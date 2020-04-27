//
//  OfflineViewController.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/24/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import UIKit
import Reachability

class OfflineViewController: UIViewController {

    var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachability!.whenReachable = {_ in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
