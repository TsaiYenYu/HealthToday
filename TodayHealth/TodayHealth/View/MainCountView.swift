//
//  MainCountView.swift
//  customer
//
//  Created by user on 2022/6/29.
//  Copyright © 2022 Chinalife. All rights reserved.
//

import Foundation
import UIKit


class MainCountView: UIView {
   
    static func new(with: String = "") -> MainCountView  {
        let view = Bundle.main.loadNibNamed("MainCountView", owner: self, options: nil)?.first as! MainCountView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    func setupUI() {
        
    }
}
