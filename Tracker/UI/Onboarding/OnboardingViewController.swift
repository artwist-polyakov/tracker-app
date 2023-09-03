//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 03.09.2023.
//

import Foundation
import UIKit
class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let repository = OnboardingRepository()
    lazy var pages: [UIViewController] = {
        return repository.getOnboardingData().map {
            OnboardingPageViewController(
                data: $0,
                repository: repository,
                completion: showNextOrClose) }
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        let color = UIColor(named: "#1A1B22") ?? .black
        pageControl.currentPageIndicatorTintColor = color
        pageControl.pageIndicatorTintColor = color.withAlphaComponent(0.3)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }

        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = (pages.count + viewControllerIndex - 1) % pages.count

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = (pages.count + viewControllerIndex + 1) % pages.count

        return pages[nextIndex]
    }
    
    // MARK: - UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }

    

    private func showNextOrClose() {
        if let currentViewController = viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController),
           currentIndex + 1 < pages.count {
            let nextViewController = pages[currentIndex + 1]
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        } else {
            // Закрыть Onboarding и показать TabBarController
            let window = UIApplication.shared.windows.first
            window?.rootViewController = TabBarController()
            window?.makeKeyAndVisible()
        }
    }
}

