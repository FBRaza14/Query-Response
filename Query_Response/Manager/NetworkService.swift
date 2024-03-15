//
//  NetworkService.swift
//  Query_Response
//
//  Created by Ahmad Azam on 15/03/2024.
//

import Foundation
 
enum GenderNetworkServiceError: Error {
    case invalidURL
    case networkError(Error)
    case genderNotFound
}
 
class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
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
        } catch {
            throw GenderNetworkServiceError.networkError("Some Network Request Issue" as? Error ?? error)
        }
    }
}
