//
//  AuthService.swift
//  BumperPick
//
//  Created by tauseef hussain on 19/05/25.
//

import Foundation


final class APIManager {
    static let shared = APIManager()

    private init() {}

    func request<T: Decodable>(
        url: URL,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:],
        responseType: T.Type,
        retryOnAuthFailure: Bool = true,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body

        var allHeaders = headers
        if let token = CustomerSession.shared.token {
            allHeaders["Authorization"] = "Bearer \(token)"
        }

        allHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        print("\n➡️ [Request] \(method) \(url.absoluteString)")
        print("Headers:", allHeaders)
        if let body = body, let json = try? JSONSerialization.jsonObject(with: body) {
            print("Body:", json)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // MARK: Handle error
            if let error = error {
                print("❌ [Error]:", error.localizedDescription)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.serverError(message: "No response")))
                }
                return
            }

            print("⬅️ [Response Code]: \(httpResponse.statusCode)")

            // MARK: Unauthorized — Try to refresh token
            if httpResponse.statusCode == 401 && retryOnAuthFailure {
                print("🔁 Attempting token refresh...")
                self.refreshToken { success in
                    if success {
                        // Retry original request with new token
                        self.request(
                            url: url,
                            method: method,
                            body: body,
                            headers: headers,
                            responseType: responseType,
                            retryOnAuthFailure: false, // Avoid infinite loop
                            completion: completion
                        )
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(APIError.serverError(message: "Token expired")))
                        }
                    }
                }
                return
            }

            // MARK: No Data
            guard let data = data else {
                print("❌ [Error]: No data returned")
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }

            // Debug
            if let rawJSON = try? JSONSerialization.jsonObject(with: data) {
                print("📦 [Raw JSON]:", rawJSON)
            }

            // MARK: Decode response
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                print("✅ [Decoded]:", decoded)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch let decodingError as DecodingError {
                DispatchQueue.main.async {
                    completion(.failure(APIError.decodingError(decodingError, rawData: data)))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(APIError.unknown(error)))
                }
            }
        }

        task.resume()
    }

    // MARK: - Refresh Token API
    private func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let currentToken = CustomerSession.shared.token else {
            print("❌ No token found for refresh")
            completion(false)
            return
        }

        let refreshURLString = AppString.baseUrl + AppString.refreshTokenApi + "?token=\(currentToken)"
        guard let url = URL(string: refreshURLString) else {
            completion(false)
            return
        }

        print("🔄 Refreshing token: \(url.absoluteString)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Refresh token request failed:", error?.localizedDescription ?? "Unknown error")
                completion(false)
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
                print("✅ Token refreshed:", tokenResponse.token)
                CustomerSession.shared.token = tokenResponse.token
                completion(true)
            } catch {
                print("❌ Failed to decode token:", error.localizedDescription)
                completion(false)
            }
        }

        task.resume()
    }
}

enum APIError: Error {
    case noData
    case decodingError(DecodingError, rawData: Data)
    case serverError(message: String)
    case unknown(Error)
}

struct RefreshTokenResponse: Codable {
    let token: String
}
