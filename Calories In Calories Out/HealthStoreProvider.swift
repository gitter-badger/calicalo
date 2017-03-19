//
//  HealthKitProvider.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 1/18/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation
import HealthKit

protocol HealthStoreProvider {
    var healthStore:HKHealthStore?{
        get set
    }
}
