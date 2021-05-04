//
//  CPKProgressHUD.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 9/25/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import SwiftUI
import UIKit

enum CPKProgressHUDStyle {
    case loading(text: String? = nil)
    case success
}

class CPKProgressHUD: UIVisualEffectView {
    private let dimension: CGFloat = 100.0

    var indicator: UIActivityIndicatorView? = nil
    let textLabel: UILabel

    let style: CPKProgressHUDStyle

    private init(style: CPKProgressHUDStyle) {
        self.style = style

        self.textLabel = UILabel()
        self.textLabel.numberOfLines = 0
        self.textLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.textLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        self.textLabel.textAlignment = .center

        super.init(effect: UIBlurEffect(style: .dark))

        self.isHidden = true
        self.alpha = 0
        self.layer.cornerRadius = 10
        self.clipsToBounds = true

        self.contentView.addSubview(textLabel)

        switch style {
            case .loading(text: let text):
                let indicator = UIActivityIndicatorView(style: .large)
                indicator.color = .white
                self.contentView.addSubview(indicator)
                self.indicator = indicator
                if let text = text {
                    self.textLabel.text = text
                } else {
                    self.textLabel.text = "Loading".localizedCore
                }
                break
            case .success:
                break
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func progressHUD(style: CPKProgressHUDStyle) -> CPKProgressHUD {
        return CPKProgressHUD(style: style)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        if let indicator = indicator {
            let w = indicator.frame.width
            let h = indicator.frame.height
            indicator.frame = CGRect(x: (bounds.width - w) / 2.0, y: 18.0, width: w, height: h)
            textLabel.sizeToFit()
            textLabel.frame = CGRect(x: 0,
                                     y: indicator.frame.maxY,
                                     width: bounds.width,
                                     height: bounds.height - 23.0 - indicator.frame.height)
        }
    }

    func show(in view: UIView) {
        self.removeFromSuperview()
        view.addSubview(self)
        view.bringSubviewToFront(self)

        indicator?.startAnimating()

        let bounds = view.bounds
        self.frame = CGRect(x: (bounds.maxX - bounds.minX - dimension) / 2.0,
                            y: (bounds.maxY - bounds.minY - dimension) / 2.0,
                            width: dimension,
                            height: dimension)
        self.setNeedsLayout()
        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.3) {
            self.isHidden = false
            self.alpha = 1
        }
    }

    func dismiss(after delay: TimeInterval = 0.3) {
        UIView.animate(withDuration: delay, animations: {
            self.isHidden = true
            self.alpha = 0
            self.indicator?.stopAnimating()
        }) { (success) in
            self.removeFromSuperview()
        }
    }
}

struct CPKProgressHUDUI: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<CPKProgressHUDUI>) -> CPKProgressHUD {
        return CPKProgressHUD.progressHUD(style: .loading(text: nil))
    }

    func updateUIView(_ uiView: CPKProgressHUD, context: UIViewRepresentableContext<CPKProgressHUDUI>) {
    }

    typealias UIViewType = CPKProgressHUD
}
