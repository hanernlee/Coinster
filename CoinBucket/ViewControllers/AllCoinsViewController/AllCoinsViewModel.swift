//
//  AllCoinsViewModel.swift
//  CoinBucket
//
//  Created by Christopher Lee on 1/9/18.
//  Copyright © 2018 Christopher Lee. All rights reserved.
//

import Foundation

public class AllCoinsViewModel {
    private let environmentService: EnvironmentServiceProtocol
    private let networkService: NetworkService

    private var coins = [ConstructedCoin]()
    private var filteredCoins = [ConstructedCoin]()
    private var suggestions = [Suggestion]()
    
    public var didTapSuggestionCell: (() -> Void)?
    
    private var page: Int = 0
    private var searchText: String = ""
    
    public var isLoadingNextPage: Bool = false
    public var hasLoadedAllCoins: Bool = false
    public var isFiltering: Bool = false
    public var isRefreshing: Bool = false
    
    public var refreshControlText: NSAttributedString = NSAttributedString(string: "")
    
    private var initialCurrency: String
    
    init(environmentService: EnvironmentServiceProtocol, networkService: NetworkService) {
        self.environmentService = environmentService
        self.networkService = networkService
        self.initialCurrency = environmentService.currency
    }
    
    func getCoins(completion: @escaping () -> Void) {
        if isRefreshing {
            reset()
        }
        
        guard isLoadingNextPage == false,
            hasLoadedAllCoins == false,
            isRefreshing == false
            else { return }

        isLoadingNextPage = true
        
        networkService.getCoins(page: page, currency: environmentService.currency) { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .Success(let constructedCoins):
                guard constructedCoins.count > 0 else {
                    self.isLoadingNextPage = false
                    self.isRefreshing = false
                    self.hasLoadedAllCoins = true
                    return completion()
                }
                
                constructedCoins.forEach{ self.coins.append($0) }
                self.filteredCoins = self.coins
                self.page += 1
                self.isLoadingNextPage = false
                self.isRefreshing = false
                self.configureRefreshControlText()
                completion()
            case .Error:
                print("Failed to get Coins")
//                completion()
            }
        }
    }
    
    func getCoinsCount() -> Int {
        return filteredCoins.count
    }

    // MARK: - Configure Coin Cell

    func configureCoinCell(cell: CoinCell, at index: Int) {
        guard filteredCoins.indices.contains(index) else { return }
        
        let coin = filteredCoins[index].coin
        let price =  filteredCoins[index].price
        
        let coinCellViewModel = CoinCellViewModel(coinModel: coin, priceModel: price, networkService: networkService, environmentService: environmentService)
        cell.configure(using: coinCellViewModel)
    }
    
    // MARK: - Currency View Controller
    
    func createCurrencyViewController() -> CurrencyViewController {
        let viewModel = CurrencyViewModel(environmentService: environmentService)
        return CurrencyViewController.instantiate(viewModel: viewModel)
    }
    
    func getSelectedCurrency() -> String {
        return environmentService.currency
    }
    
    // MARK: - Create Details View Controller
    func createCoinDetailsViewController(for index: Int) -> CoinDetailsViewController {
        let coin = filteredCoins[index].coin
        let price =  filteredCoins[index].price
        
        let viewModel = CoinDetailsViewModel(coinModel: coin, priceModel: price, environmentService: environmentService)
        let addToBucketLauncher = AddToBucketLauncher(coin: coin, environmentService: environmentService)
        return CoinDetailsViewController.instantiate(viewModel: viewModel, addToBucketLauncher: addToBucketLauncher)
    }
    
    // MARK: - Filter
    
    func filterCoins(completion: @escaping (Int) -> Void) {
        guard searchText.isEmpty == false else {
            filteredCoins = coins
            return completion(filteredCoins.count)
        }
        
        filteredCoins = coins.filter { $0.coin.fullName.lowercased().contains(searchText.lowercased()) }
        completion(filteredCoins.count)
    }
    
    // MARK: - Suggestions
    
    func getSuggestions(with searchText: String, completion: @escaping (Int) -> Void) {
        
        suggestions.removeAll()

        networkService.getSuggestions(searchText: searchText) { [weak self] (result) in
            guard let `self` = self else { return }

            switch result {
            case .Success(let suggestions):
                self.suggestions = suggestions
                completion(suggestions.count)
            case .Error:
                print("Failed to get suggestions")
//                completion()
            }
        }
    }
    
    func configureSuggestionCell(cell: SuggestionCell, at index: Int) {
        guard suggestions.indices.contains(index) else { return }
        
        let suggestion = suggestions[index]
        let suggestionCellViewModel = SuggestionCellViewModel(model: suggestion, networkService: networkService, environmentService: environmentService)
        cell.didTapSuggestionCell = { [weak self] in
            guard let `self` = self else { return }

            self.suggestions.removeAll()

            suggestionCellViewModel.getCoin(completion: { (constructedCoins) in
                self.filteredCoins = constructedCoins
                self.didTapSuggestionCell!()
            })
        }
        cell.configure(using: suggestionCellViewModel)
    }
    
    func configureSuggestionHeaderLabel(headerView: SuggestionHeaderView) {
        headerView.suggestionHeaderLabel.text = "Search results for \"\(searchText)\""
    }
    
    func hasSuggestions() -> Bool {
        return suggestions.count > 0
    }
    
    func selectSuggestionCell(cell: SuggestionCell, at index: Int) {
        suggestions.removeAll()
        cell.didTapSuggestionCell!()
    }
    
    func getSuggestionCount() -> Int {
        return suggestions.count
    }
    
    func updateSearchText(with searchText: String) {
        self.suggestions.removeAll()
        self.searchText = searchText
    }
    
    func getSearchText() -> String {
        return searchText
    }
    
    func shouldRefreshCurrency(completion: @escaping (Bool) -> Void) {
        let shouldRefresh = (initialCurrency != environmentService.currency)
        
        if shouldRefresh {
            initialCurrency = environmentService.currency
            reset()
        }

        completion(shouldRefresh)
    }
    
    func configureRefreshControlText() {
        let displayString = Date().toString(dateFormat: "d MMM yyyy h:mm a")
        refreshControlText = NSAttributedString(string: "Last updated \(displayString)")
    }
    
    func reset() {
        coins = [ConstructedCoin]()
        filteredCoins = [ConstructedCoin]()
        suggestions = [Suggestion]()
        
        page = 0
        searchText = ""
        
        isLoadingNextPage = false
        hasLoadedAllCoins = false
        isFiltering = false
        isRefreshing = false
    }
}
