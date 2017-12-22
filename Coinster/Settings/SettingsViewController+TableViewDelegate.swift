//
//  SettingsViewController+TableViewDelegate.swift
//  Coinster
//
//  Created by Christopher Lee on 19/12/17.
//  Copyright © 2017 Christopher Lee. All rights reserved.
//

import UIKit

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Currency"
        case 1: return "Nightmode"
        default: fatalError("Unknown section")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let currencyController = CurrencyViewController()
                currencyController.delegate = self
                navigationController?.pushViewController(currencyController, animated: true)
            }
        default: fatalError("Unknown section")
        }
    }
}
