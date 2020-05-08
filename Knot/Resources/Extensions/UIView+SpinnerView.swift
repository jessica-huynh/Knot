//
//  UIViewController+SpinnerView.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-04-06.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func createSpinnerView(at position: CGPoint? = nil, with backgroundColour: UIColor = .white) -> UIView {
        let spinnerView = UIView(frame: self.bounds)
        spinnerView.backgroundColor = backgroundColour
        let spinner = UIActivityIndicatorView.init(style: .medium)
        spinner.startAnimating()
        spinner.center = position ?? spinnerView.center
        spinnerView.addSubview(spinner)
        return spinnerView
    }
    
    func showSpinner(spinnerView: UIView, below subview: UIView? = nil) {
        if self.subviews.contains(spinnerView) { return }
        if let subview = subview {
            self.insertSubview(spinnerView, belowSubview: subview)
        } else {
            self.addSubview(spinnerView)
        }
    }
    
    func removeSpinner(spinnerView: UIView) {
        spinnerView.removeFromSuperview()
    }
}

extension UIViewController {
    func createSpinnerView(at position: CGPoint? = nil, with backgroundColour: UIColor = .white) -> UIView {
        return view.createSpinnerView(at: position, with: backgroundColour)
    }
    
    func showSpinner(spinnerView: UIView, belowNavBar: Bool = false) {
        if let navigationController = navigationController {
            navigationController.view.showSpinner(spinnerView: spinnerView,
                                                  below: belowNavBar ? navigationController.navigationBar : nil)
        } else {
            view.showSpinner(spinnerView: spinnerView)
        }
    }
    
    func removeSpinner(spinnerView: UIView) {
        view.removeSpinner(spinnerView: spinnerView)
    }
}
