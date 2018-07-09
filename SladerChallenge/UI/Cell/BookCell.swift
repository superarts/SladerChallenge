//
//  BookCell.swift
//  SladerChallenge
//
//  Created by Leo on 7/8/18.
//  Copyright © 2018 Super Art Software. All rights reserved.
//

import UIKit

class BookCell: UICollectionViewCell {
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var isbnLabel: UILabel!
	@IBOutlet var coverImage: UIImageView!
	@IBOutlet var longPressView: UIView!
	
	public var deleteHandler: (() -> Void)?
	
	private var longPressGesture: UILongPressGestureRecognizer!
	private let wiggleAnimation = CAKeyframeAnimation()
	private var isAnimating = false
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupGesture()
		setupAnimation()
	}
	
	private func setupGesture() {
		longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
		self.addGestureRecognizer(longPressGesture)
	}
	
	private func setupAnimation() {
		let force: CGFloat = 0.5
		wiggleAnimation.keyPath = "transform.rotation"
		wiggleAnimation.values = [0, 0.1*force, -0.1*force, 0.1*force, 0]
		wiggleAnimation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
		wiggleAnimation.duration = CFTimeInterval(1)
		wiggleAnimation.repeatCount = .infinity
		wiggleAnimation.beginTime = CACurrentMediaTime()
	}
	
	@objc func onLongPress(_ gesture: UIPanGestureRecognizer) {
		if !isAnimating {
			isAnimating = true
			layer.add(wiggleAnimation, forKey: "wiggle")
			UIView.animate(withDuration: 0.3, animations: {
				self.longPressView.alpha = 1
			})
		}
	}
	
	@IBAction func actionDismiss() {
		layer.removeAllAnimations()
		isAnimating = false
		UIView.animate(withDuration: 0.3, animations: {
			self.longPressView.alpha = 0
		})
	}
	
	@IBAction func actionDelete() {
		longPressView.alpha = 0
		deleteHandler?()
	}
}
