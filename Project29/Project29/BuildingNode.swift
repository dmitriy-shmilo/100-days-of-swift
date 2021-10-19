//
//  BuildingNode.swift
//  Project29
//
//  Created by Dmitriy Shmilo on 15.10.2021.
//

import UIKit
import SpriteKit

class BuildingNode: SKSpriteNode {

	private var currentImage: UIImage!

	func setup() {
		name = "building"
		currentImage = drawBuilding(size: size)
		texture = SKTexture(image: currentImage)

		configurePhysics()
	}

	func hit(at point: CGPoint) {
		let point = CGPoint(x: point.x + size.width / 2, y: abs(point.y - size.height / 2))
		let img = UIGraphicsImageRenderer(size: size).image { ctx in
			let ctx = ctx.cgContext
			currentImage.draw(at: .zero)
			ctx.addEllipse(in: CGRect(x: point.x - 32, y: point.y - 32, width: 64, height: 64))
			ctx.setBlendMode(.clear)
			ctx.fillPath()
		}

		texture = SKTexture(image: img)
		currentImage = img
		configurePhysics()
	}

	private func configurePhysics() {
		let body = SKPhysicsBody(texture: texture!, size: size)
		body.isDynamic = false
		body.categoryBitMask = CollisionTypes.building.rawValue
		body.contactTestBitMask = CollisionTypes.banana.rawValue
		physicsBody = body
	}

	private func drawBuilding(size: CGSize) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { ctx in
			let ctx = ctx.cgContext
			let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

			let color: UIColor
			switch Int.random(in: 0...2) {
			case 0:
				color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
			case 1:
				color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
			default:
				color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
			}

			color.setFill()
			ctx.fill(rect)

			let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
			let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)

			for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
				for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
					if Bool.random() {
						lightOnColor.setFill()
					} else {
						lightOffColor.setFill()
					}

					ctx.fill(CGRect(x: col, y: row, width: 15, height: 20))
				}
			}
		}
	}
}

