//
//  TimeLocaCalorInfoCardView.swift
//  customer
//
//  Created by user on 2022/6/29.
//  Copyright © 2022 Chinalife. All rights reserved.
//

import UIKit

class TimeLocaCalorInfoCardView: UIView {
    
    static func new(with: String = "") -> TimeLocaCalorInfoCardView  {
        let view = Bundle.main.loadNibNamed("TimeLocaCalorInfoCardView", owner: self, options: nil)?.first as! TimeLocaCalorInfoCardView
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
        containerView.makeBorder(borderColor: .clear, borderWidth: 1)
        containerView.addShadow(width: 0, height: 0.5, color: .lightGray, opacity: 0.3, radius: 1)
    }
    
    func updateUI(type: TimeUnit, timeSting: String, distanceString: String, calString: String) {
        switch type {
        case .day:
            titleLabel.text = "本日步行"
        case .week:
            titleLabel.text = "平均每日"
        case .month:
            titleLabel.text = "平均每日"
        }
        timeLabel.text = timeSting
        distanceLabel.text = distanceString
        calLabel.text = calString
    }
}
