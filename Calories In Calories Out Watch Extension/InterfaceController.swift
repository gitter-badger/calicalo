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
                calorieGraph.setImage(getNetMeterImage(restingCalories: restingCalories, activeCalories: activeCalories, netCalories: netCalories))
            }
        }
    }
    
    func getNetMeterImage(restingCalories: Int, activeCalories: Int, netCalories: Int) -> UIImage {
        let totalBarWidth: Double = Double(WKInterfaceDevice.current().screenBounds.width)
        let totalImageHeight: Int = Int(Double(WKInterfaceDevice.current().screenBounds.height) / 4)
        var frameOfReferenceCalories = restingCalories + activeCalories
        
        /*
         TODO.
                1. Make bar only go to ~90% of screen width so 100% bar is not touching sides of watch
                2. Figure out better solution for resting + active calories being 0 instead of default to 2000 grid
        */
        
        if frameOfReferenceCalories == 0 {
            frameOfReferenceCalories = 2000
        }
        
        let image: UIImage = UIImage()
        // begin a graphics context of sufficient size
        UIGraphicsBeginImageContext(CGSize(width: totalBarWidth, height: Double(totalImageHeight)))
        
        // draw original image into the context
        image.draw(at: CGPoint.zero)
        
        // get the context for CoreGraphics
        //Too many !'s make's me nervous and this makes the code a little cleaner
        //I don't know when this could happen, but if it does, this way we'll find out.
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("No graphics context")
        }
        
        let leftColor = UIColor(red: 63/255, green: 215/255, blue: 255/255, alpha: 1).cgColor
        let rightColor = UIColor(red: 251/255, green: 44/255, blue: 0/255, alpha: 1).cgColor
        let highlightColor = UIColor(red: 255/255, green: 214/255, blue: 0/255, alpha: 1).cgColor
        let middleColor = UIColor.white.cgColor
        let tickMarker: Double = 0.75
        let tickHighlightTolerance: Double = 0.04
        
        // Draw border rectangle 75% of screen
        if netCalories < 0 {
            // Draw left fill 0-LINE.
            context.setFillColor(leftColor)
            
            context.fill(CGRect(x: 0, y: totalImageHeight / 4, width: lround(totalBarWidth * tickMarker), height: totalImageHeight / 2))
            
            // Draw right fill LINE-Y
            context.setFillColor(rightColor)
            
            var barWidth: Int = lround(abs(Double(netCalories) / Double(frameOfReferenceCalories)) * (Double(totalBarWidth * (1-tickMarker))))
            if barWidth > lround(totalBarWidth * (1-tickMarker)) {
                barWidth = lround(totalBarWidth * (1-tickMarker))
            }
            
            context.fill(CGRect(x: lround(totalBarWidth * tickMarker), y: totalImageHeight / 4, width: barWidth, height: totalImageHeight / 2))
            
            // Draw right border
            context.setStrokeColor(rightColor)
            context.addRect(CGRect(x: lround(totalBarWidth * tickMarker), y: totalImageHeight / 4, width: lround(totalBarWidth * (1-tickMarker)), height: totalImageHeight / 2))
            context.strokePath()
            
        } else {
            // Draw left border 0-LINE
            context.setStrokeColor(leftColor)
            context.addRect(CGRect(x: 0, y: totalImageHeight / 4, width: lround(totalBarWidth * tickMarker), height: totalImageHeight / 2))
            context.strokePath()
            
            // Draw left fill 0-X
            context.setFillColor(leftColor)
            
            var barWidth: Int = lround((1 - abs(Double(netCalories) / Double(frameOfReferenceCalories))) * (Double(totalBarWidth * (tickMarker))))
            if barWidth > lround(totalBarWidth * (tickMarker)) {
                barWidth = lround(totalBarWidth * (tickMarker))
            }
            
            context.fill(CGRect(x: 0, y: totalImageHeight / 4, width: barWidth, height: totalImageHeight / 2))
            
            // Draw right border
            context.setStrokeColor(rightColor)
            context.addRect(CGRect(x: lround(totalBarWidth * tickMarker), y: totalImageHeight / 4, width: lround(totalBarWidth * (1-tickMarker)), height: totalImageHeight / 2))
            context.strokePath()
        }
        
        // Now draw center
        if abs(Double(netCalories) / Double(frameOfReferenceCalories)) <= tickHighlightTolerance {
            context.setFillColor(highlightColor)

            // Draw outline to make bigger
            context.setLineWidth(2.0)
            context.setStrokeColor(highlightColor)
            context.addRect(CGRect(x: lround(totalBarWidth * tickMarker) - lround(totalBarWidth * 0.02), y: totalImageHeight / 8, width: lround(totalBarWidth * 0.04), height: lround(Double(totalImageHeight) * 0.75)))
            context.strokePath()

        } else {
            context.setFillColor(middleColor)
        }
        context.fill(CGRect(x: lround(totalBarWidth * tickMarker) - lround(totalBarWidth * 0.02), y: totalImageHeight / 8, width: lround(totalBarWidth * 0.04), height: lround(Double(totalImageHeight) * 0.75)))

        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the graphics context
        UIGraphicsEndImageContext()
        
        return resultImage!
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
                for complication in complications{
                    server.reloadTimeline(for: complication)
                }
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
