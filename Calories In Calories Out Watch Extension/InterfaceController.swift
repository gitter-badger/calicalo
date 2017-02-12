//
//  InterfaceController.swift
//  Calories In Calories Out Watch Extension
//
//  Created by Ryan Klein on 1/17/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController, CalorieDataProperty {
    @IBOutlet var totalCaloriesLabel: WKInterfaceLabel!
    @IBOutlet var activeCaloriesLabel: WKInterfaceLabel!
    @IBOutlet var caloriesConsumedLabel: WKInterfaceLabel!
    @IBOutlet var restingCaloriesLabel: WKInterfaceLabel!
    @IBOutlet var calorieGraph: WKInterfaceImage!
    
    var calorieData:CalorieData?{
        didSet{
            if let calorieData = calorieData, let restingCalories = calorieData.restingCaloriesAverage, let activeCalories = calorieData.activeCalories, let caloriesConsumed = calorieData.caloriesConsumed, let netCalories = calorieData.netCalories {
                restingCaloriesLabel.setText(String(restingCalories))
                activeCaloriesLabel.setText(String(activeCalories))
                caloriesConsumedLabel.setText(String(caloriesConsumed))
                totalCaloriesLabel.setText(String(netCalories))
                
                let totalBarWidth = 120
                var barWidth = abs(netCalories / (restingCalories + activeCalories)) * totalBarWidth
                
                let image: UIImage = UIImage()
                // begin a graphics context of sufficient size
                UIGraphicsBeginImageContext(CGSize(width: totalBarWidth, height: 75))
                
                // draw original image into the context
                image.draw(at: CGPoint.zero)
                
                // get the context for CoreGraphics
                let context = UIGraphicsGetCurrentContext()
                
                // set stroking width and color of the context
                context!.setLineWidth(1.0)
                context!.setStrokeColor(UIColor.blue.cgColor)
                
                var barStartPosition = 0
                
                if netCalories > 0 {
                    context!.setFillColor(UIColor.yellow.cgColor)
                    barStartPosition = totalBarWidth / 2
                } else {
                    context!.setFillColor(UIColor.blue.cgColor)
                    barStartPosition = totalBarWidth / 2 - barWidth
                }
                
                context!.addRect(CGRect(x: barStartPosition, y: 0, width: barWidth, height: 75))
                
                // apply the stroke to the context
                context!.strokePath()
                
                // get the image from the graphics context 
                let resultImage = UIGraphicsGetImageFromCurrentImageContext()
                
                // end the graphics context 
                UIGraphicsEndImageContext()
                
                calorieGraph.setImage(resultImage)
            }
        }
    }


    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if var delegate = WKExtension.shared().delegate as? CalorieDataContainer, let dispatchQueue = delegate.getCalorieDataQueue(){
            dispatchQueue.async {
                self.calorieData = delegate.getCalorieDataLoader()?.loadCalories()
                delegate.calorieData = self.calorieData
                
                let server = CLKComplicationServer.sharedInstance()
                guard let complications = server.activeComplications, complications.count > 0 else {
                    return
                }
                server.reloadTimeline(for: complications[0])
                
                WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeInterval: 60, since: Date()), userInfo: nil){
                    error in
                    if let error = error{
                        fatalError(error.localizedDescription)
                    }
                }
                
            }

        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
