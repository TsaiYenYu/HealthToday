//
//  TimeUnitButtonsView.swift
//  customer
//
//  Created by user on 2022/6/29.
//  Copyright © 2022 Chinalife. All rights reserved.
//

import UIKit

class TimeSelectView: UIView {
    
    static func new(with: String = "") -> TimeSelectView  {
        let view = Bundle.main.loadNibNamed("TimeSelectView", owner: self, options: nil)?.first as! TimeSelectView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBOutlet weak var nextImageView: UIImageView!
    @IBOutlet weak var lastImageView: UIImageView!
    @IBOutlet weak var displayTimeLabel: UILabel!
    
    var onNext: (() -> ())?
    var onLast: (() -> ())?
    
    func setupUI() {
        backgroundColor = .clear
        nextImageView.do {
            $0.isUserInteractionEnabled = true
            let tapNext = UITapGestureRecognizer(target: self, action: #selector(clickNext))
            $0.addGestureRecognizer(tapNext)
        }
        lastImageView.do {
            $0.isUserInteractionEnabled = true
            let tapLast = UITapGestureRecognizer(target: self, action: #selector(clickLast))
            $0.addGestureRecognizer(tapLast)
        }
    }

    @objc func clickNext() {
        self.onNext?()
    }
    
    @objc func clickLast() {
        self.onLast?()
    }
    
}
