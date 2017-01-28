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
        
        let myDelegate = WKExtension.shared().delegate as? CaloriesForComplications
        guard let data = myDelegate?.calories else {
            handler(nil)
            return
        }
        
        var entry : CLKComplicationTimelineEntry?
        let now = Date()
        let text = String(data)
        
        if complication.family == .utilitarianSmall{
            let textTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            textTemplate.textProvider = CLKSimpleTextProvider(text: text)
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
            //textTemplate.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
            handler(textTemplate)
        }
        else {
            handler(nil)
        }
        
        
       
    }
    
}
