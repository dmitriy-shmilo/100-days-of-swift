//
//  GameScene.swift
//  Project23
//
//  Created by Dmitriy Shmilo on 14.09.2021.
//

import SpriteKit
import GameplayKit
import AVKit

enum ForceBomb {
	case never, always, random
}

enum SequenceType: CaseIterable {
	case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
	
	private static let EnemyAngularVelocityAmplitude: CGFloat = CGFloat.pi
	private static let EnemyVelocityMultiplier = 40
	private static let EnemyMinVelocity = 24
	private static let EnemyMaxVelocity = 32
	private static let EnemyPenguinChance = 6
	private static let EnemyFastPenguinChance = 3
	
	private var isGameOver = false
	private var lives = 3
	private var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

	private var scoreLabel: SKLabelNode!
	private var gameOverLabel: SKLabelNode!
	private var liveNodes = [SKSpriteNode]()
	private var foregroundSlice: SKShapeNode!
	private var backgroundSlice: SKShapeNode!
	private var slicePoints = [CGPoint]()
	private var activeEnemies = [SKSpriteNode]()
	
	private var isSwooshPlaying = false
	private var bombSoundEffect: AVAudioPlayer?
	
	private var popupTime = 0.9
	private var sequence = [SequenceType]()
	private var sequencePosition = 0
	private var chainDelay = 3.0
	private var nextSequenceQueued = true

	override func didMove(to view: SKView) {
		physicsWorld.gravity = CGVector(dx: 0, dy: -6)
		physicsWorld.speed = 0.85
		
		if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
			self.scoreLabel = scoreLabel
		}
		
		if let gameOverLabel = childNode(withName: "gameOverLabel") as? SKLabelNode {
			self.gameOverLabel = gameOverLabel
			gameOverLabel.isHidden = true
		}
		
		if let life1 = childNode(withName: "life1") as? SKSpriteNode,
		   let life2 = childNode(withName: "life2") as? SKSpriteNode,
		   let life3 = childNode(withName: "life3") as? SKSpriteNode {
			liveNodes = [life1, life2, life3]
		}
		
		backgroundSlice = SKShapeNode()
		backgroundSlice.zPosition = 2
		backgroundSlice.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
		backgroundSlice.lineWidth = 9
		addChild(backgroundSlice)
		
		foregroundSlice = SKShapeNode()
		foregroundSlice.zPosition = 3
		foregroundSlice.strokeColor = .white
		foregroundSlice.lineWidth = 5
		addChild(foregroundSlice)
		
		sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]

		for _ in 0 ... 1000 {
			if let nextSequence = SequenceType.allCases.randomElement() {
				sequence.append(nextSequence)
			}
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
			self?.tossEnemies()
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		
		slicePoints.removeAll(keepingCapacity: true)
		slicePoints.append(touch.location(in: self))
		
		redrawSlices()
		
		foregroundSlice.removeAllActions()
		backgroundSlice.removeAllActions()
		
		foregroundSlice.alpha = 1.0
		backgroundSlice.alpha = 1.0
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		
		if !isSwooshPlaying {
			playSwoosh()
		}
		
		let location = touch.location(in: self)
		slicePoints.append(location)
		redrawSlices()
		
		let nodes = nodes(at: location)
		let disappear = SKAction.group([
			SKAction.scale(to: 0.001, duration: 0.2),
			SKAction.fadeOut(withDuration: 0.2)
		])
		
		for case let node as SKSpriteNode in nodes {
			switch node.name {
			case "fastEnemy":
				score += 2
				fallthrough
			case "enemy":
				if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
					emitter.position = node.position
					addChild(emitter)
				}
				
				node.name = ""
				node.physicsBody?.isDynamic = false
				
				node.run(SKAction.sequence([disappear, .removeFromParent()]))
				score += 1
				activeEnemies.removeAll(where: { $0 == node })
				run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
				
			case "bomb":
				guard let node = node.parent as? SKSpriteNode else {
					continue
				}
				
				if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
					emitter.position = node.position
					addChild(emitter)
				}
				
				node.name = ""
				node.physicsBody?.isDynamic = false
				node.run(SKAction.sequence([disappear, .removeFromParent()]))
				activeEnemies.removeAll(where: { $0 == node })
				
				run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
				endGame(outOfLives: false)
			default:
				break
			}
		}
		
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		backgroundSlice.run(SKAction.fadeOut(withDuration: 0.25))
		foregroundSlice.run(SKAction.fadeOut(withDuration: 0.25))
	}
	
	override func update(_ currentTime: TimeInterval) {
		if bombSoundEffect != nil && activeEnemies.contains(where: { $0.name == "bombContainer" }) {
			bombSoundEffect?.stop()
			bombSoundEffect = nil
		}
		
		if activeEnemies.count > 0 {
			for (index, node) in activeEnemies.enumerated().reversed() {
				
				if node.position.y < -140 {
					node.removeAllActions()
					
					if node.name == "enemy" {
						loseLife()
					}
					node.removeFromParent()
					activeEnemies.remove(at: index)
				}
			}
		} else {
			if !nextSequenceQueued {
				DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
					self?.tossEnemies()
				}

				nextSequenceQueued = true
			}
		}
	}
	
	private func loseLife() {
		lives -= 1
		
		run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
		let node = liveNodes[lives]
		node.texture = SKTexture(imageNamed: "sliceLifeGone")
		node.xScale = 1.3
		node.yScale = 1.3
		node.run(SKAction.scale(to: 1.0, duration: 0.1))
		
		if lives == 0 {
			endGame(outOfLives: true)
		}
	}

	private func endGame(outOfLives: Bool) {
		if isGameOver {
			return
		}
		
		isGameOver = true
		
		physicsWorld.speed = 0
		isUserInteractionEnabled = false
		bombSoundEffect?.stop()
		bombSoundEffect = nil
		
		if !outOfLives {
			liveNodes.forEach {
				$0.texture = SKTexture(imageNamed: "sliceLifeGone")
			}
		}
		
		gameOverLabel.isHidden = false
	}
	
	private func tossEnemies() {
		popupTime *= 0.991
		chainDelay *= 0.99
		physicsWorld.speed *= 1.02
		
		let sequenceType = sequence[sequencePosition]
		
		switch sequenceType {
			case .oneNoBomb:
				createEnemy(forceBomb: .never)

			case .one:
				createEnemy()

			case .twoWithOneBomb:
				createEnemy(forceBomb: .never)
				createEnemy(forceBomb: .always)

			case .two:
				createEnemy()
				createEnemy()

			case .three:
				createEnemy()
				createEnemy()
				createEnemy()

			case .four:
				createEnemy()
				createEnemy()
				createEnemy()
				createEnemy()

			case .chain:
				createEnemy()

				DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy() }
				DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy() }
				DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy() }
				DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy() }

			case .fastChain:
				createEnemy()

				DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy() }
				DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy() }
				DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy() }
				DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy() }
			}

			sequencePosition += 1
			nextSequenceQueued = false
	}
	
	private func createEnemy(forceBomb: ForceBomb = .random) {
		let enemy: SKSpriteNode
		let isBomb: Bool
		let isFast: Bool

		switch forceBomb {
		case .always:
			isBomb = true
			isFast = false
		case .never:
			isBomb = false
			isFast = false
		default:
			isBomb = Int.random(in: 0...Self.EnemyPenguinChance) == 0
			isFast = !isBomb && Int.random(in: 0...Self.EnemyFastPenguinChance) == 0
		}
		
		
		
		if isBomb {
			enemy = SKSpriteNode()
			enemy.name = "bombContainer"
			enemy.zPosition = 1
			
			let sprite = SKSpriteNode(imageNamed: "sliceBomb")
			sprite.name = "bomb"
			enemy.addChild(sprite)
			
			if bombSoundEffect != nil {
				bombSoundEffect!.stop()
				bombSoundEffect = nil
			}
			
			if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
				if let sound = try? AVAudioPlayer(contentsOf: path) {
					bombSoundEffect = sound
					sound.play()
				}
			}
			
			if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
				emitter.position = CGPoint(x: 76, y: 64)
				enemy.addChild(emitter)
			}
		} else {
			enemy = SKSpriteNode(imageNamed: "penguin")
			enemy.name = isFast ? "fastEnemy" : "enemy"
			run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
		}
		
		enemy.position = CGPoint(x: Int.random(in: 64...960), y: -128)
		let xVelocity: Int
		let yVelocity = Int.random(in: Self.EnemyMinVelocity...Self.EnemyMaxVelocity)

		switch enemy.position.x {
		case let x where x < 256:
			xVelocity = Int.random(in: 8...15)
			
		case let x where x < 512:
			xVelocity = Int.random(in: 3...5)
			
		case let x where x < 768:
			xVelocity = -Int.random(in: 3...5)
			
		default:
			xVelocity = -Int.random(in: 8...15)
		}
		
		enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
		enemy.physicsBody?.velocity = CGVector(
			dx: xVelocity * Self.EnemyVelocityMultiplier,
			dy: yVelocity * Self.EnemyVelocityMultiplier
		)
		enemy.physicsBody?.angularVelocity = CGFloat.random(
			in: -Self.EnemyAngularVelocityAmplitude...Self.EnemyAngularVelocityAmplitude)
		enemy.physicsBody?.collisionBitMask = 0
		
		if isFast {
			enemy.physicsBody?.angularVelocity *= CGFloat.random(in: 1.5...2.0)
			enemy.physicsBody?.velocity.dx *= CGFloat.random(in: 1.5...2.0)
			enemy.physicsBody?.velocity.dy *= CGFloat.random(in: 1.5...2.0)
		}
		
		
		addChild(enemy)
		activeEnemies.append(enemy)
	}

	private func playSwoosh() {
		isSwooshPlaying = true
		
		let name = "swoosh\(Int.random(in: 1...3)).caf"
		let action = SKAction.playSoundFileNamed(name, waitForCompletion: true)
		run(action) { [weak self] in
			self?.isSwooshPlaying = false
		}
	}
	
	private func redrawSlices() {
		if slicePoints.count < 2 {
			foregroundSlice.path = nil
			backgroundSlice.path = nil
		}
		
		if slicePoints.count > 12 {
			slicePoints.removeFirst(slicePoints.count - 12)
		}
		
		let path = UIBezierPath()
		path.move(to: slicePoints[0])
		
		for i in 1..<slicePoints.count {
			path.addLine(to: slicePoints[i])
		}
		
		foregroundSlice.path = path.cgPath
		backgroundSlice.path = path.cgPath
	}
}
