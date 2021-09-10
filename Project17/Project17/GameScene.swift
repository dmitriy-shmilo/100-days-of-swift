//
//  GameScene.swift
//  Project17
//
//  Created by Dmitriy Shmilo on 10.09.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	let items = ["hammer", "ball", "tv"]
	var isGameOver = false
	var gameTimer: Timer?
	var starField: SKEmitterNode!
	var player: SKSpriteNode!
	var scoreLabel: SKLabelNode!
	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
    
	override func didMove(to view: SKView) {
		backgroundColor = .black
		
		starField = SKEmitterNode(fileNamed: "starfield")
		starField.position = CGPoint(x: 1024, y: 384)
		starField.advanceSimulationTime(10)
		starField.zPosition = -1
		addChild(starField)
		
		player = SKSpriteNode(imageNamed: "player")
		player.position = CGPoint(x: 100, y: 384)
		player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
		player.physicsBody?.contactTestBitMask = 1
		addChild(player)
		
		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.position = CGPoint(x: 16, y: 16)
		scoreLabel.horizontalAlignmentMode = .left
		addChild(scoreLabel)
		
		score = 0
		
		physicsWorld.gravity = CGVector.zero
		physicsWorld.contactDelegate = self
		
		gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		
		var location = touch.location(in: self)
		if location.y < 100 {
			location.y = 100
		} else if location.y > 668 {
			location.y = 668
		}
		
		player.position = location
	}
	
	override func update(_ currentTime: TimeInterval) {
		children
			.filter { $0.position.x <= -300 }
			.forEach { $0.removeFromParent() }
		
		if !isGameOver {
			score += 1
		}
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		let explosion = SKEmitterNode(fileNamed: "explosion")!
		explosion.position = player.position
		addChild(explosion)
		
		player.removeFromParent()
		isGameOver = true
	}
	
	@objc private func createEnemy() {
		guard let enemy = items.randomElement() else {
			return
		}
		
		let sprite = SKSpriteNode(imageNamed: enemy)
		sprite.position = CGPoint(x: 1024, y: Int.random(in: 50...736))
		sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
		sprite.physicsBody?.categoryBitMask = 1
		sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
		sprite.physicsBody?.angularVelocity = CGFloat.pi * 2
		sprite.physicsBody?.linearDamping = 0
		sprite.physicsBody?.angularDamping = 0
		addChild(sprite)
	}
}
