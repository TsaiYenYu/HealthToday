//
//  CircleSpecView.swift
//  customer
//
//  Created by user on 2022/7/1.
//  Copyright © 2022 Chinalife. All rights reserved.
//

import Foundation
import UIKit

class CircleSpecView: UIView {
    
    static func new(with: String = "") -> CircleSpecView  {
        let view = Bundle.main.loadNibNamed("CircleSpecView", owner: self, options: nil)?.first as! CircleSpecView
        return view
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        
    }
    
    func updateUI(dateString: String, count: String, unitString: String = "步") {
        dateLabel.text = dateString
        countLabel.text = count
        unitLabel.text = unitString
    }
}
