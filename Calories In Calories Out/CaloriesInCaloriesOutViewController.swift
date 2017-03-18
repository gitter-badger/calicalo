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
    
    var calorieData:CalorieData? = CalorieData()
    
    var synchronousCalorieDataLoader:SynchronousCalorieDataLoader?
    
    let calorieLoaderQueue = DispatchQueue(label: "com.base11studios.cico.queue")
    
    let loadingString = "..."
    
    override func viewDidLoad() {
        
        refreshControl?.tintColor = Colors.orange
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo-txt-white"))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        if let healthStoreProvider = UIApplication.shared.delegate as? HealthStoreProvider, let healthStore = healthStoreProvider.healthStore{
            synchronousCalorieDataLoader = SynchronousCalorieDataLoader(healthStore: healthStore)
            loadCaloriesInBackground()
            
            
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = Colors.orange
        navigationController?.navigationBar.barTintColor = Colors.orange
        super.viewWillAppear(animated)
    }
    
        
    
    @IBAction func beginRefresh(_ sender: Any) {
        
        if refreshControl?.isRefreshing == true{
            loadCaloriesInBackground()
        }
    }
    
    private func loadCaloriesInBackground(){
        self.willLoadCalories()
        calorieLoaderQueue.async {
            
            self.calorieData = self.synchronousCalorieDataLoader?.loadCalories()
            
            DispatchQueue.main.async {
                self.loadingCaloriesComplete()
            }
            
        }
        
        
    }
    
    
    private func willLoadCalories(){
        
        
        restingCaloriesLabel.text = loadingString
        activeCaloriesLabel.text = loadingString
        caloriesConsumedLabel.text = loadingString
        totalCaloriesLabel.text = loadingString
    }
    
    private func loadingCaloriesComplete(){
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
    
    
}

