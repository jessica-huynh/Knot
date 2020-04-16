//
//  NoSelectTextField.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-29.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

/// A   `UITextField` with all possible user interaction disabled.
class NoSelectTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
}
