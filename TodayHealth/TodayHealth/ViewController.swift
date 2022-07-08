//
//  ViewController.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        showWalkBarChart()
        let vc = WalkingBarChartViewController.new(with: WalkingBarChartViewModel())
        vc.title = "Health Steps"
        let nav = UINavigationController.init(rootViewController: vc)
        nav.modalTransitionStyle = .partialCurl
        nav.modalPresentationStyle = .fullScreen
//        nav.pushViewController(vc, animated: true)
        self.present(nav, animated: false)
    }

}

