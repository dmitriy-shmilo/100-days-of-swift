//
//  GameScene.swift
//  Project18
//
//  Created by Dmitriy Shmilo on 10.09.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
	
	static let ClipSize = 6
	static let MaxTime: TimeInterval = 6.0

	var currentClip = ClipSize
	var isGameOver = false
	var startTime: TimeInterval!
	var timeLeft = TimeInterval() {
		didSet {
			timerLabel.text = "Time: \(Int(timeLeft))"
		}
	}
	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

	var bulletNodes = [BulletNode]()
	var timerLabel: SKLabelNode!
	var scoreLabel: SKLabelNode!
	var gameOverLabel: SKLabelNode!
	var tickAction: SKAction!
	
	
	override func didMove(to view: SKView) {
		let sequence = SKAction.sequence([
			SKAction.wait(forDuration: 0.5),
			SKAction.run { [unowned self] in
				tick()
			}
		])
		tickAction = SKAction.repeatForever(sequence)
		run(tickAction)
		
		timerLabel = SKLabelNode(fontNamed: "Papyrus")
		timerLabel.horizontalAlignmentMode = .right
		timerLabel.position = CGPoint(x: size.width - 100.0, y: size.height - 100.0)
		addChild(timerLabel)
		
		scoreLabel = SKLabelNode(fontNamed: "Papyrus")
		scoreLabel.horizontalAlignmentMode = .right
		scoreLabel.position = CGPoint(x: size.width - 100.0, y: size.height - 50.0)
		addChild(scoreLabel)
		
		gameOverLabel = SKLabelNode(fontNamed: "Papyrus")
		gameOverLabel.text = "Game Over"
		gameOverLabel.fontSize = 80
		gameOverLabel.horizontalAlignmentMode = .center
		gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
		
		score = 0
		
		bulletNodes = (0...5).map { i in
			let node = BulletNode()
			node.position = CGPoint(x: 50.0 + CGFloat(i) * 50.0, y: size.height - 100.0)
			return node
		}
		bulletNodes.forEach {
			addChild($0)
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		if startTime == nil {
			startTime = currentTime
		}
		timeLeft = Self.MaxTime - currentTime + startTime
		
		if timeLeft <= 0 {
			timeLeft = 0
			removeAllActions()
			
			if !isGameOver {
				addChild(gameOverLabel)
				isGameOver = true
			}
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first, !isGameOver else {
			return
		}
		
		if nodes(at: touch.location(in: self)).contains(where: { $0 is BulletNode }) {
			currentClip = Self.ClipSize
			bulletNodes.forEach { $0.reload() }
			return
		}
		
		if currentClip <= 0 {
			return
		}

		currentClip -= 1
		bulletNodes[currentClip].use()
		
		nodes(at: touch.location(in: self))
			.compactMap { $0 as? TargetNode }
			.forEach{
				$0.hit()
				score += $0.points
			}
	}
	
	private func tick() {
		let node1 = TargetNode(isGood: Bool.random(), moveTo: size.width + 100, duration: 4.0, points: 1)
		node1.start(at: CGPoint(x: -32, y: size.height / 2 - 300))
		addChild(node1)
		
		let node2 = TargetNode(isGood: Bool.random(), moveTo: -100, duration: 2.0, points: 3)
		node2.start(at: CGPoint(x: size.width + 32, y: size.height / 2 - 100))
		addChild(node2)
		
		let node3 = TargetNode(isGood: Bool.random(), moveTo: size.width + 100, duration: 3.0, points: 2)
		node3.start(at: CGPoint(x: -32, y: size.height / 2 + 100))
		addChild(node3)
	}
}
