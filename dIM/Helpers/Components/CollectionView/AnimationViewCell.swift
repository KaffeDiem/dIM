//
//  AnimationViewCell.swift
//  dIM
//
//  Created by Kasper Munch on 05/03/2023.
//

import Lottie
import UIKit

public class AnimationViewCell<DataType: CustomStringConvertible>: UICollectionViewCell, Configurable {
    let animationView = LottieAnimationView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.1)
        layer.cornerRadius = Swift.min(frame.width, frame.height) * 0.2
        clipsToBounds = false
        
        addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationView.heightAnchor.constraint(equalTo: heightAnchor),
            animationView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    public func configure(using data: DataType) {
        animationView.animation = LottieAnimation.named(data.description)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public override func prepareForReuse() {
        animationView.animation = nil
    }
}
