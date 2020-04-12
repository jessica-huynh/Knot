//
//  GettingStartedViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-04-07.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class GettingStartedViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let parent = parent as? LaunchViewController {
            parent.statusBarStyle = .lightContent
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessfulLinking(_:)), name: .successfulLinking, object: nil)
    }
    

    @IBAction func gettingStartedTapped(_ sender: Any) {
        presentPlaidLink()
    }
    
    func showHomePage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Home")
        
        viewController.view.frame = view.frame
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    @objc func onSuccessfulLinking(_ notification:Notification) {
        NotificationCenter.default.removeObserver(self)
        if let parent = parent as? LaunchViewController {
            parent.statusBarStyle = .default
        }
        showHomePage()
        UserDefaults.standard.set(false, forKey: "isFirstLinking")
    }

}
