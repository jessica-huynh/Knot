//
//  HomeViewController+TableViewDelegates.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-04-14.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension HomeViewController {
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 2 {
            return nil
        }
        
        if indexPath == IndexPath(row: 0, section: 1) && storageManager.cashAccounts.isEmpty {
            return nil
        } else if indexPath == IndexPath(row: 1, section: 1) && storageManager.creditAccounts.isEmpty {
            return nil
        }
        return indexPath
     }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectedBackgroundView = UITableViewCell.lightGrayBackgroundView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionTitle: UILabel = UILabel()
        sectionTitle.frame = CGRect(x: 30, y: -10, width: 320, height: 30)
        sectionTitle.font = UIFont.boldSystemFont(ofSize: 18)
        sectionTitle.textColor = UIColor.black
        sectionTitle.text = self.tableView(tableView, titleForHeaderInSection: section)

        let headerView = UIView()
        headerView.addSubview(sectionTitle)

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 { return 10 }
        return 30
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white
    }
}
