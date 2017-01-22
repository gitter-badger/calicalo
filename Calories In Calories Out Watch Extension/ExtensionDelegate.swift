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

class ExtensionDelegate: NSObject, WKExtensionDelegate, HealthStoreProvider, CaloriesForCaomplications {
    
    var healthStore: HKHealthStore?
    var calories: Int?

    func applicationDidFinishLaunching() {
        if(HKHealthStore.isHealthDataAvailable()){
            healthStore = HKHealthStore()
        }
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeInterval: 60, since: Date()), userInfo: nil){
            error in
            if let error = error{
                fatalError(error.localizedDescription)
            }
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
                
                guard WKExtension.shared().applicationState == WKApplicationState.background else{
                    WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeInterval: 60, since: Date()), userInfo: nil){
                        error in
                        if let error = error{
                            fatalError(error.localizedDescription)
                        }
                    }
                    backgroundTask.setTaskCompleted()
                    return
                }
                
                if let mainInterfaceController = WKExtension.shared().rootInterfaceController as? UpdateCaloriesInBackground{
                    mainInterfaceController.updateCalories(){
                        [weak self]calories in
                        
                        self?.calories = calories
                        
                        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeInterval: 900, since: Date()), userInfo: nil){
                            error in
                            if let error = error{
                                fatalError(error.localizedDescription)
                            }
                        }

                        backgroundTask.setTaskCompleted()
                    }
                }
                else {
                    WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeInterval: 900, since: Date()), userInfo: nil){
                        error in
                        if let error = error{
                            fatalError(error.localizedDescription)
                        }
                    }
                    backgroundTask.setTaskCompleted()
                    

                }
                
                
                
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                guard WKExtension.shared().applicationState == WKApplicationState.background else{
                    snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
                    return
                }
                
                if let mainInterfaceController = WKExtension.shared().rootInterfaceController as? UpdateCaloriesInBackground{
                    mainInterfaceController.updateCalories(){
                        [weak self]calories in
                        self?.calories = calories

                        snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
                    }
                }
                else {
                    snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
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
