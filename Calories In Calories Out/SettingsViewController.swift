//
//  SettingsViewController.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 3/12/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import Foundation
import UIKit


class SettingsViewController : UITableViewController{
    
    
    @IBOutlet weak var unitsSegmentedControl: UISegmentedControl!
    
    let defaults = UserDefaults(suiteName: "group.com.base11studios.cico")
    
    
    override func viewDidLoad() {
        unitsSegmentedControl.addTarget(self, action: #selector(SettingsViewController.segmentChanged), for: .valueChanged)
        
        let unit = defaults?.string(forKey: "com.base11studios.cico.unit")
        
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
        if unitsSegmentedControl.selectedSegmentIndex == 0 {
            defaults?.set("calories", forKey:"com.base11studios.cico.unit")
        }
        else{
            defaults?.set("joules", forKey:"com.base11studios.cico.unit")
        }
        defaults?.synchronize()
    }
    
}
