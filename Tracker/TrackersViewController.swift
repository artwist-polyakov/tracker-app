//
//  ViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 27.07.2023.
//

import UIKit

class TrackersViewController: UIViewController {
    
    
    // Вызов конструктора суперкласса с nil параметрами.
        init() { // Объявление инициализатора.
            super.init(nibName: nil, bundle: nil)
        }
        
        // Объявление обязательного инициализатора, который требуется, если вы используете Storyboards или XIBs. В этом случае он не реализован и вызовет ошибку выполнения.
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    
    
    override func viewDidLoad() {
        sleep(10)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

