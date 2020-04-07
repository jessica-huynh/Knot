//
//  LaunchViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-04-07.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let isFirstLinking = UserDefaults.standard.bool(forKey: "isFirstLinking")
        let viewController = isFirstLinking ?
            storyboard.instantiateViewController(withIdentifier: "GettingStarted") :
            storyboard.instantiateViewController(withIdentifier: "Home")
        
        viewController.view.frame = view.frame
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        if !isFirstLinking { StorageManager.instance.fetchData() }
    }

}
