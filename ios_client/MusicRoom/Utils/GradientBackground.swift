//
//  GradientBackground.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/22/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import UIKit

class GradientBackground : CAGradientLayer {
    static private let startPoint = CGPoint(x: 1.0, y: 1.0)
    static private let endPoint = CGPoint(x: 0.0, y: 0.0)
    static private let startPointAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "startPoint")
        animation.fromValue = startPoint
        animation.toValue = CGPoint(x: 1.0, y: 0.0)
        animation.duration = 6.0
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        return animation
    }()
    static private let endPointAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "endPoint")
        animation.fromValue = endPoint
        animation.toValue = CGPoint(x: 0.0, y: 1.0)
        animation.duration = 6.0
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        return animation
    }()

    init(with bounds: CGRect, startColor: UIColor, endColor: UIColor) {
        super.init()

        self.frame = bounds
        self.colors = [startColor.cgColor, endColor.cgColor]
        self.startPoint = GradientBackground.startPoint
        self.endPoint = GradientBackground.endPoint

        self.add(GradientBackground.startPointAnimation, forKey: nil)
        self.add(GradientBackground.endPointAnimation, forKey: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
