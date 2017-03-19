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
    
    var unit:String?
    
    private var calorieData:CalorieData?
    
    init(healthStore:HKHealthStore){
        self.healthStore = healthStore
    }
    
    func loadCalories() -> CalorieData?{
        unit = UserDefaults.standard.string(forKey: "com.base11studios.cico.unit")
        if unit == nil{
            unit = "calories"
        }
        if let healthStore = healthStore{
            
            calorieData = CalorieData()
            
            guard let basalEnergyType = basalEnergyType, let activeEnergyType = activeEnergyType, let caloriesConsumedType = caloriesConsumedType else{
                fatalError("Unknown HKQuantityTypes")
            }
            
            healthStore.requestAuthorization(toShare: nil, read: [basalEnergyType, activeEnergyType, caloriesConsumedType]){
                [weak self]succcess, error in
                if succcess {
                    self?.dispatchGroup.enter()
                    self?.averageOfPrevious7Days(for: self?.basalEnergyType, healthStore: healthStore)
                    self?.dispatchGroup.enter()
                    self?.getCummulativeSum(for: self?.activeEnergyType, healthStore: healthStore)
                    self?.dispatchGroup.enter()
                    self?.getCummulativeSum(for: self?.caloriesConsumedType, healthStore: healthStore)
                    self?.dispatchGroup.enter()
                    self?.getSamples(for: self?.caloriesConsumedType, healthStore: healthStore)
                    self?.dispatchGroup.notify(queue: DispatchQueue.global()){
                        self?.semaphore.signal()
                    }
                    
                }
                else{
                    //Authorization failed. This can happen even if user has previously accepted
                    self?.calorieData = nil
                    self?.dispatchGroup.notify(queue: DispatchQueue.global()){
                        self?.semaphore.signal()
                    }
                    
                    
                }
            }
        }
        else{
            //Shouldn't be here if healthStore isn't initiated, but handle it anyway
            calorieData = nil
            semaphore.signal()
        }
        semaphore.wait()
        return calorieData
        
    }
    
    func getSamples(for type:HKQuantityType!, healthStore:HKHealthStore!){
        let calendar = NSCalendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        
        guard let startDate = calendar.date(from: components), let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else{
            fatalError("Failed date sateup")
        }
        
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil){
            query, results, error in
            
            defer{
                self.dispatchGroup.leave()
            }
            
            guard error == nil else{
                return
            }
            
            guard let samples = results else {
                return
            }
            
            for sample in samples{
                print(sample.sampleType)
            }

            
            
        }
        
        healthStore.execute(query)
        
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
                return
            }
            
            guard results != nil else {
                return
            }
            
            var calories = 0.0
            
            if let results = results{
                guard let activeEnergyType = self.activeEnergyType, let caloriesConsumedType = self.caloriesConsumedType else{
                    return
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
                        return
                        
                    }
                    
                    
                }
                else{
                    switch type {
                    case activeEnergyType:
                        self.calorieData?.activeCalories = 0
                    case caloriesConsumedType:
                        self.calorieData?.caloriesConsumed = 0
                    default:
                        return
                        
                    }
                    
                }
                
            }
            else{
                return
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
            return
        }
        
        let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: yesterday, intervalComponents: interval)
        
        
        query.initialResultsHandler = {
            query, results, error in
            defer {
                self.dispatchGroup.leave()
            }
            guard error == nil else{
                return
            }
            guard let statsCollection = results else {
                return
            }
            
            guard let startDate = calendar.date(byAdding: .day, value: -6, to: yesterday) else{
                return
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
