//
//  TabBarController.swift
//  Tracker
//
//  Created by Александр Поляков on 02.08.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let statsViewController = StatsViewController()
        let trackersViewController = TrackersViewController()

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
        self.viewControllers = [trackersViewController, statsViewController]
    }
}
