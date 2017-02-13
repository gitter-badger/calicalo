//
//  ComplicationController.swift
//  Calories In Calories Out Watch Extension
//
//  Created by Ryan Klein on 1/17/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
        
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        //handler([.forward, .backward])
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        let myDelegate = WKExtension.shared().delegate as? CalorieDataContainer
        guard let calorieData = myDelegate?.calorieData, let restingCalories = calorieData.restingCaloriesAverage, let activeCalories = calorieData.activeCalories, let caloriesConsumed = calorieData.caloriesConsumed, let netCalories = calorieData.netCalories else {
            handler(nil)
            return
        }
        
        var entry : CLKComplicationTimelineEntry?
        let now = Date()
        
        
        if complication.family == .utilitarianSmall{
            let textTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            textTemplate.textProvider = CLKSimpleTextProvider(text: String(netCalories))
            textTemplate.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
            textTemplate.imageProvider?.tintColor = Colors.orange
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: textTemplate)
            handler(entry)
        }
        else if complication.family == .modularSmall{
            let line2Text = "kCal"
            let textTemplate = CLKComplicationTemplateModularSmallStackText()
            textTemplate.line1TextProvider = CLKSimpleTextProvider(text:String(netCalories))
            textTemplate.line1TextProvider.tintColor = Colors.orange
            textTemplate.line2TextProvider = CLKSimpleTextProvider(text: line2Text)
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: textTemplate)
            handler(entry)

        }
        else if complication.family == .circularSmall{
            let line2Text = "kCal"
            let textTemplate = CLKComplicationTemplateCircularSmallStackText()
            textTemplate.line1TextProvider = CLKSimpleTextProvider(text:String(netCalories))
            textTemplate.line1TextProvider.tintColor = Colors.orange
            textTemplate.line2TextProvider = CLKSimpleTextProvider(text: line2Text)
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: textTemplate)
            handler(entry)
        }
        else if complication.family == .modularLarge{
            let columnTemplate = CLKComplicationTemplateModularLargeColumns()
            
           
            columnTemplate.row1Column1TextProvider = CLKSimpleTextProvider(text: "Out")
            columnTemplate.row1Column1TextProvider.tintColor = UIColor.green
            columnTemplate.row1Column2TextProvider = CLKSimpleTextProvider(text: "\(restingCalories+activeCalories) kCal")
            
            columnTemplate.row2Column1TextProvider = CLKSimpleTextProvider(text: "In")
            
            if(netCalories>0){
                columnTemplate.row2Column1TextProvider.tintColor = UIColor.cyan
            }
            else{
                columnTemplate.row2Column1TextProvider.tintColor = UIColor.red
            }
            
            columnTemplate.row2Column2TextProvider = CLKSimpleTextProvider(text: "\(caloriesConsumed) kCal")
            
            columnTemplate.row3Column1TextProvider = CLKSimpleTextProvider(text:"Net")
            columnTemplate.row3Column1TextProvider.tintColor = Colors.orange
            columnTemplate.row3Column2TextProvider = CLKSimpleTextProvider(text: "\(netCalories) kCal")
            
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: columnTemplate)
            handler(entry)
            
        }
        else if complication.family == .utilitarianLarge{
            let textTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            textTemplate.textProvider = CLKSimpleTextProvider(text: "\(restingCalories + activeCalories)-\(caloriesConsumed) = \(netCalories)")
            textTemplate.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
            textTemplate.imageProvider?.tintColor = Colors.orange
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: textTemplate)
            handler(entry)
        }
        else if complication.family == .extraLarge{
            let line2Text = "kCal"
            let textTemplate = CLKComplicationTemplateExtraLargeStackText()
            textTemplate.line1TextProvider = CLKSimpleTextProvider(text:String(netCalories))
            textTemplate.line1TextProvider.tintColor = Colors.orange
            textTemplate.line2TextProvider = CLKSimpleTextProvider(text: line2Text)
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: textTemplate)
            handler(entry)
        }
        else{
            handler(nil)
        }
        
        
        
    }
    
    func formatString(data:Int) -> String{
        
        var text = ""
        
        if data > 999 || data < -999{
            let caloriesDouble = Double(data)/1000
            let number = NSNumber(floatLiteral: caloriesDouble)
            
            let numberFormatter = NumberFormatter()
            
            numberFormatter.maximumSignificantDigits = 2
            numberFormatter.minimumSignificantDigits = 2
            
            if let formattedNumber = numberFormatter.string(from: number){
                text = formattedNumber+"K"
            }
        }
        else{
            text = String(data)
        }
        
        return text

    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        if complication.family == .utilitarianSmall{
            let text = "1234"
            let textTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            textTemplate.textProvider = CLKSimpleTextProvider(text: text)
            textTemplate.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
            textTemplate.imageProvider?.tintColor = Colors.orange
            handler(textTemplate)
        }
        else if complication.family == .modularSmall{
            let line1Text = "1234"
            let line2Text = "kCal"
            let textTemplate = CLKComplicationTemplateModularSmallStackText()
            textTemplate.line1TextProvider = CLKSimpleTextProvider(text:line1Text)
            textTemplate.line1TextProvider.tintColor = Colors.orange
            textTemplate.line2TextProvider = CLKSimpleTextProvider(text: line2Text)
            handler(textTemplate)
        }
        else if complication.family == .modularLarge{
            let headerText = "kCal"
            let bodyText = "1234"
            let textTemplate = CLKComplicationTemplateModularLargeTallBody()
            textTemplate.headerTextProvider = CLKSimpleTextProvider(text: headerText)
            textTemplate.headerTextProvider.tintColor = Colors.orange
            textTemplate.bodyTextProvider = CLKSimpleTextProvider(text: bodyText)
            textTemplate.bodyTextProvider.tintColor = Colors.orange
            handler(textTemplate)
            
        }
        else if complication.family == .circularSmall{
            let line1Text = "1234"
            let line2Text = "kCal"
            let textTemplate = CLKComplicationTemplateCircularSmallStackText()
            textTemplate.line1TextProvider = CLKSimpleTextProvider(text:line1Text)
            textTemplate.line1TextProvider.tintColor = Colors.orange
            textTemplate.line2TextProvider = CLKSimpleTextProvider(text: line2Text)
            handler(textTemplate)
        }
        else if complication.family == .utilitarianLarge{
            let text = "-500 + 2000 = 500 cKal"
            let textTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            textTemplate.textProvider = CLKSimpleTextProvider(text: text)
            textTemplate.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
            textTemplate.imageProvider?.tintColor = Colors.orange
            handler(textTemplate)
        }
        else if complication.family == .extraLarge{
            let line1Text = "1234"
            let line2Text = "kCal"
            let textTemplate = CLKComplicationTemplateExtraLargeStackText()
            textTemplate.line1TextProvider = CLKSimpleTextProvider(text:line1Text)
            textTemplate.line1TextProvider.tintColor = Colors.orange
            textTemplate.line2TextProvider = CLKSimpleTextProvider(text: line2Text)
            handler(textTemplate)

        }
        else {
            handler(nil)
        }
        
        
       
    }
    
}
