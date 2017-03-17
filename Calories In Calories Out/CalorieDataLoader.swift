//
//  CalorieDataLoader.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 1/17/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation
import HealthKit


protocol CalorieDataLoader:class {
    
    var healthStore:HKHealthStore?{
        get
    }
    
    var basalEnergyType:HKQuantityType? {
        get
        
    }
    var activeEnergyType:HKQuantityType? {
        get
        
    }
    var caloriesConsumedType:HKQuantityType? {
        get
        
    }
    var dispatchGroup:DispatchGroup{
        get
    }
    var calorieData:CalorieData?{
        get set
    }
    var unit:String?{
        get
    }
       
    func loadCalories()
    func allDone()
    func willLoadCalories()
}
extension CalorieDataLoader{
    
    func loadCalories(){
        if let healthStore = healthStore{
            
            guard let basalEnergyType = basalEnergyType, let activeEnergyType = activeEnergyType, let caloriesConsumedType = caloriesConsumedType else{
                fatalError("Unknown HKQuantityTypes")
            }
            
            healthStore.requestAuthorization(toShare: nil, read: [basalEnergyType, activeEnergyType, caloriesConsumedType]){
                succcess, error in
                if succcess {
                    self.calorieData = CalorieData()
                    DispatchQueue.main.sync {
                        self.willLoadCalories()
                    }
                    self.dispatchGroup.enter()
                    self.averageOfPrevious7Days(for: self.basalEnergyType, healthStore: healthStore)
                    self.dispatchGroup.enter()
                    self.getCummulativeSum(for: self.activeEnergyType, healthStore: healthStore)
                    self.dispatchGroup.enter()
                    self.getCummulativeSum(for: self.caloriesConsumedType, healthStore: healthStore)
                    self.dispatchGroup.notify(queue: DispatchQueue.main, execute: self.allDone)
                }
                else{
                    fatalError("Unable to read data")
                    
                }
            }
        }

    }
    
    func getCummulativeSum(for type:HKQuantityType!, healthStore:HKHealthStore!){
        let calendar = NSCalendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        
        guard let startDate = calendar.date(from: components), let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else{
            fatalError("Failed date sateup")
        }
        
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let statsQuery = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum){
            query, results, error in
            
            defer {
                self.dispatchGroup.leave()
            }
            
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            
            guard results != nil else {
                fatalError("No results found in queries")
            }
            
            var calories = 0.0
            
            if let results = results{
                guard let activeEnergyType = self.activeEnergyType, let caloriesConsumedType = self.caloriesConsumedType else{
                    fatalError("Unknown HKQuantityTypes")
                }

                if let quantity = results.sumQuantity(){
                    
                    var unitForCalculation:HKUnit
                    
                    if(self.unit == nil || self.unit == "calories"){
                        unitForCalculation = HKUnit.kilocalorie()
                    }
                    else{
                        unitForCalculation = HKUnit.jouleUnit(with: .kilo)
                    }
                    
                    calories = quantity.doubleValue(for: unitForCalculation)
                    
                    
                    switch type {
                    case activeEnergyType:
                        self.calorieData?.activeCalories = Int(calories)
                    case caloriesConsumedType:
                        self.calorieData?.caloriesConsumed = Int(calories)
                    default:
                        fatalError("Attempted to get cummulative sum for undefined type")
                        
                    }
                    
                    
                }
                else{
                    switch type {
                        case activeEnergyType:
                        self.calorieData?.activeCalories = 0
                        case caloriesConsumedType:
                        self.calorieData?.caloriesConsumed = 0
                        default:
                        fatalError("Attempted to get cummulative sum for undefined type")
                        
                    }

                }

            }
            else{
                fatalError("No data to sum")
            }
            
            
        }
        
        healthStore.execute(statsQuery)
    }
    
    func averageOfPrevious7Days(for type:HKQuantityType!, healthStore:HKHealthStore!){
        let calendar = NSCalendar.current
        var interval = DateComponents()
        interval.day = 1
        
        var anchorComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        
        anchorComponents.day = anchorComponents.day! - 1
        
        guard  let yesterday = calendar.date(from: anchorComponents) else {
            fatalError("Couldn't parse date")
        }
        
        let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: yesterday, intervalComponents: interval)
        
        
        query.initialResultsHandler = {
            query, results, error in
            defer {
                self.dispatchGroup.leave()
            }
            guard let statsCollection = results else {
                fatalError("Couldn't collect stats")
            }
            
            guard let startDate = calendar.date(byAdding: .day, value: -6, to: yesterday) else{
                fatalError("Couldn't parse date")
            }
            
            
            self.calorieData?.restingCaloriesTotal = 0
            var total = 0
            statsCollection.enumerateStatistics(from: startDate, to: yesterday){
                statistics, stop in
                if let sum = statistics.sumQuantity() {
                    var unitForCalculation:HKUnit
                    
                    if(self.unit == nil || self.unit == "calories"){
                        unitForCalculation = HKUnit.kilocalorie()
                    }
                    else{
                        unitForCalculation = HKUnit.jouleUnit(with: .kilo)
                    }

                    let calories = sum.doubleValue(for: unitForCalculation)
                    total = total + Int(calories)
                    
                }
            }
            self.calorieData?.restingCaloriesTotal = total
        }
        
        healthStore.execute(query)
        
        
    }

}
