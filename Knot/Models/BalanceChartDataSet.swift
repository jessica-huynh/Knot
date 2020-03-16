//
//  BalanceChartDataSet.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-16.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import Charts

class BalanceChartDataSet: LineChartDataSet {
    var isCustomized = false
    
    public required init() {
        super.init()
    }
    
    public override init(entries: [ChartDataEntry]?, label: String?) {
        super.init(entries: entries, label: label)
    }
}
