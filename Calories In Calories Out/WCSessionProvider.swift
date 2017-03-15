//
//  WCSessionProvider.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 3/13/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol WCSessionProvider {
    var session:WCSession?{
        get
    }
}
