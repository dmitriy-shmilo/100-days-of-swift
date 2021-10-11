//
//  GameScene.swift
//  Project26
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import SpriteKit
import GameplayKit
import CoreMotion

enum CollisionTypes: UInt32 {
	case player = 0x1
	case wall = 0x10
	case star = 0x100
	case vortex = 0x1000
	case finish = 0x10000
	case portal = 0x100000
}

class GameScene: SKScene, SKPhysicsContactDelegate {

	private static let totalLevels = 3

	private var motionManager: CMMotionManager!
	private var player: SKSpriteNode!
	private var lastTouchPosition: CGPoint?
	private var scoreLabel: SKLabelNode!

	private var isGameOver = false
	private var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	private var currentLevel = 0

	override func didMove(to view: SKView) {
		motionManager = CMMotionManager()
		motionManager.startDeviceMotionUpdates()

		physicsWorld.gravity = .zero
		physicsWorld.contactDelegate = self

		scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode

		loadLevel(levelName: "level\(currentLevel)")
		loadPlayer()
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let location = touches.first?.location(in: self) else {
			return
		}
		lastTouchPosition = location
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let location = touches.first?.location(in: self) else {
			return
		}
		lastTouchPosition = location
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		lastTouchPosition = nil
	}

	override func update(_ currentTime: TimeInterval) {
		guard !isGameOver else {
			return
		}

		#if targetEnvironment(simulator)
		if let touch = lastTouchPosition {
			let diff = CGPoint(x: touch.x - player.position.x, y: touch.y - player.position.y)
			physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
		} else {
			physicsWorld.gravity = .zero
		}
		#else
		if let data = motionManager.accelerometerData {
			physicsWorld.gravity = CGVector(dx: data.acceleration.y * -50, dy: data.acceleration.x * 50)
		}
		#endif
	}

	func didBegin(_ contact: SKPhysicsContact) {
		guard let nodeA = contact.bodyA.node else { return }
		guard let nodeB = contact.bodyB.node else { return }

		if nodeA == player {
			playerCollided(with: nodeB)
		} else if nodeB == player {
			playerCollided(with: nodeA)
		}
	}

	// MARK: - Collision handling

	private func playerCollided(with node: SKNode) {
		guard !isGameOver else {
			return
		}

		if node.name == "vortex" {
			touchVortex(node: node)
		} else if node.name == "star" {
			touchStar(node: node)
		} else if node.name == "finish" {
			touchFinish(node: node)
		} else if node.name == "portal" {
			touchPortal(node: node)
		}
	}

	private func touchVortex(node: SKNode) {
		player.physicsBody?.isDynamic = false
		isGameOver = true
		score -= 1

		let move = SKAction.move(to: node.position, duration: 0.25)
		let scale = SKAction.scale(to: 0.0001, duration: 0.25)
		let remove = SKAction.removeFromParent()
		let sequence = SKAction.sequence([move, scale, remove])

		player.run(sequence) { [weak self] in
			self?.loadPlayer()
			self?.isGameOver = false
		}
	}

	private func touchStar(node: SKNode) {
		node.removeFromParent()
		score += 1
	}

	private func touchFinish(node: SKNode) {
		currentLevel += 1

		let move = SKAction.move(to: node.position, duration: 0.25)
		let scale = SKAction.scale(to: 0.0001, duration: 0.25)
		let remove = SKAction.removeFromParent()
		let sequence = SKAction.sequence([move, scale, remove])

		player.run(sequence) { [weak self] in
			guard let self = self else {
				return
			}
			if self.currentLevel < Self.totalLevels {
				self.children
					.filter { $0 != self.scoreLabel }
					.forEach { $0.removeFromParent() }
				self.loadLevel(levelName: "level\(self.currentLevel)")
				self.loadPlayer()
			} else {
				self.isGameOver = true
			}
		}
	}

	private func touchPortal(node: SKNode) {
		if let portal = self.children.first(where: { $0 != node && $0.name == "portal" }) {
			isGameOver = true
			let move = SKAction.move(to: node.position, duration: 0.25)
			let scale = SKAction.scale(to: 0.0001, duration: 0.25)
			let teleport = SKAction.move(to: portal.position, duration: 0.25)
			let descale = SKAction.scale(to: 1.0, duration: 0.25)
			let removePortals = SKAction.run {
				node.removeFromParent()
				portal.removeFromParent()
			}
			let sequence = SKAction.sequence([move, scale, teleport, descale, removePortals])
			player.run(sequence) { [weak self] in
				self?.isGameOver = false
			}
		}
	}

	// MARK: - Level loading
	private func loadLevel(levelName: String) {
		guard let levelUrl = Bundle.main.url(forResource: levelName, withExtension: "txt") else {
			fatalError("Can't find \(levelName)")
		}
		
		guard let levelData = try? String(contentsOf: levelUrl) else {
			fatalError("Can't load \(levelName)")
		}
		
		let lines = levelData.components(separatedBy: "\n")
		
		for (row, line) in lines.reversed().enumerated() {
			for (column, letter) in line.enumerated() {
				let position = CGPoint(x: 64 * column + 32, y: 64 * row + 32)
				switch letter {
				case "x":
					createBlock(at: position)
				case "v":
					createVortex(at: position)
				case "s":
					createStar(at: position)
				case "f":
					createFinish(at: position)
				case "p":
					createPortal(at: position)
				case " ":
					break
				default:
					fatalError("Unknown symbol \(letter) at \(line):\(column)")
				}
			}
		}
	}

	private func createBlock(at position: CGPoint) {
		let node = SKSpriteNode(imageNamed: "block")
		node.position = position

		node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
		node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
		node.physicsBody?.isDynamic = false
		addChild(node)
	}

	private func createStar(at position: CGPoint) {
		let node = SKSpriteNode(imageNamed: "star")
		node.name = "star"
		node.position = position

		node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
		node.physicsBody?.isDynamic = false
		node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
		node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		node.physicsBody?.collisionBitMask = 0
		addChild(node)
	}

	private func createFinish(at position: CGPoint) {
		let node = SKSpriteNode(imageNamed: "finish")
		node.name = "finish"
		node.position = position

		node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
		node.physicsBody?.isDynamic = false
		node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
		node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		node.physicsBody?.collisionBitMask = 0
		addChild(node)
	}

	private func createVortex(at position: CGPoint) {
		let node = SKSpriteNode(imageNamed: "vortex")
		node.name = "vortex"
		node.position = position
		node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1.0)))

		node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
		node.physicsBody?.isDynamic = false
		node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
		node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		node.physicsBody?.collisionBitMask = 0
		addChild(node)
	}

	private func createPortal(at position: CGPoint) {
		let node = SKSpriteNode(imageNamed: "vortex")
		node.name = "portal"
		node.color = .green
		node.colorBlendFactor = 1.0
		node.position = position
		node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1.0)))

		node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
		node.physicsBody?.isDynamic = false
		node.physicsBody?.categoryBitMask = CollisionTypes.portal.rawValue
		node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		node.physicsBody?.collisionBitMask = 0
		addChild(node)
	}

	private func loadPlayer() {
		player = SKSpriteNode(imageNamed: "player")
		player.position = CGPoint(x:96, y: 672)
		player.zPosition = 1

		player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
		player.physicsBody?.allowsRotation = false
		player.physicsBody?.linearDamping = 0.5
		player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue
			| CollisionTypes.vortex.rawValue
			| CollisionTypes.finish.rawValue
			| CollisionTypes.portal.rawValue
		player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
		addChild(player)
	}

}
