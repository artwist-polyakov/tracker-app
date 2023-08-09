//
//  TabBarController.swift
//  Tracker
//
//  Created by Александр Поляков on 02.08.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borderView = UIView()
        borderView.backgroundColor = UIColor(named: "TrackerGray")
        borderView.frame = CGRect(x: 0, y: 0, width: self.tabBar.frame.width, height: 1)
        // Добавляем вьюшку границы к Tab Bar
        self.tabBar.addSubview(borderView)
        
        let statsViewController = StatsViewController()
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        
        
        
        self.tabBar.tintColor = UIColor(named: "TrackerBlue")
        
        
        self.tabBar.unselectedItemTintColor = UIColor(named: "TrackerGray")
        
        
        
        // присваиваем вью контроллерам иконки для таб бара
        statsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Stats"),
            selectedImage: nil
        )
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Trackers"),
            selectedImage: nil
        )
        
        // указываем с какими вью контроллерами связан таб бар
        self.viewControllers = [trackersNavigationController, statsViewController]
        
        self.selectedIndex = 0
        
    }
}
