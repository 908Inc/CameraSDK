//
//  AnalyticService.swift
//  Pods
//
//  Created by vlad on 4/6/17.
//
//

import UIKit
import CoreData

// prevents any statistic to be sent during debug
class DebugAnalyticService: AnalyticService {
    override func appOpenedFromPush(pushId: Int32) {}
    override func stampSelected(stampId: Int32) {}
    override func storySelected(storyId: Int32) {}
    override func storyShared(storyId: Int32) {}
    override func sendAnalytics() {}
}

public class AnalyticService: NSObject {
    let context: NSManagedObjectContext
    let webservice: AnalyticWebservice

    init(moc: NSManagedObjectContext = SessionManager.shared.coreDataManager.mainContext, webservice: AnalyticWebservice = AnalyticWebservice()) {
        context = moc
        self.webservice = webservice
    }

    public func appOpenedFromPush(pushId: Int32) {
        storeEvent(forId: pushId, category: Event.Category.appOpen.rawValue, action: Event.Action.push.rawValue)
    }

    func stampSelected(stampId: Int32) {
        storeEvent(forId: stampId, category: Event.Category.stamp.rawValue, action: Event.Action.use.rawValue)
    }

    func storySelected(storyId: Int32) {
        storeEvent(forId: storyId, category: Event.Category.story.rawValue, action: Event.Action.use.rawValue)
    }

    func storyShared(storyId: Int32) {
        storeEvent(forId: storyId, category: Event.Category.story.rawValue, action: Event.Action.share.rawValue)
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
            
            self.webservice.sendAnalytics(withDicts: analyticsDicts) { response, error in
                defer { self.semaphore.signal() }

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
            }
        }
    }
    
    private let analyticQueue = DispatchQueue(label: "com.zweigraf.DisplayLiveSamples.sampleQueue")
    let semaphore = DispatchSemaphore(value:1)
}
