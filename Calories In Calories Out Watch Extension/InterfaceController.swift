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
    
    var restingCaloriesTotal:Int?
    var activeCalories:Int?
    var caloriesConsumed:Int?
    
    var updateCaloriesCallback:((_ calories:Int)->Void)?


    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let healthStoreProvider = WKExtension.shared().delegate as? HealthStoreProvider{
            healthStore = healthStoreProvider.healthStore
            
            loadCalories()
            
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
        if let restingCalories = restingCaloriesTotal, let activeCalories = activeCalories, let caloriesConsumed = caloriesConsumed{
            restingCaloriesLabel.setText(String(restingCalories/7))
            activeCaloriesLabel.setText(String(activeCalories))
            caloriesConsumedLabel.setText(String(caloriesConsumed))
            
            let calories = (restingCalories/7) + activeCalories - caloriesConsumed
            
            if var myDelegate = WKExtension.shared().delegate as? CaloriesForComplications{
                myDelegate.calories = calories
            }
            
            totalCaloriesLabel.setText(String(calories))
            updateCaloriesCallback?(calories)
        }else{
            updateCaloriesCallback?(0)
        }
        self.updateCaloriesCallback = nil
        let server = CLKComplicationServer.sharedInstance()
        guard let complications = server.activeComplications else {
            return
        }
        
        guard complications.count>0 else {
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

extension InterfaceController:UpdateCaloriesInBackground{
    func updateCalories(loadCompleteHandler:@escaping(_ calories:Int)->Void){
        
        updateCaloriesCallback = loadCompleteHandler
        
        loadCalories()
    }
}
