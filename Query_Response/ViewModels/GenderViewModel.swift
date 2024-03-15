//
//  GenderViewModel.swift
//  Query_Response
//
//  Created by Ahmad Azam on 14/03/2024.
//

import Foundation
import UIKit

class GenderViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var gender: String?

    @MainActor
    func fetchGender() async throws {
        guard let formattedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        // Check if the response is cached in Core Data
        if let cachedResponseString = PersistenceController.shared.getCachedResponse(for: formattedName) {
            // Use the cached response
            self.gender = cachedResponseString
            return
        }
        
        // Fetch the gender from the API if not cached or cache expired
        do {
            let response = try await NetworkService.shared.fetchGender(forName: formattedName)
            self.gender = response
            
            // Cache the response in Core Data
            PersistenceController.shared.saveCachedResponse(input: formattedName, response: response)
        } catch {
            throw error
        }
    }

    var genderInfoHTML: String {
        let genderText = gender ?? "Unknown"
        
        return """
        <html>
        <head>
        <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            padding: 20px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            transform: scale(2.0);
        }
        h2 {
            color: #333;
        }
        h1 {
            color: #7a4cb5;
        }
        p {
            color: #666;
        }
        </style>
        </head>
        <body>
        <div class="container">
            <h2>Your Gender Details</h2>
            <h1>Hi, \(name):</h1>
            <p>Your Gender is: \(genderText)</p>
        </div>
        </body>
        </html>
        """
    }
}
