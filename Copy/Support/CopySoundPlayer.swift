import AppKit

/// Plays the optional feedback for a clipboard capture. The sounds are the ones macOS
/// already ships in `/System/Library/Sounds`, so Copy bundles no audio of its own: a
/// stock-audio licence that permits redistribution from a public GPL repository is hard
/// to satisfy (both Pixabay and Mixkit forbid handing their files over on their own, and
/// a file in this repo is downloadable on its own), and a system sound already follows
/// the listener's output device and alert volume.
@MainActor
final class CopySoundPlayer {
    static let shared = CopySoundPlayer()

    private var cache: [CopySound: NSSound] = [:]
    private var playing: NSSound?

    private init() {}

    func play(_ choice: CopySound) {
        // A burst of copies should sound like the latest one, not like all of them.
        playing?.stop()
        playing = nil

        guard let name = choice.systemSoundName else { return }
        let sound: NSSound
        if let cached = cache[choice] {
            sound = cached
        } else {
            guard let loaded = NSSound(named: name) else { return }
            cache[choice] = loaded
            sound = loaded
        }
        playing = sound
        sound.play()
    }
}
