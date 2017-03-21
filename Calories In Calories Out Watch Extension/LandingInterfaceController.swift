//
//  LandingInterfaceController.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 3/19/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation
import UIKit
import WatchKit
import HealthKit

class LandingInterfaceController:WKInterfaceController{
    
    @IBOutlet var landingLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        
        guard let delegate = WKExtension.shared().delegate else {
            fatalError("The extension delegate was not initialized")
        }
        
        guard var healthStoreProvider = delegate as? HealthStoreProvider else {
            fatalError("The extension delegate is not available as HealthStoreProvider")
        }

        
        //Initializing this here because there is no garauntee that the WKExtensionDelegate finished lauching before this method is called
        if(HKHealthStore.isHealthDataAvailable()){
            let healthStore = HKHealthStore()
            healthStoreProvider.healthStore = healthStore
            DispatchQueue.global().async {
                
                let dataLoader = SynchronousCalorieDataLoader(healthStore:healthStore)
                
                guard let newCalorieData = dataLoader.loadCalories() else {
                    self.landingLabel.setText("Error")
                    return
                }
                
                WKInterfaceController.reloadRootControllers(withNames: ["mainController","dietaryDetailsController"], contexts: [newCalorieData, newCalorieData])
                
                if let relaodComplication = context as? Bool{
                    if !relaodComplication{
                        return
                    }
                }
                
                let server = CLKComplicationServer.sharedInstance()
                guard let complications = server.activeComplications, complications.count > 0 else {
                    return
                }
                for complication in complications{
                    server.reloadTimeline(for: complication)
                }
                WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeInterval: 60, since: Date()), userInfo: nil){
                    error in
                    return
                }
                
            }
            
        }
        else{
            fatalError("Health data is not available in the watch interface controller")
        }

    }
    
}
