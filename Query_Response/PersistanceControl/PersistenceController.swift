//
//  PersistenceController.swift
//  Query_Response
//
//  Created by Ahmad Azam on 14/03/2024.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    private init() {}
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CacheModel")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
#if DEBUG
                print("Unresolved error \(error), \(error.userInfo)")
#endif
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    // MARK: - Save request data to CachedResponseEntity
    func saveCachedResponse(input: String, response: String) {
        let context = container.viewContext
        let cachedResponse = CachedResponseEntity(context: context)
        cachedResponse.input = input
        cachedResponse.response = response
        cachedResponse.timestamp = Date()
        save()
    }
    
    // MARK: - Save screenshot data to ScreenshotsEntity
    func saveScreenshot(fileName: String) {
        let context = container.viewContext
        let screenshotEntity = ScreenshotsEntity(context: context)
        screenshotEntity.timestamp = Date()
        screenshotEntity.url = fileName // saving relative fileName
        save()
    }
    
    // MARK: - Fetch cached request data
    func getCachedResponse(for input: String) -> String? {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<CachedResponseEntity> = CachedResponseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "input == %@", input)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let cachedResponses = try context.fetch(fetchRequest)
            if let cachedResponse = cachedResponses.first, !isCacheExpired(timestamp: cachedResponse.timestamp ?? Date()) {
                return cachedResponse.response
            }
        } catch {
#if DEBUG
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
#endif
        }
        return nil
    }

    func isCacheExpired(timestamp: Date) -> Bool {
        let cacheExpirationTime: TimeInterval = 600 // 10 minutes
        let expirationDate = timestamp.addingTimeInterval(cacheExpirationTime)
        return Date() > expirationDate
    }
    
    // MARK: - Core Data Saving support
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
#if DEBUG
                print("Error saving context: \(error)")
#endif
            }
        }
    }
}
