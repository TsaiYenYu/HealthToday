//
//  TotalTimeLocaCalorInfoCardView.swift
//  customer
//
//  Created by user on 2022/6/30.
//  Copyright © 2022 Chinalife. All rights reserved.
//

import Foundation
import UIKit

class TotalTimeLocaCalorInfoCardView: UIView {
    
    static func new(with: String = "") -> TotalTimeLocaCalorInfoCardView  {
        let view = Bundle.main.loadNibNamed("TotalTimeLocaCalorInfoCardView", owner: self, options: nil)?.first as! TotalTimeLocaCalorInfoCardView
        return view
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var calLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .clear
        containerView.makeRadius(radius: 10)
        containerView.addShadow(width: 0, height: 0.5, color: .lightGray, opacity: 0.3, radius: 1)
    }
    
    func updateUI(type: TimeUnit, timeSting: String, distanceString: String, calString: String) {
        switch type {
        case .day:
            titleLabel.text = "本日步行"
        case .week:
            titleLabel.text = "本週總計"
        case .month:
            titleLabel.text = "本月總計"
        }
        timeLabel.text = timeSting
        distanceLabel.text = distanceString
        calLabel.text = calString
    }    
}
