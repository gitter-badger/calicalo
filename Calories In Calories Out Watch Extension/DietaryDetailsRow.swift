//
//  DietaryDetails.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 3/18/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation
import UIKit
import WatchKit


class DietaryDetailsRow:NSObject{
    @IBOutlet var sourceLabel: WKInterfaceLabel!
    @IBOutlet var caloriesLabel: WKInterfaceLabel!
    @IBOutlet var rootGroup: WKInterfaceGroup!
    @IBOutlet var timestamp: WKInterfaceLabel!
    
    var showing:Bool = true{
        didSet{
            if showing{
                rootGroup.setBackgroundColor(Colors.orange)
            }
            else{
                rootGroup.setBackgroundColor(UIColor.clear)
            }
        }
    }
    
    var uuid:UUID?
    
}
