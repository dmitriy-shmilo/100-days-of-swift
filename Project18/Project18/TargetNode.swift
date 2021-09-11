//
//  TargetNode.swift
//  Project18
//
//  Created by Dmitriy Shmilo on 11.09.2021.
//

import SpriteKit

class TargetNode: SKSpriteNode {
	var isGood = false
	var moveTo: CGFloat = 0
	var movementDuration: TimeInterval = 0
	var points = 0
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	init(isGood: Bool, moveTo: CGFloat, duration: TimeInterval, points: Int) {
		let texture = SKTexture(imageNamed: isGood ? "GoodTarget" : "BadTarget")
		super.init(texture: texture, color: .clear, size: texture.size())
		self.isGood = isGood
		self.moveTo = moveTo
		self.movementDuration = duration
		self.points = isGood ? abs(points) : -abs(points)
		name = isGood ? "GoodTarget" : "BadTarget"
	}
	
	func start(at position: CGPoint) {
		self.position = position
		let move = SKAction.moveTo(x: moveTo,
								   duration: movementDuration)
		let destroy = SKAction.run {
			self.removeFromParent()
		}
		run(SKAction.sequence([move, destroy]))
	}
	
	func hit() {
		removeFromParent()
	}
}
