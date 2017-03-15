//
//  SettingsViewController.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 3/12/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity


class SettingsViewController : UITableViewController{
    
    
    @IBOutlet weak var unitsSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        unitsSegmentedControl.addTarget(self, action: #selector(SettingsViewController.segmentChanged), for: .valueChanged)
        
        let unit = UserDefaults.standard.string(forKey: "com.base11studios.cico.unit")
        
        if(unit == "calories"){
            unitsSegmentedControl.selectedSegmentIndex = 0
        }
        else{
            unitsSegmentedControl.selectedSegmentIndex = 1
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = Colors.orange
        navigationController?.navigationBar.barTintColor = Colors.orange
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        super.viewWillAppear(animated)
    }

    
    func segmentChanged(){
        
        var session:WCSession?
        
        if let sessionProvider = UIApplication.shared.delegate as? WCSessionProvider{
            session = sessionProvider.session
        }
        
        if unitsSegmentedControl.selectedSegmentIndex == 0 {
            UserDefaults.standard.set("calories", forKey:"com.base11studios.cico.unit")
            if let session = session{
                sendUnit(session, unit: "calories")
            }
            
        }
        else{
            UserDefaults.standard.set("joules", forKey:"com.base11studios.cico.unit")
            if let session = session{
                sendUnit(session, unit: "joules")
            }
        }
        UserDefaults.standard.synchronize()
    }
    
    private func sendUnit(_ session:WCSession, unit:String){
        if #available(iOS 9.3, *) {
            if session.activationState == .activated && session.isPaired && session.isWatchAppInstalled{
                session.transferUserInfo(["unit":unit])
            }
        } else {
            if session.isPaired && session.isWatchAppInstalled{
                session.transferUserInfo(["unit":unit])
            }
        }

    }
    
}
