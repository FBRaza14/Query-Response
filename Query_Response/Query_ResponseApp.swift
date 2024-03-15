//
//  Query_ResponseApp.swift
//  Query_Response
//
//  Created by Ahmad Azam on 13/03/2024.
//

import SwiftUI
import CoreData

@main
struct Query_ResponseApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let persistenceController = PersistenceController.shared
    @State private var timer: Timer?

    var body: some Scene {
        WindowGroup {
            GenderCheckerView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    startScreenshotCleanupTimer()
                }
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active: // on active start timer.
                        startScreenshotCleanupTimer()
                    case .background: // while go in background invalidate timer.
                        timer?.invalidate()
                        timer = nil
                    default:
                        break
                    }
                }
        }
    }

    private func startScreenshotCleanupTimer() {
        guard timer == nil else { return } // Timer already started so return.

        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { timer in
            DispatchQueue.main.async(qos: .background) { // in background thread clearing the cache.
                StorageCacheManager.shared.deleteOldScreenshots()
                persistenceController.deleteCachedResponse()
            }
        }
    }
}

