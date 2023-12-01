/*import SwiftUI

// Define structs to match the request and response JSON structures
struct FileListRequest: Codable {
    let prefix: String
}

struct FileListResponse: Codable {
    let files: [String]
}

struct Audioslist: View {
    @State private var fileList: [String] = []

    var body: some View {
        List(fileList, id: \.self) { fileName in
            Text(fileName)
        }
        .onAppear {
            fetchFileList(prefix: "1234") // Replace "your-prefix-here" with the actual prefix you want to use
        }
        VStack {
                    Text("List of Audios")
                        .font(.title)
                    
                    // Your audio list content here
                    
                    Spacer()
                }
                .frame(maxWidth: 300, maxHeight: 400)
                .padding()
    }

    func fetchFileList(prefix: String) {
        guard let url = URL(string: "https://listenbe.azurewebsites.net/list-files/") else {
            print("Invalid URL")
            return
        }

        let requestBody = FileListRequest(prefix: "1234")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let fileListResponse = try decoder.decode(FileListResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.fileList = fileListResponse.files
                    }
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}*/

import SwiftUI

// Define structs to match the request and response JSON structures
struct FileListRequest: Codable {
    let prefix: String
}

struct FileListResponse: Codable {
    let files: [String]
}

struct DownloadRequest: Codable {
    let fileName: String
}

struct Audioslist: View {
    @State private var fileList: [String] = []

    var body: some View {
        List(fileList, id: \.self) { fileName in
            Button(action: {
                downloadFile(fileName: fileName)
            }) {
                Text(fileName)
            }
        }
        .onAppear {
            fetchFileList(prefix: "1234") // Replace "1234" with the actual prefix you want to use
        }
        .frame(maxWidth: 300, maxHeight: 400)
        .padding()
    }

    func fetchFileList(prefix: String) {
        guard let url = URL(string: "https://listenbe.azurewebsites.net/list-files/") else {
            print("Invalid URL")
            return
        }

        let requestBody = FileListRequest(prefix: prefix)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let fileListResponse = try decoder.decode(FileListResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.fileList = fileListResponse.files
                    }
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    func downloadFile(fileName: String) {
        guard let url = URL(string: "https://listenbe.azurewebsites.net/download-file/") else {
            print("Invalid download file URL")
            return
        }

        let requestBody = DownloadRequest(fileName: fileName)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            if let data = data {
                // Save the downloaded data to the system
                saveDownloadedFile(data: data, fileName: fileName)
            }
        }.resume()
    }

    func saveDownloadedFile(data: Data, fileName: String) {
        let fileManager = FileManager.default
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentsURL.appendingPathComponent(fileName)
            try data.write(to: fileURL)
            print("File saved at: \(fileURL)")
        } catch {
            print("Error saving file: \(error.localizedDescription)")
        }
    }

}


