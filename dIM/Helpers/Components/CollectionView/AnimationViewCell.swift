//
//  AnimationViewCell.swift
//  dIM
//
//  Created by Kasper Munch on 05/03/2023.
//

import Lottie
import UIKit

public class Sticker {
    let name: String
    let isUnlocked: Bool
    
    init(name: String, isUnlocked: Bool) {
        self.name = name
        self.isUnlocked = isUnlocked
    }
}


public class AnimationViewCell<DataType: Sticker>: UICollectionViewCell, Configurable {
    let animationView = LottieAnimationView()
    let lockView: UIImageView = {
        let this = UIImageView(image: .init(systemName: "lock.fill"))
        this.translatesAutoresizingMaskIntoConstraints = false
        this.tintColor = UIColor.black.withAlphaComponent(0.9)
        return this
    }()
    
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
        addSubview(lockView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationView.heightAnchor.constraint(equalTo: heightAnchor),
            animationView.widthAnchor.constraint(equalTo: widthAnchor),
            
            lockView.centerXAnchor.constraint(equalTo: centerXAnchor),
            lockView.centerYAnchor.constraint(equalTo: centerYAnchor),
            lockView.widthAnchor.constraint(equalToConstant: 70),
            lockView.heightAnchor.constraint(equalToConstant: 70),
        ])
    }
    
    public func configure(using data: DataType) {
        lockView.isHidden = data.isUnlocked
        animationView.animation = LottieAnimation.named(data.name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public override func prepareForReuse() {
        animationView.animation = nil
    }
}
