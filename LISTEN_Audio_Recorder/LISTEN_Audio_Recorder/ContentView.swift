import SwiftUI
import AVFoundation

struct AudioRecorderView: View {
    @State private var audioRecorder: AVAudioRecorder!
    @State private var audioPlayer: AVAudioPlayer!
    @State private var isRecording = false
    var audioFilename: URL {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        let fileName = "1234_\(timestamp).m4a"

            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        }
    
    var body: some View {
        VStack {
            Button(action: {
                if self.audioRecorder == nil {
                    self.startRecording()
                } else {
                    self.finishRecording(success: true)
                }
            }) {Image(systemName: self.isRecording ? "stop.fill" : "circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(self.isRecording ? .red : .blue)
                .overlay(
                Text(self.isRecording ? "Stop Recording" : "Start Recording")
                                        .foregroundColor(.black)
                                        .font(.caption)
            )
        }/*{
                Text(self.isRecording ? "Stop Recording" : "Start Recording")
            }*/

            Button(action: {
                self.playRecordedAudio()
            }) {
                Text("Play Recorded Audio")
            }

            Button(action: {
                self.uploadToCloud()
            }) {
                Text("Upload to Cloud")
            }
        }
    }

    func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            isRecording = true
            print(audioFilename)
        } catch {
            print("Recording failed with error: \(error.localizedDescription)")
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        isRecording = false
    }

    func playRecordedAudio() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("Playback failed with error: \(error.localizedDescription)")
        }
    }

    
    // ...

    func uploadToCloud() {
        do {
            let audioData = try Data(contentsOf: audioFilename)

            guard let url = URL(string: "https://listenbe.azurewebsites.net/uploadfile/") else {
            //guard let url = URL(string: "http://192.168.12.223:80/uploadfile/") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()

            // Add audio file data
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(audioFilename.lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
            body.append(contentsOf: audioData)
            body.append("\r\n".data(using: .utf8)!)

            // Add additional form data (file type)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file_type\"\r\n\r\n".data(using: .utf8)!)
            body.append("audio\r\n".data(using: .utf8)!)

            // End the request body
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            request.httpBody = body

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error uploading to cloud: \(error.localizedDescription)")
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Status Code: \(httpResponse.statusCode)")

                        if let responseData = data {
                            let responseString = String(data: responseData, encoding: .utf8)
                            print("Response Data: \(responseString ?? "")")
                        }

                        if httpResponse.statusCode == 200 {
                            print("Audio uploaded to the cloud successfully")
                        } else {
                            print("Error uploading audio. Status Code: \(httpResponse.statusCode)")
                        }
                    }
                }
            }.resume()
        } catch {
            print("Error uploading audio: \(error.localizedDescription)")
        }
    }

    // ...



}

struct ContentView: View {
    var body: some View {
        AudioRecorderView()
        
        
        NavigationView {
                    VStack {
                        NavigationLink(destination: Audioslist()) {
                            Text("View audios for the client(from the cloud)")
                        }
                        NavigationLink(destination: AudioPlayerView()) {
                            Text("Play audios for the client(on your device)")
                        }
                    }
                    .navigationTitle("Main Page")
                }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

