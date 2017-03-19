//
//  ExtensionDelegate.swift
//  Calories In Calories Out Watch Extension
//
//  Created by Ryan Klein on 1/17/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import WatchKit
import HealthKit
import ClockKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, HealthStoreProvider, CalorieDataContainer {
    
    var healthStore: HKHealthStore?
    
    var synchronousCalorieDataLoader:SynchronousCalorieDataLoader?
    
    var calorieData:CalorieData?

    func applicationDidFinishLaunching() {
        
        if WCSession.isSupported(){
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                
                defer{
                    WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeInterval: 900, since: Date()), userInfo: nil){
                        error in
                        if let error = error{
                            fatalError(error.localizedDescription)
                        }
                    }
                    backgroundTask.setTaskCompleted()
                }

                
                guard WKExtension.shared().applicationState == WKApplicationState.background else{
                    return
                }
                
                guard let healthStore = healthStore else {
                    //The health store was not instantiated by the Interface Controller
                    return
                }
                
                DispatchQueue.global().sync {
                    
                    let dataLoader = SynchronousCalorieDataLoader(healthStore:healthStore)
                    guard let calorieData = dataLoader.loadCalories() else {
                        return
                    }
                    //Note the interface controller will set the calorieData property on this class
                    WKInterfaceController.reloadRootControllers(withNames: ["mainController","dietaryDetailsController"], contexts: [calorieData, calorieData])
                    
                    let server = CLKComplicationServer.sharedInstance()
                    guard let complications = server.activeComplications, complications.count > 0 else {
                        return
                    }
                    
                    for complication in complications{
                        server.reloadTimeline(for: complication)
                    }
                }
                
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                
                defer{
                    snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
                }
                
                guard WKExtension.shared().applicationState == WKApplicationState.background else{
                    return
                }
                
                guard let healthStore = healthStore else {
                    //The health store was not instantiated by the Interface Controller
                    return
                }

                
                DispatchQueue.global().sync {
                    let dataLoader = SynchronousCalorieDataLoader(healthStore:healthStore)
                    guard let calorieData = dataLoader.loadCalories() else {
                        return
                    }
                    
                    self.calorieData = calorieData
                    //Note the interface controller will set the calorieData property on this class
                    WKInterfaceController.reloadRootControllers(withNames: ["mainController","dietaryDetailsController"], contexts: [calorieData, calorieData])
                    
                    let server = CLKComplicationServer.sharedInstance()
                    guard let complications = server.activeComplications, complications.count > 0 else {
                        return
                    }
                    for complication in complications{
                        server.reloadTimeline(for: complication)
                    }
                }
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }

}

extension ExtensionDelegate:WCSessionDelegate{
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        UserDefaults.standard.set(userInfo["unit"], forKey:"com.base11studios.cico.unit")
        UserDefaults.standard.synchronize()
    }
    
}
