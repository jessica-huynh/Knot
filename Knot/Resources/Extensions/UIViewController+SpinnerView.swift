//
//  UIViewController+SpinnerView.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-04-06.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func createSpinnerView() -> UIView {
        let spinnerView = UIView(frame: view.bounds)
        spinnerView.backgroundColor = UIColor.white
        let spinner = UIActivityIndicatorView.init(style: .large)
        spinner.startAnimating()
        spinner.center = spinnerView.center
        spinnerView.addSubview(spinner)
        return spinnerView
    }
    
    func showSpinner(spinnerView: UIView) {
        if let navigationController = navigationController {
            navigationController.view.insertSubview(spinnerView, belowSubview: navigationController.navigationBar)
        } else {
            view.addSubview(spinnerView)
        }
    }
    
    func removeSpinner(spinnerView: UIView) {
        spinnerView.removeFromSuperview()
    }
}
