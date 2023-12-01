import SwiftUI
import AVKit

struct AudioPlayerView: View {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    @State private var audioFiles: [URL] = []

    var body: some View {
        VStack {
            List(audioFiles, id: \.self) { audioFile in
                Button(action: {
                    playAudio(audioURL: audioFile)
                }) {
                    Text(audioFile.lastPathComponent)
                }
            }
            .onAppear {
                fetchAudioFiles()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Audio Files")
    }

    func fetchAudioFiles() {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            audioFiles = directoryContents.filter { $0.pathExtension == "mp3" || $0.pathExtension == "m4a" } // Filter audio files (you can adjust the file extensions)
        } catch {
            print("Error fetching audio files: \(error.localizedDescription)")
        }
    }

    func playAudio(audioURL: URL) {
        let player = AVPlayer(url: audioURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        UIApplication.shared.windows.first?.rootViewController?.present(playerViewController, animated: true) {
            player.play()
        }
    }
}

