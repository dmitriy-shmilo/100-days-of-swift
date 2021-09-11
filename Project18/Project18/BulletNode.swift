//
//  BulletNode.swift
//  Project18
//
//  Created by Dmitriy Shmilo on 11.09.2021.
//

import SpriteKit

class BulletNode: SKSpriteNode {
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	init() {
		let texture = SKTexture(imageNamed: "Bullet")
		super.init(texture: texture, color: .clear, size: texture.size())
	}
	
	func use() {
		alpha = 0.5
	}
	
	func reload() {
		alpha = 1.0
	}
}
