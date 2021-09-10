//
//  GameScene.swift
//  Project14
//
//  Created by Dmitriy Shmilo on 09.09.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
	
	static let MaxRoundCount = 30
	private var roundCount = 0
	private var popupTime = 0.85
	private var slots = [WhackSlotNode]()
	private var gameScore: SKLabelNode!
	private var score = 0 {
		didSet {
			gameScore.text = "Score \(score)"
		}
	}
	
	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "whackBackground.png")
		background.position = CGPoint(x: size.width / 2, y: size.height / 2)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)
		
		gameScore = SKLabelNode(fontNamed: "Chalkduster")
		gameScore.text = "Score: 0"
		gameScore.position = CGPoint(x: 8, y: 8)
		gameScore.horizontalAlignmentMode = .left
		gameScore.fontSize = 48
		addChild(gameScore)
		
		for j in 0..<4 {
			for i in 0..<(j.isMultiple(of: 2) ? 5 : 4) {
				createSlot(at: CGPoint(x: i * 170 + (j.isMultiple(of: 2) ? 100 : 180), y: 140 + 90 * j))
			}
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
			self?.createEnemies()
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		
		let location = touch.location(in: self)
		let nodes = nodes(at: location)
		
		for node in nodes {
			guard let parent = node.parent?.parent as? WhackSlotNode else {
				continue
			}
			if !parent.isVisible || parent.isHit {
				continue
			}
			
			parent.hit()
			node.xScale = 0.85
			node.yScale = 0.85

			if node.name == "charGood" {
				score += 1
				run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
			} else if node.name == "charEvil" {
				score -= 5
				run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
			}
		}
	}
	
	
	private func createSlot(at position: CGPoint) {
		let slot = WhackSlotNode()
		slot.configure(at: position)
		addChild(slot)
		slots.append(slot)
	}
	
	private func createEnemies() {
		roundCount += 1
		
		if roundCount >= Self.MaxRoundCount {
			slots.forEach { $0.hide() }
			let gameOver = SKSpriteNode(imageNamed: "gameOver")
			gameOver.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
			gameOver.zPosition = 1
			
			let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
			scoreLabel.fontSize = 80
			scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 60)
			scoreLabel.text = "Your score: \(score)"

			addChild(gameOver)
			addChild(scoreLabel)
			return
		}

		popupTime *= 0.991
		
		slots.shuffle()
		slots[0].show(hideTime: popupTime)
		if Int.random(in: 0...12) > 4 {
			slots[1].show(hideTime: popupTime)
		}
		if Int.random(in: 0...12) > 8 {
			slots[2].show(hideTime: popupTime)
		}
		if Int.random(in: 0...12) > 10 {
			slots[3].show(hideTime: popupTime)
		}
		if Int.random(in: 0...12) > 11 {
			slots[4].show(hideTime: popupTime)
		}
		
		let minDelay = popupTime / 2
		let maxDelay = popupTime * 2
		let delay = Double.random(in: minDelay...maxDelay)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
			self?.createEnemies()
		}
	}
}
