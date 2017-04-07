//
//  AnalyticService.swift
//  Pods
//
//  Created by vlad on 4/6/17.
//
//

import UIKit
import CoreData

class AnalyticService: NSObject {
    let context: NSManagedObjectContext
    let webservice: AnalyticWebservice

    init(moc: NSManagedObjectContext = SessionManager.shared.coreDataManager.mainContext, webservice: AnalyticWebservice = AnalyticWebservice()) {
        context = moc
        self.webservice = webservice
    }
    
    func stampSelected(stampId: Int32) {
        storeEvent(forId: stampId, category: Event.Category.stamp, action: Event.Action.use)
    }

    func storySelected(storyId: Int32) {
        storeEvent(forId: storyId, category: Event.Category.story, action: Event.Action.use)
    }

    func storyShared(storyId: Int32) {
        storeEvent(forId: storyId, category: Event.Category.story, action: Event.Action.share)
    }

    private func storeEvent(forId id: Int32, category: String, action: String) {
        let entityName = String(describing: Event.self)

        guard let newEvent = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? Event else {
            printErr("can't create an event")

            return
        }

        newEvent.label = id
        newEvent.category = category
        newEvent.action = action

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                printErr("can't create an event", error: error)
            }
        }
    }

    func sendAnalytics() {
        analyticQueue.async {
            self.semaphore.wait()
            
            guard let allAnalytics = Event.stk_findAll(context: self.context) as? [Event] else {
                printErr("can't access analytics")
                
                self.semaphore.signal()
                
                return
            }
            
            guard !allAnalytics.isEmpty else {
                self.semaphore.signal()
                
                return
            }
            
            let analyticsDicts = allAnalytics.map { $0.dictionaryRepresentation() }
            
            self.webservice.sendAnalytics(withDicts: analyticsDicts) { error in
                guard error == nil else {
                    printErr("can't send statistic", error: error)
                    
                    return
                }
                
                for event in allAnalytics {
                    self.context.delete(event)
                }
                
                if self.context.hasChanges {
                    do {
                        try self.context.save()
                    } catch {
                        printErr("can't delete an event", error: error)
                    }
                }
                
                self.semaphore.signal()
            }
        }
    }
    
    private let analyticQueue = DispatchQueue(label: "com.zweigraf.DisplayLiveSamples.sampleQueue")
    let semaphore = DispatchSemaphore(value:1)
}
