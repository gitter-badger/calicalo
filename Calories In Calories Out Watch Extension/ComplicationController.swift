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
        
        let myDelegate = WKExtension.shared().delegate as? CaloriesForCaomplications
        guard let data = myDelegate?.calories else {
            handler(nil)
            return
        }
        
        var entry : CLKComplicationTimelineEntry?
        let now = Date()
        var longText = String()
        
        
        if complication.family == .circularSmall{
            
            if data > 999 || data < -999{
                let caloriesDouble = Double(data)/1000
                let number = NSNumber(floatLiteral: caloriesDouble)
                
                let numberFormatter = NumberFormatter()
                
                numberFormatter.maximumSignificantDigits = 2
                numberFormatter.minimumSignificantDigits = 2
                
                if let formattedNumber = numberFormatter.string(from: number){
                    longText = formattedNumber+"K"
                }
                
                
            }
            else{
                longText = String(data)
            }
            
            let textTemplate = CLKComplicationTemplateCircularSmallSimpleText()
            textTemplate.textProvider = CLKSimpleTextProvider(text: longText)
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: textTemplate)
            handler(entry)
        }
        /*if complication.family == .utilitarianSmall{
            longText = String(data)
            let textTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            textTemplate.textProvider = CLKSimpleTextProvider(text: longText)
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: textTemplate)
            handler(entry)
            
        }*/
        handler(nil)
        
        
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
        
        if complication.family == .circularSmall{
            let longText =  "1000K"
            let shortText = "1.1K"
            let textTemplate = CLKComplicationTemplateCircularSmallSimpleText()
            textTemplate.textProvider = CLKSimpleTextProvider(text: longText, shortText: shortText)
            handler(textTemplate)
        }
        /*if complication.family == .utilitarianSmall{
            let text = "1234"
            let textTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            textTemplate.textProvider = CLKSimpleTextProvider(text: text)
            handler(textTemplate)
        }*/
        
        handler(nil)
        
       
    }
    
}
