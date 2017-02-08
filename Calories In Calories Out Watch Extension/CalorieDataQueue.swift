//
//  CalorieDataQueue.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 2/7/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation


protocol CalorieDataQueue {
    var calorieData:CalorieData?{
        get set
    }
    func getCalorieDataQueue() -> DispatchQueue?
    func getCalorieDataLoader() -> SynchronousCalorieDataLoader?
}
