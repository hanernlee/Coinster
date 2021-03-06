//
//  BucketViewController.swift
//  CoinBucket
//
//  Created by Christopher Lee on 18/11/18.
//  Copyright © 2018 Christopher Lee. All rights reserved.
//

import UIKit

public class BucketViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    private var viewModel: BucketViewModel!

    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    lazy var currencyRightButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(presentCurrencySelection), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.gray, for: .normal)
        return button
    }()

    lazy var addCoinButton: UIButton = {
        let button = UIButton()
        button.setTitle("+ Add Coins", for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 12.0
        button.layer.masksToBounds = true
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        return button
    }()

    let emptyView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Instantiate
    public static func instantiate(viewModel: BucketViewModel) -> BucketViewController {
        let viewController = BucketViewController.instantiateFromStoryboard()
        viewController.viewModel = viewModel
        return viewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.configureRefreshControlText()
        configure()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        toggleDisplayAddCoinButton()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        checkForBucketChanges()
        configureNavigationBar()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currencyRightButton.removeFromSuperview()
    }

    private func configure() {
        configureCollectionView()
        configureInitialCoinCollection()
    }
    
    // MARK: - Configure Navigation Title
    private func configureNavigationBar() {
        navigationItem.title = "Bucket"
        
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.addSubview(currencyRightButton)
        
        currencyRightButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currencyRightButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -6),
            currencyRightButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -16)
            ])
        
        configureCurrency()
    }
    
    // MARK: - Configure Currency
    private func configureCurrency() {
        viewModel.shouldRefreshCurrency { [weak self] (shouldRefresh) in
            guard let `self` = self, shouldRefresh else { return }

            self.configureInitialCoinCollection()
        }

        currencyRightButton.setTitle(viewModel.getSelectedCurrency(), for: .normal)
    }
    
    // MARK: - Configure Initial Coin Collection
    private func configureInitialCoinCollection() {
        self.view.showLoadingIndicator()
        self.refreshControl.endRefreshing()

        viewModel.getCoinsFromDataStorage { [weak self] in
            guard let `self` = self else { return }
            
            self.view.hideLoadingIndicator()
            self.refreshControl.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Configure CollectionView
    private func configureCollectionView() {
        collectionView.backgroundColor = .bgGray
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BucketCoinHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomCellIdentifier.bucketCoinHeader)
        collectionView.register(BucketCoinHeaderEmpty.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomCellIdentifier.bucketCoinHeaderEmpty)
        collectionView.register(UINib(nibName: "BucketCoinCell", bundle: nil), forCellWithReuseIdentifier: CustomCellIdentifier.bucketCoinCell)

        configureRefreshControl()
        configureBackgroundCollectionView()
        configureCollectionViewFlowLayout()
    }

    private func configureBackgroundCollectionView() {
        collectionView.backgroundView = emptyView
        emptyView.addSubview(addCoinButton)
        
        addCoinButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addCoinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCoinButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addCoinButton.widthAnchor.constraint(equalToConstant: 150),
            addCoinButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        addCoinButton.isHidden = false
        
        addCoinButton.addTarget(self, action: #selector(goToCoins), for: .touchUpInside)
    }
    
    // MARK: - Configure CollectionViewFlowLayout
    
    private func configureCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        layout.itemSize = CGSize(width: self.view.frame.width - 32, height: 70)
        layout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: 300)
        collectionView.collectionViewLayout = layout
    }
    
    private func configureRefreshControl() {
        refreshControl.attributedTitle = viewModel.refreshControlText
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func removeRefreshControl() {
        refreshControl.removeTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = nil
        self.refreshControl.removeFromSuperview()
    }

    private func toggleDisplayAddCoinButton() {
        if viewModel.bucketIsEmpty() {
            addCoinButton.isHidden = false
        } else {
            addCoinButton.isHidden = true
        }
    }

    @objc func goToCoins() {
        tabBarController?.selectedIndex = 1
    }
    
    // MARK: - Refresh
    @objc private func handleRefresh() {
        
        viewModel.isRefreshing = true
        self.view.showLoadingIndicator()
        self.refreshControl.beginRefreshing()

        
        viewModel.getCoinsFromDataStorage { [weak self] in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.refreshControl.attributedTitle = self.viewModel.refreshControlText
                self.viewModel.isRefreshing = false
                
                self.view.hideLoadingIndicator()
                self.collectionView.reloadData()
            }
        }
    }
    
    private func checkForBucketChanges() {
        if viewModel.shouldBucketChange() {
            configureInitialCoinCollection()
        }
    }
    
    // MARK: - Present Currency View Controller
    @objc private func presentCurrencySelection() {
        let currencyViewController = viewModel.createCurrencyViewController()
        let navigationController = UINavigationController(rootViewController: currencyViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension BucketViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCellIdentifier.bucketCoinCell, for: indexPath) as? BucketCoinCell else {
            return UICollectionViewCell()
        }
        
        viewModel.configureCoinCell(cell: cell, at: indexPath.item)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getCoinsCount()
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationItem.rightBarButtonItem = nil
        let coinDetailsViewController = viewModel.createCoinDetailsViewController(for: indexPath.item)
        navigationController?.pushViewController(coinDetailsViewController, animated: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if viewModel.getCoinsCount() == 0 {
            let headerEmpty = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomCellIdentifier.bucketCoinHeaderEmpty, for: indexPath) as! BucketCoinHeaderEmpty
            headerEmpty.frame = CGRect.zero
            return headerEmpty
        }
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomCellIdentifier.bucketCoinHeader, for: indexPath) as? BucketCoinHeader else {
                return UICollectionReusableView()
            }
            
            cell.configure(with: viewModel.createBucketCoinHeaderViewModel())
            
            return cell
        default:  fatalError("Unexpected element kind")
        }
    }
}

extension BucketViewController: Storyboardable {}
