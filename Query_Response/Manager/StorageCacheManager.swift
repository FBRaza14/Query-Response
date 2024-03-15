//
//  StorageCacheManager.swift
//  Query_Response
//
//  Created by Ahmad Azam on 15/03/2024.
//

import CoreData
import UIKit

class StorageCacheManager {
    static let shared = StorageCacheManager()
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
        let olderThanThirtyMinutes = Date().addingTimeInterval(-120) // 30 minutes ago
        fetchRequest.predicate = NSPredicate(format: "timestamp < %@", olderThanThirtyMinutes as NSDate)
        do {
            let screenshots = try context.fetch(fetchRequest)
            for screenshot in screenshots {
                if let relativePath = screenshot.url {
                    // Append the relative path to the app's document directory URL
                    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(relativePath)
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                        context.perform {
                            context.delete(screenshot) // call in backkground
                        }
                        try context.save()
                    } catch {
#if DEBUG
                        print("Error deleting screenshot at \(fileURL): \(error)")
#endif
                    }
                }
            }
        } catch {
#if DEBUG
            print("Error fetching screenshots: \(error)")
#endif
        }
    }
}
