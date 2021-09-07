//
//  GameScene.swift
//  Project11
//
//  Created by Dmitriy Shmilo on 06.09.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	static let initialBallCount = 5
	static let allowedTopInset:CGFloat = 150

	var scoreLabel: SKLabelNode!
	var editingLabel: SKLabelNode!
	var ballCountLabel: SKLabelNode!
	
	var ballCount: Int = initialBallCount {
		didSet {
			ballCountLabel.text = "\(ballCount) balls left"
		}
	}
	var isEditing = false {
		didSet {
			editingLabel.text = isEditing ? "Done" : "Editing"
			ballCount = Self.initialBallCount
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
		
		ballCountLabel = SKLabelNode(fontNamed: "Chalkduster")
		ballCountLabel.text = "\(ballCount) balls left"
		ballCountLabel.horizontalAlignmentMode = .right
		ballCountLabel.position = CGPoint(x: 980, y: 650)
		addChild(ballCountLabel)
		
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
				makeBox(at: location)
				return
			}
			
			if size.height - location.y <= Self.allowedTopInset {
				makeBall(at: location)
				ballCount -= 1
				return
			}
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
	
	private func makeBall(at position: CGPoint) {
		let color = ["Blue", "Cyan", "Green", "Green", "Grey", "Purple", "Yellow", "Red"].randomElement()!
		let ball = SKSpriteNode(imageNamed: "ball\(color).png")
		ball.position = position
		ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
		ball.physicsBody?.restitution = 0.4
		ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask
		ball.name = "Ball"
		addChild(ball)
	}
	
	private func makeBox(at position: CGPoint) {
		let size = CGSize(width: CGFloat.random(in: 16...128), height: 16)
		let box = SKSpriteNode(
			color: UIColor(
				red: CGFloat.random(in: 0...1),
				green: CGFloat.random(in: 0...1),
				blue: CGFloat.random(in: 0...1),
				alpha: 1.0
			), size: size)
		box.name = "Box"
		box.zRotation = CGFloat.random(in: 0...CGFloat.pi)
		box.position = position
		box.physicsBody = SKPhysicsBody(rectangleOf: size)
		box.physicsBody?.isDynamic = false
		addChild(box)
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
			destroy(node: ball, withFX: true)
			score += 1
			ballCount += 1
		} else if object.name == "Bad" {
			destroy(node: ball, withFX: true)
			score -= 1
		} else if object.name == "Box" {
			destroy(node: object, withFX: false)
		}
	}
	
	private func destroy(node: SKNode, withFX: Bool) {
		if withFX, let particles = SKEmitterNode(fileNamed: "FireParticles") {
			particles.position = node.position
			addChild(particles)
		}
		node.removeFromParent()
	}
}
