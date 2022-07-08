//
//  UiView+utility.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//

import Foundation
import UIKit


extension UIView {
    public func makeBorder(borderColor: UIColor, borderWidth: CGFloat) {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    public func makeRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    public func makeRadiusForEachCorner(radius: CGFloat, corners: CACornerMask?) {
        self.layer.cornerRadius = radius
        
        if let corners = corners {
            self.layer.maskedCorners = corners
        }
    }
    
    public func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    public func addSeparator(color: UIColor, leftPadding: CGFloat = 16, rightPadding: CGFloat = -16, width: CGFloat = 1) {
        let separatorLine = UIView()
        separatorLine.backgroundColor = color
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(separatorLine)
        separatorLine.heightAnchor.constraint(equalToConstant: width).isActive = true
        separatorLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftPadding).isActive = true
        separatorLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rightPadding).isActive = true
        separatorLine.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    public func addVerticalSeparator(color: UIColor, topPadding: CGFloat = 10, bottomPadding: CGFloat = -10, width: CGFloat = 1) {
        let separatorLine = UIView()
        separatorLine.backgroundColor = color
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(separatorLine)
        separatorLine.widthAnchor.constraint(equalToConstant: width).isActive = true
        separatorLine.topAnchor.constraint(equalTo: self.topAnchor, constant: topPadding).isActive = true
        separatorLine.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottomPadding).isActive = true
        separatorLine.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    public func addDashedBorder(start: CGPoint, end: CGPoint, color: UIColor = .lightGray) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [5, 5]

        let path = CGMutablePath()
        path.addLines(between: [start, end])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    
    public func addDashedBorderWithCorner(color: UIColor = .gray) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.frame = self.bounds
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [5, 5]

        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width , height: self.bounds.height), cornerRadius: self.frame.height / 2).cgPath
        
        return shapeLayer
    }

}



public extension UIView {

    var absoluteFrame: CGRect {
        UIApplication.shared.delegate?.window.flatMap { convert(bounds, to: $0) } ?? .zero
    }

    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func fill(with subview: UIView, insets: UIEdgeInsets = .zero) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: insets.right),
            subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: insets.bottom)])
    }
    
    var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
}


extension UIView {
    
    /// 陰影
    /// - Parameters:
    ///   - width: _
    ///   - height: _
    ///   - color: _
    ///   - opacity: _
    ///   - radius: _
    public func addShadow(width: CGFloat = 0.2, height: CGFloat = 0.2, color: UIColor, opacity: Float = 0.5, radius: CGFloat = 0.5) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
    }
    
    public func removeShadow() {
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 0.0
    }
    
    public func applyShadow(color: UIColor, opacity: Float = 1.0) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    
    /// 漸層
    /// - Parameters:
    ///   - colors: 顏色的分配
    ///   - startPoint: 起始位置(預設左上)
    ///   - endPoint: 結束位置(預設右下)
    public func applyGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1), locations: [NSNumber]? = nil) {
        guard self.layer.sublayers?.first(where: {$0.isKind(of: CAGradientLayer.self) }) == nil else { return }
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        if let location = locations {
            gradientLayer.locations = location
        }
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //  移除漸層
    public func removeGradient() {
        layer.sublayers?.first(where: {$0.isKind(of: CAGradientLayer.self) })?.removeFromSuperlayer()
    }
    
    /// 漸層&陰影
    /// - Parameters:
    ///   - colors: 顏色的分配
    ///   - startPoint: 起始位置(預設左上)
    ///   - endPoint: 結束位置(預設右下)
    public func applyGradientAndShadow(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1), cornerRadius: CGFloat, shadowColor: UIColor, shadowColorOffset: CGSize, shadowRadius: CGFloat = 3.0, opacity: Float = 0.3) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        
        guard self.layer.sublayers?.first(where: {$0.isKind(of: CAGradientLayer.self) }) == nil else { return }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadius
        
        gradientLayer.shadowColor = shadowColor.cgColor
        gradientLayer.shadowOffset = shadowColorOffset
        gradientLayer.shadowRadius = shadowRadius
        gradientLayer.shadowOpacity = opacity
        gradientLayer.masksToBounds = false
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UICollectionViewCell {
    public func applyRoundShadow(radius: CGFloat, color: UIColor) {
        contentView.layer.cornerRadius = radius
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
    }
}
