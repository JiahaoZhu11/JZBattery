//
//  ViewController.swift
//  JZBattery
//
//  Created by 朱嘉皓 on 12/11/2020.
//  Copyright (c) 2020 朱嘉皓. All rights reserved.
//

import UIKit
import JZBattery

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let battery = JZBatteryView()
        battery.frame.size = CGSize(width: 100, height: 100)
        battery.center = view.center
        view.addSubview(battery)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

