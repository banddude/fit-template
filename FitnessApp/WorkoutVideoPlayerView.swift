import SwiftUI
import AVFoundation
import AVKit

struct WorkoutVideoPlayerView: UIViewRepresentable {
    let player: AVPlayer?

    func makeUIView(context: Context) -> UIView {
        let view = PlayerContainerView()
        view.backgroundColor = .black

        guard let player = player else { return view }

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.playerLayer = playerLayer
        view.layer.addSublayer(playerLayer)

        // Store reference for coordinator
        context.coordinator.playerLayer = playerLayer
        context.coordinator.player = player

        // Configure audio session
        configureAudioSession()

        // Configure for smooth playback
        player.isMuted = true
        player.automaticallyWaitsToMinimizeStalling = false

        // Setup looping
        context.coordinator.setupLooping(for: player)

        // Reset and play
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
            player.play()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let containerView = uiView as? PlayerContainerView,
              let playerLayer = context.coordinator.playerLayer,
              let player = context.coordinator.player else { return }

        // Update frame without animation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = containerView.bounds
        CATransaction.commit()

        // Ensure player is playing when view updates (handles recycled views)
        if player.rate == 0 && player.currentItem != nil {
            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                player.play()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.cleanup()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
        var player: AVPlayer?
        var loopObserver: Any?

        func setupLooping(for player: AVPlayer) {
            // Remove any existing observer
            if let observer = loopObserver {
                NotificationCenter.default.removeObserver(observer)
            }

            loopObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }

        func cleanup() {
            if let observer = loopObserver {
                NotificationCenter.default.removeObserver(observer)
                loopObserver = nil
            }
        }

        deinit {
            cleanup()
        }
    }

    // Custom UIView that updates layer frame on layout
    class PlayerContainerView: UIView {
        var playerLayer: AVPlayerLayer?

        override func layoutSubviews() {
            super.layoutSubviews()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            playerLayer?.frame = bounds
            CATransaction.commit()
        }
    }
    
    private func configureAudioSession() {
        do {
            // Set audio session category to allow mixing with other audio
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}