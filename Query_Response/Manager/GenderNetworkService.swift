//
//  NetworkService.swift
//  Query_Response
//
//  Created by Ahmad Azam on 15/03/2024.
//

import Foundation

// Define the protocol
protocol GenderNetworkServiceProtocol {
    func fetchGender(forName name: String) async throws -> String
}

// Define the custom error type
enum GenderNetworkServiceError: Error {
    case invalidURL
    case networkError(Error)
    case genderNotFound
}

// Make GenderNetworkService conform to the protocol
class GenderNetworkService: GenderNetworkServiceProtocol {
    static let shared = GenderNetworkService()
    
    private init() {}
    
    // Implemented the protocol method
    func fetchGender(forName name: String) async throws -> String {
        guard let url = URL(string: "https://api.genderize.io?name=\(name)") else {
            throw GenderNetworkServiceError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(GenderModel.self, from: data)
            if let gender = response.gender, !gender.isEmpty {
                return gender
            } else {
                throw GenderNetworkServiceError.genderNotFound
            }
        } catch GenderNetworkServiceError.genderNotFound {
            throw GenderNetworkServiceError.genderNotFound
        } catch {
            throw GenderNetworkServiceError.networkError("Some Network Request Issue" as? Error ?? error)
        }
    }
}
