//
//  ScreenshotManager.swift
//  Query_Response
//
//  Created by Ahmad Azam on 15/03/2024.
//

import CoreData
import UIKit

class ScreenshotManager {
    static let shared = ScreenshotManager()
    
    private let persistenceController = PersistenceController.shared
    
    private init() {}
    
    func saveScreenshotToDocumentDirectory(image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        let filename = "\(timestamp).png"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if let imageData = image.pngData() {
            do {
                try imageData.write(to: fileURL)
                persistenceController.saveScreenshot(fileName: filename)
            } catch {
#if DEBUG
                print("Error saving screenshot to document directory: \(error)")
#endif
            }
        }
    }
    
    func deleteOldScreenshots() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<ScreenshotsEntity> = ScreenshotsEntity.fetchRequest()
        let olderThanThirtyMinutes = Date().addingTimeInterval(-1800) // 30 minutes ago
        fetchRequest.predicate = NSPredicate(format: "timestamp < %@", olderThanThirtyMinutes as NSDate)
        
        do {
            let screenshots = try context.fetch(fetchRequest)
            print("Screen shots are", screenshots.count)
            for screenshot in screenshots {
                if let relativePath = screenshot.url {
                    // Append the relative path to the app's document directory URL
                    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(relativePath)
                    
                    // Perform file deletion asynchronously on a background queue
                    DispatchQueue.global(qos: .background).async {
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                            // Perform deletion of the entity on the main queue
                            DispatchQueue.main.async {
                                context.delete(screenshot)
                            }
                        } catch {
#if DEBUG
                            print("Error deleting screenshot at \(fileURL): \(error)")
#endif
                        }
                    }
                }
            }
            try context.save()
        } catch {
#if DEBUG
            print("Error fetching screenshots: \(error)")
#endif
        }
    }
}
