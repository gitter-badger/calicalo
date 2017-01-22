//
//  UpdateCaloriesInBackground.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 1/19/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation

protocol UpdateCaloriesInBackground {
    
    var updateCaloriesCallback:((_ calories:Int)->Void)?{
        get set
    }
    
    func updateCalories(loadCompleteHandler:@escaping(_ calories:Int)->Void)
    
    
}
