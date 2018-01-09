//
//  MainTabBarController.swift
//  CoinBucket
//
//  Created by Christopher Lee on 9/12/17.
//  Copyright © 2017 Christopher Lee. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    var stateController: StateController!

    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBarItems()
        tabBar.itemPositioning = .fill
    }

    // MARK: - Fileprivate Methods
    fileprivate func setupTabBarItems() {
        let stateController = StateController(currency: Currency(name: "USD"))
        
        let coinsViewController = CoinsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        coinsViewController.stateController = stateController
        let coinsNavController = templateNavController(title: "Coins", unselectedImage: #imageLiteral(resourceName: "coins_unselected").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "coins_selected").withRenderingMode(.alwaysOriginal), rootViewController: coinsViewController)
        
        let settingsController = SettingsViewController()
        settingsController.stateController = stateController
        let settingsNavController = templateNavController(title: "Settings", unselectedImage: #imageLiteral(resourceName: "settings_unselected").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "settings_selected").withRenderingMode(.alwaysOriginal), rootViewController: settingsController)
        
        viewControllers = [coinsNavController, settingsNavController]
    }
    
    // Templating Navigation Controllers
    fileprivate func templateNavController(title: String, unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.prefersLargeTitles = true
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        navController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, 5)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}
