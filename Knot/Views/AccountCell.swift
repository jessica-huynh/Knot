//
//  AccountCell.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-11.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var accountCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accountCollectionView.showsHorizontalScrollIndicator = false
        accountCollectionView.register(
            UINib(nibName: "AccountCollectionCell", bundle: nil),
            forCellWithReuseIdentifier: "AccountCollectionCell")
    }
}
