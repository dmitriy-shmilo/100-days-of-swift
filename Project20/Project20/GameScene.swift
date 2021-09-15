//
//  GameScene.swift
//  Project20
//
//  Created by Dmitriy Shmilo on 13.09.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
	private static let MaxLaunches = 5

	private var currentLaunch = 0
	private var gameTimer: Timer?
	private var fireworks = [SKNode]()
	private var scoreLabel: SKLabelNode!

	private let leftEdge = -22
	private let bottomEdge = -22
	private let rightEdge = 1024 + 22

	private var score = 0 {
		didSet {
			scoreLabel?.text = "Score: \(score)"
		}
	}

	override func didMove(to view: SKView) {
		gameTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { [weak self] _ in
			self?.launchFireworks()
		}
		
		if let label = childNode(withName: "scoreLabel") as? SKLabelNode {
			scoreLabel = label
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		handleTouches(touches: touches)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		handleTouches(touches: touches)
	}
	
	override func update(_ currentTime: TimeInterval) {
		for (index, node) in fireworks.enumerated().reversed() {
			if node.position.y >= 900 {
				fireworks.remove(at: index)
				node.removeFromParent()
			}
		}
	}
	
	func explodeFireworks() {
		var numExploded = 0
		
		for (i, node) in fireworks.enumerated().reversed() {
			guard let firework = node.children.first as? SKSpriteNode else {
				continue;
			}
			
			if firework.name == "selected" {
				explode(firework: firework)
				fireworks.remove(at: i)
				numExploded += 1
			}
		}
		
		switch numExploded {
		case 0:
			break
		case 1:
			score += 200
		case 2:
			score += 500
		case 3:
			score += 1000
		case 4:
			score += 2000
		default:
			score += 4000
		}
	}
	private func explode(firework: SKNode) {
		if let emitter = SKEmitterNode(fileNamed: "explode"), let parent = firework.parent {
			emitter.position = parent.position
			let wait = SKAction.wait(forDuration: 0.5)
			let remove = SKAction.removeFromParent()
			emitter.run(SKAction.sequence([wait, remove]))
			addChild(emitter)
			parent.removeFromParent()
		}
	}
	
	private func handleTouches(touches: Set<UITouch>) {
		guard let touch = touches.first else {
			return
		}
		
		let location = touch.location(in: self)
		let nodes = nodes(at: location)
		
		for case let node as SKSpriteNode in nodes {
			guard node.name == "firework" else {
				continue
			}
			
			for parent in fireworks {
				guard let firework = parent.children.first as? SKSpriteNode else {
					continue
				}
				
				if firework.name == "selected" && firework.color != node.color {
					firework.name = "firework"
					firework.colorBlendFactor = 0.75
				}
				
			}
			node.name = "selected"
			node.colorBlendFactor = 0
		}
	}
	private func launchFireworks() {
		let movementAmount: CGFloat = 1800.0
		
		currentLaunch += 1
		if currentLaunch >= Self.MaxLaunches {
			gameTimer?.invalidate()
		}

		switch Int.random(in: 0...3) {
			case 0:
				createFirework(xMovement: 0, x: 512, y: bottomEdge)
				createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
				createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
				createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
				createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)

			case 1:
				createFirework(xMovement: 0, x: 512, y: bottomEdge)
				createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
				createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
				createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
				createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

			case 2:
				createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
				createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
				createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
				createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
				createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

			case 3:
				createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
				createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
				createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
				createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
				createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

			default:
				break
			}
	}
	
	private func createFirework(xMovement: CGFloat, x: Int, y: Int) {
		let node = SKNode()
		node.position = CGPoint(x: x, y: y)
		
		let firework = SKSpriteNode(imageNamed: "rocket")
		firework.colorBlendFactor = 0.75
		firework.name = "firework"
		node.addChild(firework)
		
		switch Int.random(in: 0...3) {
		case 0:
			firework.color = .cyan
		case 1:
			firework.color = .green
		default:
			firework.color = .red
		}
		
		let path = UIBezierPath()
		path.move(to: .zero)
		path.addLine(to: CGPoint(x: xMovement, y: 1000))
		
		let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
		node.run(move)
		
		if let emitter = SKEmitterNode(fileNamed: "fuse") {
			emitter.position = CGPoint(x: 0, y: -22)
			node.addChild(emitter)
		}
		
		fireworks.append(node)
		addChild(node)
	}
}
