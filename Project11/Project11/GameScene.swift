//
//  GameScene.swift
//  Project11
//
//  Created by Dmitriy Shmilo on 06.09.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	var scoreLabel: SKLabelNode!
	var editingLabel: SKLabelNode!
	
	var isEditing = false {
		didSet {
			editingLabel.text = isEditing ? "Done" : "Editing"
		}
	}
	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
    
	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "background.jpg")
		background.position = CGPoint(x: 1024 / 2, y: 768 / 2)
		background.blendMode = .replace
		background.zPosition = -1
		
		for i in 0..<4 {
			makeSlot(
				at: CGPoint(x: CGFloat(i) * size.width / 4.0 + size.width / 8.0, y: 0),
				isGood: i.isMultiple(of: 2)
			)
		}
		
		for i in 0..<5 {
			makeBouncer(at: CGPoint(x: CGFloat(i) * size.width / 4.0, y: 0))
		}
		
		editingLabel = SKLabelNode(fontNamed: "Chalkduster")
		editingLabel.text = "Edit"
		editingLabel.position = CGPoint(x: 80, y: 700)
		addChild(editingLabel)

		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.text = "Score \(score)"
		scoreLabel.horizontalAlignmentMode = .right
		scoreLabel.position = CGPoint(x: 980, y: 700)
		addChild(scoreLabel)
		
		physicsWorld.contactDelegate = self
		physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
		addChild(background)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let location = touch.location(in: self)
			let nodes = nodes(at: location)
			
			if nodes.contains(editingLabel) {
				isEditing.toggle()
				return
			}
			
			if isEditing {
				let size = CGSize(width: CGFloat.random(in: 16...128), height: 16)
				let box = SKSpriteNode(
					color: UIColor(
						red: CGFloat.random(in: 0...1),
						green: CGFloat.random(in: 0...1),
						blue: CGFloat.random(in: 0...1),
						alpha: 1.0
					), size: size)
				box.zRotation = CGFloat.random(in: 0...CGFloat.pi)
				box.position = location
				box.physicsBody = SKPhysicsBody(rectangleOf: size)
				box.physicsBody?.isDynamic = false
				addChild(box)
				return
			}

			let ball = SKSpriteNode(imageNamed: "ballBlue.png")
			ball.position = location
			ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
			ball.physicsBody?.restitution = 0.4
			ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask
			ball.name = "Ball"
			addChild(ball)
		}
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		guard let nodeA = contact.bodyA.node,
			  let nodeB = contact.bodyB.node else {
			return
		}
		
		if nodeA.name == "Ball" {
			collisionBetween(ball: nodeA, object: nodeB)
		} else if nodeB.name == "Ball" {
			collisionBetween(ball: nodeB, object: nodeA)
		}
	}
	
	private func makeBouncer(at position: CGPoint) {
		let bouncer = SKSpriteNode(imageNamed: "bouncer.png")
		bouncer.position = position
		bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
		bouncer.physicsBody?.isDynamic = false
		addChild(bouncer)
	}
	
	private func makeSlot(at position: CGPoint, isGood: Bool) {
		var slotBase: SKSpriteNode
		var slotGlow: SKSpriteNode
		
		let spin = SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 10))
		
		if isGood {
			slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
			slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
			slotBase.name = "Good"
		} else {
			slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
			slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
			slotBase.name = "Bad"
		}
		
		slotBase.position = position
		slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
		slotBase.physicsBody?.isDynamic = false
		
		slotGlow.position = position
		slotGlow.run(spin)
		addChild(slotBase)
		addChild(slotGlow)
	}
	
	private func collisionBetween(ball: SKNode, object: SKNode) {
		if object.name == "Good" {
			destroy(node: ball)
			score += 1
		} else if object.name == "Bad" {
			destroy(node: ball)
			score -= 1
		}
	}
	
	private func destroy(node: SKNode) {
		if let particles = SKEmitterNode(fileNamed: "FireParticles") {
			particles.position = node.position
			addChild(particles)
		}
		node.removeFromParent()
	}
}
