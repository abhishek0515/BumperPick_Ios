//
//  EditProfileViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 18/06/25.
//


import Foundation
import SwiftUI

class EditProfileViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var alerMessage: String?
    @Published var showAlert = false
    @Published var isSuccess = false
    
    func updateProfile(token: String, name: String, phone: String, email: String, imageData: Data?) {
        guard let url = URL(string: AppString.baseUrl + AppString.customerProfileUpdate) else {
            self.alerMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()

        // Add name
        body.append(convertFormField(named: "name", value: name, using: boundary))
        // Add phone
        body.append(convertFormField(named: "phone_number", value: phone, using: boundary))
        // Add email
        body.append(convertFormField(named: "email", value: email, using: boundary))
        // Add token
        body.append(convertFormField(named: "token", value: token, using: boundary))

        // Add image if exists
        if let data = imageData {
            body.append(convertFileData(fieldName: "image",
                                        fileName: "profile.jpg",
                                        mimeType: "image/jpeg",
                                        fileData: data,
                                        using: boundary))
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        isLoading = true
        alerMessage = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.alerMessage = "Network error: \(error.localizedDescription)"
                    self.showAlert = true
                    self.isSuccess = false
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.alerMessage = "Invalid server response"
                    self.showAlert = true
                    self.isSuccess = false
                }
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                   // self.alerMessage = "Server error: \(httpResponse.statusCode)"
                    if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                        print("🔸 Server response JSON:\n\(jsonString)")
                        self.alerMessage = jsonString
                        self.showAlert = true
                        self.isSuccess = false
                    }
                }
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.alerMessage = "Profile Update Successfully!"
                    self.showAlert = true
                    self.isSuccess = true
                    print("✅ Response: \n\(responseString)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("🔍 success JSON (for debugging):\n\(jsonString)")
                    }
                }
            }
        }.resume()
    }

    private func convertFormField(named name: String, value: String, using boundary: String) -> Data {
        var fieldString = ""
        fieldString += "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
        fieldString += "\(value)\r\n"
        return fieldString.data(using: .utf8) ?? Data()
    }

    private func convertFileData(fieldName: String,
                                 fileName: String,
                                 mimeType: String,
                                 fileData: Data,
                                 using boundary: String) -> Data {
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
        return data
    }
}
