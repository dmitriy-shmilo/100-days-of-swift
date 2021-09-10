//
//  WhackSlotNode.swift
//  Project14
//
//  Created by Dmitriy Shmilo on 09.09.2021.
//

import SpriteKit

class WhackSlotNode: SKNode {
	
	private var charNode: SKSpriteNode!
	var isVisible = false
	var isHit = false
	
	func configure(at position: CGPoint) {
		self.position = position
		
		let sprite = SKSpriteNode(imageNamed: "whackHole")
		addChild(sprite)
		
		let cropNode = SKCropNode()
		cropNode.position = CGPoint(x: 0, y: 15)
		cropNode.zPosition = 1
		cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
		
		charNode = SKSpriteNode(imageNamed: "penguinGood")
		charNode.position = CGPoint(x: 0, y: -90)
		charNode.name = "character"
		cropNode.addChild(charNode)
		
		addChild(cropNode	)
	}
	
	func show(hideTime: Double) {
		if isVisible {
			return
		}
		
		charNode.xScale = 1.0
		charNode.yScale = 1.0
		charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
		isVisible = true
		isHit = false
		
		if Bool.random() {
			charNode.texture = SKTexture(imageNamed: "penguinGood")
			charNode.name = "charGood"
		} else {
			charNode.texture = SKTexture(imageNamed: "penguinEvil")
			charNode.name = "charEvil"
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + hideTime * 3.5) { [weak self] in
			self?.hide()
		}
	}
	
	func hide() {
		if !isVisible {
			return
		}
		
		charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
		isVisible = false
	}
	
	func hit() {
		isHit = true
		
		let delay = SKAction.wait(forDuration: 0.25)
		let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
		let invisible = SKAction.run { [unowned self] in
			self.isVisible = false
		}
		
		charNode.run(SKAction.sequence([delay, hide, invisible]))
	}
}