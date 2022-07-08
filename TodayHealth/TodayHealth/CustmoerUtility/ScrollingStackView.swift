//
//  ScrollingStackView.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//

import UIKit

public class ScrollingStackView: UIView {
    private var didSetupConstraints = false
    
    public var topConstraint: CGFloat =  0
    public var leadingConstraint: CGFloat =  0
    public var trailingConstraint: CGFloat =  0
    public var bottomConstraint: CGFloat =  0
    
    public var axis: NSLayoutConstraint.Axis {
        get {
            return stackView.axis
        }
        set {
            stackView.axis = newValue
            switch newValue as NSLayoutConstraint.Axis {
            case .vertical:
                stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
            case .horizontal:
                stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true
            @unknown default:
                fatalError()
            }
        }
    }

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.layoutMargins = .zero
        return scrollView
    }()

    public lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        setNeedsUpdateConstraints()
    }

    public override func updateConstraints() {
        super.updateConstraints()
        if !didSetupConstraints {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topConstraint),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: leadingConstraint),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: trailingConstraint),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: bottomConstraint),
            ])
            
            didSetupConstraints.toggle()
        }
    }
}

extension ScrollingStackView {
    public func add(view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    public func insert(view: UIView, at index:  Int) {
        stackView.insertArrangedSubview(view, at: index)
    }
    
    public func remove(view: UIView) {
        stackView.removeArrangedSubview(view)
    }
}

extension ScrollingStackView {
    public var spacing: CGFloat {
        get {
            return stackView.spacing
        }
        set {
            stackView.spacing = newValue
        }
    }
    
    public var alignment: UIStackView.Alignment {
        get {
            return stackView.alignment
        }
        set {
            stackView.alignment = newValue
        }
    }

    public var distribution: UIStackView.Distribution {
        get {
            return stackView.distribution
        }
        set {
            stackView.distribution = newValue
        }
    }
    
    public var showsVerticalScrollIndicator: Bool {
        get {
            return scrollView.showsVerticalScrollIndicator
        }
        set {
            scrollView.showsVerticalScrollIndicator = newValue
        }
    }

    public var bounces: Bool {
        get {
            return scrollView.bounces
        }
        set {
            scrollView.bounces = newValue
        }
    }
}
