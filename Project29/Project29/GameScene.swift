//
//  GameScene.swift
//  Project29
//
//  Created by Dmitriy Shmilo on 15.10.2021.
//

import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
	case banana = 1
	case building = 2
	case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	private static let maxScore = 3

	weak var viewController: GameViewController?
	private var buildings = [BuildingNode]()
	private var player1: SKSpriteNode!
	private var player2: SKSpriteNode!
	private var banana: SKSpriteNode!

	private var currentPlayer = 0
	private var p1Score = 0
	private var p2Score = 0

	override func didMove(to view: SKView) {
		backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
		reset()
		physicsWorld.contactDelegate = self
	}

	override func update(_ currentTime: TimeInterval) {
		guard banana != nil else {
			return
		}

		if abs(banana.position.y) > 1000 {
			banana.removeFromParent()
			banana = nil
			changePlayer()
		}
	}

	func didBegin(_ contact: SKPhysicsContact) {
		let firstBody: SKPhysicsBody
		let secondBody: SKPhysicsBody

		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}

		guard let firstNode = firstBody.node else {
			return

		}
		guard let secondNode = secondBody.node else {
			return

		}

		if firstNode.name == "banana" && secondNode.name == "building" {
			bananaHit(building: secondNode, atPoint: contact.contactPoint)
		}

		if firstNode.name == "banana" && secondNode.name == "player1" {
			destroy(player: player1)
		}

		if firstNode.name == "banana" && secondNode.name == "player2" {
			destroy(player: player2)
		}
	}

	func launch(angle: Int, velocity: Int) {
		let speed = Double(velocity) / 10.0
		let radians = Double(angle) * Double.pi / 180.0

		if banana != nil {
			banana.removeFromParent()
			banana = nil
		}

		banana = SKSpriteNode(imageNamed: "banana")
		banana.name = "banana"
		banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
		banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
		banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
		banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
		banana.physicsBody?.usesPreciseCollisionDetection = true
		addChild(banana)

		if currentPlayer == 0 {
			banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
			banana.physicsBody?.angularVelocity = -20

			let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
			let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
			let pause = SKAction.wait(forDuration: 0.15)
			let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
			player1.run(sequence)

			let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
			banana.physicsBody?.applyImpulse(impulse)
		} else {
			banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
			banana.physicsBody?.angularVelocity = 20

			let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
			let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
			let pause = SKAction.wait(forDuration: 0.15)
			let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
			player2.run(sequence)

			let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
			banana.physicsBody?.applyImpulse(impulse)
		}
	}

	private func createPlayers() {
		player1 = SKSpriteNode(imageNamed: "player")
		player1.name = "player1"
		player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
		player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
		player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
		player1.physicsBody?.isDynamic = false

		let player1Building = buildings[1]
		player1.position = CGPoint(
			x: player1Building.position.x,
			y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2)
		)
		addChild(player1)

		player2 = SKSpriteNode(imageNamed: "player")
		player2.name = "player2"
		player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
		player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
		player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
		player2.physicsBody?.isDynamic = false

		let player2Building = buildings[buildings.count - 2]
		player2.position = CGPoint(
			x: player2Building.position.x,
			y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2)
		)
		addChild(player2)
	}

	private func createBuildings() {
		var x: CGFloat = -15

		while x < 1024 {
			let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
			x += size.width + 2

			let node = BuildingNode(color: .red, size: size)
			node.position = CGPoint(x: x - size.width / 2, y: size.height / 2)
			node.setup()
			addChild(node)

			buildings.append(node)
		}
	}

	private func destroy(player: SKNode) {
		if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
			explosion.position = player.position
			addChild(explosion)
		}

		if player.name == "player1" {
			p2Score += 1
			viewController?.updateScore(p2Score, for: 1)
		} else {
			p1Score += 1
			viewController?.updateScore(p1Score, for: 0)
		}

		player.removeFromParent()
		banana.removeFromParent()

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
			guard let self = self else {
				return
			}

			if self.p1Score >= Self.maxScore || self.p2Score >= Self.maxScore {
				if let scene = SKScene(fileNamed: "GameOverScene") as? GameOverScene {
					self.view?.presentScene(scene, transition: .crossFade(withDuration: 0.25))
				}
			} else {
				self.changePlayer()
				self.reset()
			}
		}
	}

	private func changePlayer() {
		currentPlayer = (currentPlayer + 1) % 2
		viewController?.activatePlayer(number: currentPlayer)
		updateWind()
	}

	private func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
		guard let building = building as? BuildingNode else {
			return
		}
		let buildingLocation = convert(contactPoint, to: building)
		building.hit(at: buildingLocation)

		if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
			explosion.position = contactPoint
			addChild(explosion)
		}

		banana.name = ""
		banana.removeFromParent()
		banana = nil

		changePlayer()
	}

	private func updateWind() {
		let wind = CGFloat.random(in: -10...10)
		physicsWorld.gravity = CGVector(dx: wind, dy: -9.8)
		viewController?.updateWind(wind)
	}

	private func reset() {
		buildings.forEach {
			$0.removeFromParent()
		}
		buildings.removeAll()
		player1?.removeFromParent()
		player2?.removeFromParent()


		createBuildings()
		createPlayers()
		updateWind()
		viewController?.updateScore(p1Score, for: 0)
		viewController?.updateScore(p2Score, for: 1)
		viewController?.activatePlayer(number: currentPlayer)
	}
}
