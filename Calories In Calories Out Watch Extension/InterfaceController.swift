//
//  InterfaceController.swift
//  Calories In Calories Out Watch Extension
//
//  Created by Ryan Klein on 1/17/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController {
    @IBOutlet var totalCaloriesLabel: WKInterfaceLabel!
    @IBOutlet var activeCaloriesLabel: WKInterfaceLabel!
    @IBOutlet var caloriesConsumedLabel: WKInterfaceLabel!
    @IBOutlet var restingCaloriesLabel: WKInterfaceLabel!
    
    var healthStore:HKHealthStore?
    
    let dispatchGroup:DispatchGroup = DispatchGroup()
    
    let basalEnergyType = HKQuantityType.quantityType(forIdentifier:.basalEnergyBurned)
    
    let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
    
    let caloriesConsumedType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)
    
    var calorieData:CalorieData?{
        didSet{
            if let calorieData = calorieData, let restingCalories = calorieData.restingCaloriesAverage, let activeCalories = calorieData.activeCalories, let caloriesConsumed = calorieData.caloriesConsumed, let netCalories = calorieData.netCalories {
                restingCaloriesLabel.setText(String(restingCalories))
                activeCaloriesLabel.setText(String(activeCalories))
                caloriesConsumedLabel.setText(String(caloriesConsumed))
                totalCaloriesLabel.setText(String(netCalories))
            }
        }
    }


    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let healthStoreProvider = WKExtension.shared().delegate as? HealthStoreProvider{
            healthStore = healthStoreProvider.healthStore
            
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}


extension InterfaceController:CalorieDataLoader{
    func allDone(){
        if let calorieData = calorieData, let restingCalories = calorieData.restingCaloriesAverage, let activeCalories = calorieData.activeCalories, let caloriesConsumed = calorieData.caloriesConsumed, let netCalories = calorieData.netCalories {
            restingCaloriesLabel.setText(String(restingCalories))
            activeCaloriesLabel.setText(String(activeCalories))
            caloriesConsumedLabel.setText(String(caloriesConsumed))
            totalCaloriesLabel.setText(String(netCalories))
        }
        let server = CLKComplicationServer.sharedInstance()
        guard let complications = server.activeComplications, complications.count > 0 else {
            return
        }
        
        server.reloadTimeline(for: complications[0])
        
    }
    
    func willLoadCalories() {
        let loadingString = "Loading..."
        
        restingCaloriesLabel.setText(loadingString)
        activeCaloriesLabel.setText(loadingString)
        caloriesConsumedLabel.setText(loadingString)
        totalCaloriesLabel.setText(loadingString)

    }

}
