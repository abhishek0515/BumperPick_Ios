//
//  AuthService.swift
//  BumperPick
//
//  Created by tauseef hussain on 19/05/25.
//

import Foundation

//final class APIManager {
//    
//    static let shared = APIManager()  // Singleton instance
//    
//    private init() {}  // Private initializer prevents others from creating instances
//    
//    // Generic API request method
//    func request<T: Decodable>(
//        url: URL,
//        method: String = "GET",
//        body: Data? = nil,
//        headers: [String: String] = [:],
//        responseType: T.Type,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.httpBody = body
//        
//        headers.forEach { key, value in
//            request.setValue(value, forHTTPHeaderField: key)
//        }
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            
//            // Handle error
//            if let error = error {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//                return
//            }
//            
//            // Handle response
//            guard let data = data else {
//                DispatchQueue.main.async {
//                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
//                }
//                return
//            }
//            
//            do {
//                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(decodedResponse))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }
//        
//        task.resume()
//    }
//}

final class APIManager {
    
    static let shared = APIManager()
    
    private init() {}
    
    func request<T: Decodable>(
        url: URL,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:],
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // 🔴 Print raw URL request
            print("\n➡️ [Request] \(method) \(url.absoluteString)")
            if let headers = request.allHTTPHeaderFields {
                print("Headers:", headers)
            }
            if let body = body, let json = try? JSONSerialization.jsonObject(with: body) {
                print("Body:", json)
            }

            // 🔴 Print response
            if let httpResponse = response as? HTTPURLResponse {
                print("⬅️ [Response Code]: \(httpResponse.statusCode)")
            }

            // 🔴 Handle error
            if let error = error {
                print("❌ [Error]:", error.localizedDescription)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                print("❌ [Error]: No data returned")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
                }
                return
            }

            // 🔴 Print raw JSON response
            if let rawJSON = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                print("📦 [Raw JSON]:", rawJSON)
            } else {
                print("⚠️ [Warning]: Could not parse raw JSON")
            }

//            do {
//                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
//                print("✅ [Decoded]:", decodedResponse)
//                DispatchQueue.main.async {
//                    completion(.success(decodedResponse))
//                }
//            } catch {
//                print("❌ [Decoding Error]:", error)
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                print("✅ [Decoded]:", decoded)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch let decodingError as DecodingError {
                completion(.failure(APIError.decodingError(decodingError, rawData: data)))
            } catch {
                completion(.failure(APIError.unknown(error)))
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
