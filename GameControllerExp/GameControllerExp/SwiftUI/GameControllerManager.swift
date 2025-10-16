//
//  GameControllerManager.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 10/12/25.
//

import Foundation
import GameController
import simd

struct Pointer {
    var pitch: Double
    var yaw: Double
    var roll: Double
}

@Observable
@MainActor
class GameControllerManager {
    private(set) var connected: GCController?
    private(set) var controllerState: (any GCDevicePhysicalInputState & GCDevicePhysicalInputStateDiff)?
    private(set) var motion: GCMotion?
    private(set) var pointer = Pointer(pitch: 0, yaw: 0, roll: 0)
    @ObservationIgnored private var lastUpdateTime = CACurrentMediaTime()

    init() {
        resetOrientation()
        setupNotificationObservers()
    }

    @MainActor
    deinit {
        removeNotificationObservers()
    }

    func resetOrientation() {
        pointer = Pointer(pitch: 0, yaw: 0, roll: 0)
    }

    func list() -> [GCController] {
        GCController.controllers()
    }

    func connect(_ controller: GCController) {
        connected = controller
        setupExtendedController(controller)
    }

    func disconnect() {
        if let connected {
            connected.motion?.sensorsActive = false
            connected.motion?.valueChangedHandler = nil
            connected.input.inputStateAvailableHandler = nil
        }

        resetOrientation()
        connected = nil
        motion = nil
        controllerState = nil
    }

    private func setupExtendedController(_ controller: GCController) {
        controller.input.inputStateAvailableHandler = { input in
            while let nextState = input.nextInputState() {
                Task { [weak self] in
                    self?.setInputState(nextState)
                }
            }
        }

        if let motion = controller.motion {
            self.motion = motion
            if motion.sensorsRequireManualActivation {
                motion.sensorsActive = true
            }
            motion.valueChangedHandler = { motion in
                Task { [weak self] in
                    self?.updateMotion(motion)
                }
            }
        }
    }

    private func updateMotion(_ motion: GCMotion) {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime

        updatePointer(motion: motion, deltaTime: deltaTime)

        lastUpdateTime = currentTime
    }

    private func updatePointer(motion: GCMotion, deltaTime: CFTimeInterval) {
        let rotRate = motion.rotationRate

        let deadZone = 0.05
        let angularVelocity = simd_double3(
            abs(rotRate.x) > deadZone ? rotRate.x : 0,
            abs(rotRate.y) > deadZone ? rotRate.y : 0,
            abs(rotRate.z) > deadZone ? rotRate.z : 0
        )

        let rotationSpeed = simd_length(angularVelocity)

        if rotationSpeed > 0.001 {
            pointer.pitch -= angularVelocity.x * deltaTime
            pointer.yaw -= angularVelocity.z * deltaTime
            pointer.roll += angularVelocity.y * deltaTime
        }
    }

    private nonisolated func debugMotion(motion: GCMotion) {
        // Gravity vector (accelerometer data)
        let gravity = motion.gravity
        print("Gravity - X: \(gravity.x), Y: \(gravity.y), Z: \(gravity.z)")

        // User acceleration (gravity removed)
        let userAcceleration = motion.userAcceleration
        print("User Accel - X: \(userAcceleration.x), Y: \(userAcceleration.y), Z: \(userAcceleration.z)")

        let acceleration = motion.acceleration
        print("Acceleration - X: \(acceleration.x), Y: \(acceleration.y), Z: \(acceleration.z)")

        // Rotation rate (gyroscope data in radians/second)
        let rotationRate = motion.rotationRate
        print("Rotation - X: \(rotationRate.x), Y: \(rotationRate.y), Z: \(rotationRate.z)")

        // Attitude (orientation quaternion)
        if motion.hasAttitude {
            let attitude = motion.attitude
            print("Attitude - X: \(attitude.x), Y: \(attitude.y), Z: \(attitude.z), W: \(attitude.w)")
        } else {
            print("No Attitude")
        }
        print("=========================")
    }

    private func setInputState(_ input: any GCDevicePhysicalInputState & GCDevicePhysicalInputStateDiff) {
        controllerState = input
    }

    private nonisolated func debugInputState(_ input: any GCDevicePhysicalInputState & GCDevicePhysicalInputStateDiff) {
        for button in input.buttons {
            print("button: \(button.debugDescription ?? button.description)")
        }

        for axis in input.axes {
            print("axis: \(axis.debugDescription ?? axis.description)")
        }

        for `switch` in input.switches {
            print("switch: \(`switch`.debugDescription ?? `switch`.description)")
        }

        for dpad in input.dpads {
            print("dpad: \(dpad.debugDescription ?? dpad.description)")
        }
        print("=========================")
    }
}

extension GameControllerManager {
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidBecomeCurrent),
            name: .GCControllerDidBecomeCurrent,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidStopBeingCurrent),
            name: .GCControllerDidStopBeingCurrent,
            object: nil
        )
    }

    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private nonisolated func controllerDidBecomeCurrent(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        print("[GCControllerDidBecomeCurrent]\n\(controller.identifierDescription)")

        Task { @MainActor in
            if connected === controller {
                print("[GCControllerDidBecomeCurrent] Already connected to this controller")
                return
            }

            connect(controller)
        }
    }

    @objc private nonisolated func controllerDidStopBeingCurrent(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        print("[GCControllerDidStopBeingCurrent]\n\(controller.identifierDescription)")

        Task { @MainActor in
            if connected === controller {
                print("[GCControllerDidStopBeingCurrent] Disconnecting controller")
                disconnect()
            } else {
                print("[GCControllerDidStopBeingCurrent] Not the currently connected controller")
            }
        }
    }
}

extension GCController {
    nonisolated var identifierDescription: String {
        """
        Controller Info:
        - Vendor Name: \(vendorName ?? "Unknown")
        - Product Category: \(productCategory)
        - Player Index: \(playerIndex.rawValue)
        - Is Attached to Device: \(isAttachedToDevice)
        """
    }
}
