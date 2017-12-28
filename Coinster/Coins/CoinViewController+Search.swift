//
//  CoinViewController+UISearchBarDelegate.swift
//  Coinster
//
//  Created by Christopher Lee on 16/12/17.
//  Copyright © 2017 Christopher Lee. All rights reserved.
//

import UIKit

extension CoinsViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchCoin(id:)), object: lastSearched)
        
        lastSearched = searchText as NSString
        self.perform(#selector(searchCoin(id:)), with: lastSearched, afterDelay: 1.0)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        
        progressHUD.hide()
        
        filterCoins(searchBar: searchController.searchBar, searchText: searchText) { (coins) in
            if (coins.isEmpty) {
                progressHUD.showWithoutSpinner()
                progressHUD.text = "Sorry can't find `\(searchText)`. Try hitting 'Search'."
                
//                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchCoin(id:)), object: lastSearched)
//                lastSearched = searchText as NSString
//                self.perform(#selector(searchCoin(id:)), with: lastSearched, afterDelay: 1.0)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        progressHUD.hide()
    }
}
