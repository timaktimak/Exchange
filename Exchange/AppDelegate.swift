//
//  AppDelegate.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Exchange", bundle: .main)
        guard let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController else {
            fatalError()
        }
        guard let exchangeViewController = navigationController.viewControllers.first as? ExchangeViewController else {
            fatalError()
        }
        let assembly: ExchangeAssemblyProtocol = ExchangeAssembly()
        exchangeViewController.viewModel = assembly.viewModel
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
}
