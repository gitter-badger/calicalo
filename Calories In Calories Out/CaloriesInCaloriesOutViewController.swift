//
//  CaloriesInCaloriesOutViewController.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 9/25/16.
//  Copyright © 2016 Base11 Studios. All rights reserved.
//

import Foundation
import UIKit
import HealthKit


class CaloriesInCaloriesOutViewController : UITableViewController{
    

    
    @IBOutlet weak var restingCaloriesLabel: UILabel!
    @IBOutlet weak var activeCaloriesLabel: UILabel!
    @IBOutlet weak var caloriesConsumedLabel: UILabel!
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    
    var healthStore:HKHealthStore?
    
    let dispatchGroup:DispatchGroup = DispatchGroup()
    
    let basalEnergyType = HKQuantityType.quantityType(forIdentifier:.basalEnergyBurned)
    
    let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
    
    let caloriesConsumedType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)
    
    var calorieData:CalorieData? = CalorieData()
    
    override func viewDidLoad() {
        
        refreshControl?.tintColor = UIColor(red: 1, green: 145/255, blue: 0, alpha: 1)
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo-txt-white"))
        
        if let healthStoreProvider = UIApplication.shared.delegate as? HealthStoreProvider{
            healthStore = healthStoreProvider.healthStore
            
            loadCalories()
            
            
        }
        
    }
    
        
    
    func refreshTouched(_ sender: Any) {
        if let healthStoreProvider = UIApplication.shared.delegate as? HealthStoreProvider{
            healthStore = healthStoreProvider.healthStore
            
            loadCalories()
            
        }
    }
    @IBAction func beginRefresh(_ sender: Any) {
        
        if refreshControl?.isRefreshing == true{
            loadCalories()
        }
    }
    
}



extension CaloriesInCaloriesOutViewController:CalorieDataLoader{
    func allDone(){
        if self.refreshControl?.isRefreshing == true{
            self.refreshControl?.endRefreshing()
        }
        if let calorieData = calorieData, let restingCalories = calorieData.restingCaloriesAverage , let activeCalories = calorieData.activeCalories, let caloriesConsumed = calorieData.caloriesConsumed, let netCalories = calorieData.netCalories{
            restingCaloriesLabel.text = String(restingCalories)
            activeCaloriesLabel.text = String(activeCalories)
            caloriesConsumedLabel.text = String(caloriesConsumed)
            totalCaloriesLabel.text = String((netCalories))
        }
    }
    
    func willLoadCalories(){
        
        let loadingString = "..."
        
        restingCaloriesLabel.text = loadingString
        activeCaloriesLabel.text = loadingString
        caloriesConsumedLabel.text = loadingString
        totalCaloriesLabel.text = loadingString
    }

}
