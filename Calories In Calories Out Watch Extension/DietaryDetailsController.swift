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
            let unit = UserDefaults.standard.string(forKey: "com.base11studios.cico.unit")
            var unitForCalculation:HKUnit
            var unitSuffix:String
            if(unit == nil || unit == "calories"){
                unitForCalculation = HKUnit.kilocalorie()
                unitSuffix = "kCal"
            }
            else{
                unitForCalculation = HKUnit.jouleUnit(with: .kilo)
                unitSuffix = "kj"
            }

            
            dietaryDetailsTable.setNumberOfRows(samples.count, withRowType: "dietaryDetailsRow")
            let samplesFromDefaults = UserDefaults.standard.dictionary(forKey: "com.base11studios.cico.samples") as? [String:Bool]
            
            for (index, sample) in samples.enumerated(){
                
                let rowController = dietaryDetailsTable.rowController(at: index) as? DietaryDetailsRow
                
                rowController?.sourceLabel.setText("\(sample.sourceRevision.source.name)")
                rowController?.caloriesLabel.setText("\(Int(sample.quantity.doubleValue(for:unitForCalculation))) \(unitSuffix)")
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Calendar.current.locale
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                
                rowController?.timestamp.setText(dateFormatter.string(from: sample.startDate))
                
                if let sampleFromDefault = samplesFromDefaults?[sample.uuid.uuidString]{
                    rowController?.showing = sampleFromDefault
                }
                else{
                    rowController?.showing = true
                }
                
                rowController?.uuid = sample.uuid
                
            }
            
        }
        
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if let rowController = dietaryDetailsTable.rowController(at: rowIndex) as? DietaryDetailsRow{
            rowController.showing = !rowController.showing
            
        }
        
    }
    
    @IBAction func reloadTapped() {
        
        var newShowHidePreferences = [String:Bool]()
        
        for index in 0...dietaryDetailsTable.numberOfRows{
            if let rowController = dietaryDetailsTable.rowController(at: index) as? DietaryDetailsRow, let uuid = rowController.uuid{
                newShowHidePreferences[uuid.uuidString] = rowController.showing
            }
            
        }
        
        UserDefaults.standard.set(newShowHidePreferences, forKey: "com.base11studios.cico.samples")
        UserDefaults.standard.synchronize()
        
        InterfaceController.reloadRootControllers(withNames: ["landingInterfaceController"], contexts: [false])
        
    }
    
}
