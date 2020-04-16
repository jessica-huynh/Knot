//
//  TransactionsHeaderCell.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-28.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class TransactionsHeaderCell: UITableViewCell {
    weak var delegate: TransactionsHeaderCellDelegate?

    var timeFrames: [DateInterval] = []
    let picker: UIPickerView = UIPickerView()
    var pickerOptions: [String] = []
    var rowPicked: Int = 0
    var previousRowPicked: Int = 0
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        return dateFormatter
    }
    
    @IBOutlet weak var timeFrameField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedAccounts(_:)), name: .updatedAccounts, object: nil)
        
        setupTimeFrames()
        setupPicker()
        createToolbar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Picker Setup
    func setupTimeFrames() {
        let recentDays = [30, 60, 90]
        for numberOfDaysToSubtract in recentDays {
            let dayComponent = DateComponents(day: -numberOfDaysToSubtract)
            let startDate = Calendar.current.date(byAdding: dayComponent, to: Date.today)!
            timeFrames.append(DateInterval(start: startDate, end: Date.today))
            pickerOptions.append("Last \(numberOfDaysToSubtract) Days")
        }
        
        for numberOfMonthsToSubtract in 0...12 {
            let monthComponent = DateComponents(month: -numberOfMonthsToSubtract)
            let date = Calendar.current.date(byAdding: monthComponent, to: Date.today)!
            timeFrames.append(DateInterval(start: date.startOfMonth(), end: date.endOfMonth()))
            pickerOptions.append(dateFormatter.string(from: date))
        }
    }

    func setupPicker() {
        picker.delegate = self
        picker.backgroundColor = .white
        timeFrameField.inputView = picker
    }
    
    func createToolbar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = .white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.finishedPicking))
        doneButton.tintColor = UIColor(hexString: "#63BBD7")
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        timeFrameField.inputAccessoryView = toolBar
    }
    
    @objc func finishedPicking() {
        endEditing(true)
        let didChangeTimeFrame = rowPicked != previousRowPicked
        if didChangeTimeFrame {
            delegate?.transactionsHeaderCell(self, didUpdateTimeFrame: timeFrames[rowPicked])
            previousRowPicked = rowPicked
        }
    }
    
    @objc func onUpdatedAccounts(_ notification:Notification) {
        picker.selectRow(0, inComponent: 0, animated: true)
        timeFrameField.text = pickerOptions[0]
        previousRowPicked = 0
    }
}

// MARK: - PickerView Delegate and Data Source
extension TransactionsHeaderCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timeFrameField.text = pickerOptions[row]
        rowPicked = row
    }
}

// MARK: - Delegate Protocol
protocol TransactionsHeaderCellDelegate: class {
    func transactionsHeaderCell(_ : TransactionsHeaderCell, didUpdateTimeFrame timeFrame: DateInterval)
}
