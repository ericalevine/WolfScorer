import Foundation
import CoreMotion
import AVFoundation
import WatchKit

@MainActor
class ImpactDetector: ObservableObject {
    @Published var isListening = false
    @Published var detectionsThisHole = 0

    var onImpact: (() -> Void)?

    private let motion = CMMotionManager()
    private let audioEngine = AVAudioEngine()

    // Low thresholds require both signals within fusionWindow
    private let audioLow: Float   = 0.15
    private let accelLow: Double  = 3.5   // net g
    // High thresholds fire standalone
    private let audioHigh: Float  = 0.40
    private let accelHigh: Double = 8.0   // Wolf's own swing

    private let fusionWindow: TimeInterval = 0.25
    private let debounce: TimeInterval = 1.5

    private var lastAudioSpike: Date?
    private var lastAccelSpike: Date?
    private var lastConfirmed: Date?
    private var audioMicAvailable = false

    func startListening() {
        guard !isListening else { return }
        detectionsThisHole = 0
        startAccelerometer()
        startMicrophone()
        isListening = true
    }

    func stopListening() {
        guard isListening else { return }
        motion.stopAccelerometerUpdates()
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isListening = false
    }

    func resetCount() {
        detectionsThisHole = 0
    }

    // MARK: - Accelerometer

    private func startAccelerometer() {
        guard motion.isAccelerometerAvailable else { return }
        motion.accelerometerUpdateInterval = 0.01
        motion.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            let a = data.acceleration
            let net = sqrt(a.x*a.x + a.y*a.y + a.z*a.z) - 1.0

            if net > self.accelHigh {
                self.lastAccelSpike = Date()
                self.evaluate(accelAlone: true)
            } else if net > self.accelLow {
                self.lastAccelSpike = Date()
                self.evaluate()
            }
        }
    }

    // MARK: - Microphone

    private func startMicrophone() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
            try session.setActive(true)

            let input = audioEngine.inputNode
            let format = input.inputFormat(forBus: 0)
            guard format.channelCount > 0 else { return }

            audioMicAvailable = true
            input.installTap(onBus: 0, bufferSize: 512, format: format) { [weak self] buffer, _ in
                let rms = Self.rms(buffer)
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if rms > self.audioHigh {
                        self.lastAudioSpike = Date()
                        self.evaluate(audioAlone: true)
                    } else if rms > self.audioLow {
                        self.lastAudioSpike = Date()
                        self.evaluate()
                    }
                }
            }
            try audioEngine.start()
        } catch {
            // Falls back to accelerometer-only mode
        }
    }

    private static func rms(_ buffer: AVAudioPCMBuffer) -> Float {
        guard let data = buffer.floatChannelData, buffer.frameLength > 0 else { return 0 }
        let n = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<n { sum += data[0][i] * data[0][i] }
        return sqrt(sum / Float(n))
    }

    // MARK: - Fusion

    private func evaluate(audioAlone: Bool = false, accelAlone: Bool = false) {
        let now = Date()
        guard now.timeIntervalSince(lastConfirmed ?? .distantPast) > debounce else { return }

        let confirmed: Bool
        if audioAlone || accelAlone {
            confirmed = true
        } else if let a = lastAudioSpike, let b = lastAccelSpike {
            confirmed = abs(a.timeIntervalSince(b)) < fusionWindow
        } else {
            confirmed = false
        }

        guard confirmed else { return }
        lastConfirmed = now
        lastAudioSpike = nil
        lastAccelSpike = nil
        detectionsThisHole += 1
        WKInterfaceDevice.current().play(.notification)
        onImpact?()
    }
}
