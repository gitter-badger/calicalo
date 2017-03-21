//
//  CalorieData.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 2/4/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation
import HealthKit


struct CalorieData {
    var restingCaloriesTotal:Int?
    var activeCalories:Int?
    var caloriesConsumed:Int?
    var restingCaloriesAverage:Int?{
        
        guard let restingCaloriesTotal = restingCaloriesTotal else {
            return nil
        }
        
        return restingCaloriesTotal/7
    }
    var netCalories:Int?{
        
        guard let restingCaloriesAverage = restingCaloriesAverage, let activeCalories = activeCalories, let caloriesConsumed = caloriesConsumed else{
            return nil
        }
        
        return restingCaloriesAverage + activeCalories - caloriesConsumed
    }
    var samples:[HKQuantitySample]?
    
}
