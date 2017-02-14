//
//  SynchronousCalorieCounter.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 2/5/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation
import HealthKit


class SynchronousCalorieDataLoader{
    
    let healthStore:HKHealthStore!
    
    let dispatchGroup = DispatchGroup()
    
    let semaphore = DispatchSemaphore(value: 0)
    
    let basalEnergyType = HKQuantityType.quantityType(forIdentifier:.basalEnergyBurned)
    
    let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
    
    let caloriesConsumedType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)
    
    private var calorieData:CalorieData?
    
    init(healthStore:HKHealthStore){
        self.healthStore = healthStore
    }
    
    func loadCalories() -> CalorieData?{
        if let healthStore = healthStore{
            
            calorieData = CalorieData()
            
            guard let basalEnergyType = basalEnergyType, let activeEnergyType = activeEnergyType, let caloriesConsumedType = caloriesConsumedType else{
                fatalError("Unknown HKQuantityTypes")
            }
            
            healthStore.requestAuthorization(toShare: nil, read: [basalEnergyType, activeEnergyType, caloriesConsumedType]){
                succcess, error in
                if succcess {
                    self.dispatchGroup.enter()
                    self.averageOfPrevious7Days(for: self.basalEnergyType, healthStore: healthStore)
                    self.dispatchGroup.enter()
                    self.getCummulativeSum(for: self.activeEnergyType, healthStore: healthStore)
                    self.dispatchGroup.enter()
                    self.getCummulativeSum(for: self.caloriesConsumedType, healthStore: healthStore)
                    self.dispatchGroup.notify(queue: DispatchQueue.global()){
                        self.semaphore.signal()
                    }
                    
                }
                else{
                    fatalError("Unable to read data")
                    
                }
            }
        }
        else{
            fatalError("health store is not available")
        }
        semaphore.wait()
        return calorieData
        
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
                if let error = error as? NSError{
                    let healthError = HKError(_nsError: error)
                    if healthError.code == HKError.errorDatabaseInaccessible{
                        return
                    }
                }

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
                    let unit = HKUnit.kilocalorie()
                    calories = quantity.doubleValue(for: unit)
                    
                    
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
            guard error == nil else{
                
                if let error = error as? NSError{
                    let healthError = HKError(_nsError: error)
                    if healthError.code == HKError.errorDatabaseInaccessible{
                        return
                    }
                }
                
                fatalError(error!.localizedDescription)
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
                    let unit = HKUnit.kilocalorie()
                    let calories = sum.doubleValue(for: unit)
                    total = total + Int(calories)
                    
                }
            }
            self.calorieData?.restingCaloriesTotal = total
        }
        
        healthStore.execute(query)
        
        
    }

    
    
    
    
    
}
