//
//  DietaryDetailsController.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 3/18/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation
import WatchKit
import HealthKit

class DietaryDetailsController:WKInterfaceController{
    @IBOutlet var dietaryDetailsTable: WKInterfaceTable!
    
    
    override func awake(withContext context: Any?) {
        
        if let calorieData = context as? CalorieData, let samples = calorieData.samples{
            
            dietaryDetailsTable.setNumberOfRows(samples.count, withRowType: "dietaryDetailsRow")
            
            for (index, sample) in samples.enumerated(){
                
                let rowController = dietaryDetailsTable.rowController(at: index) as? DietaryDetailsRow
                rowController?.sourceLabel.setText(sample.sourceRevision.source.name)
                rowController?.caloriesLabel.setText("\(Int(sample.quantity.doubleValue(for:HKUnit.kilocalorie())))")
                
            }
            
        }
        
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if let rowController = dietaryDetailsTable.rowController(at: rowIndex) as? DietaryDetailsRow{
            rowController.showing = !rowController.showing
        }
        
    }
    
    
}
