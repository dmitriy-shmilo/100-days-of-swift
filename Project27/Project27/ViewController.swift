//
//  ViewController.swift
//  Project27
//
//  Created by Dmitriy Shmilo on 12.10.2021.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet private var imageView: UIImageView!
	private var drawType = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		drawRectangle()
	}

	private func drawRectangle() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
		let img = renderer.image { ctx in
			let rect = CGRect(x: 10, y: 10, width: 492, height: 492)
			ctx.cgContext.setFillColor(UIColor.red.cgColor)
			ctx.cgContext.setStrokeColor(UIColor.blue.cgColor)
			ctx.cgContext.setLineWidth(10)

			ctx.cgContext.addRect(rect)
			ctx.cgContext.drawPath(using: .fillStroke)
		}

		imageView.image = img
	}

	private func drawCircle() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
		let img = renderer.image { ctx in
			let rect = CGRect(x: 10, y: 10, width: 492, height: 492)
			ctx.cgContext.setFillColor(UIColor.red.cgColor)
			ctx.cgContext.setStrokeColor(UIColor.blue.cgColor)
			ctx.cgContext.setLineWidth(10)

			ctx.cgContext.addEllipse(in: rect)
			ctx.cgContext.drawPath(using: .fillStroke)
		}

		imageView.image = img
	}

	private func drawCheckerboard() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
		let img = renderer.image { ctx in
			ctx.cgContext.setFillColor(UIColor.red.cgColor)

			for row in 0..<8 {
				for col in 0..<8 {
					if (row + col).isMultiple(of: 2) {
						ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
					}
				}
			}
		}

		imageView.image = img
	}

	private func drawRotatedSquares() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
		let img = renderer.image { ctx in
			ctx.cgContext.translateBy(x: 256, y: 256)
			let rotations = 16
			let angle = Double.pi / Double(rotations)

			for _ in 0..<rotations {
				ctx.cgContext.rotate(by: angle)
				ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
			}

			ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
			ctx.cgContext.strokePath()
		}

		imageView.image = img
	}

	private func drawLines() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
		let img = renderer.image { ctx in
			var length: CGFloat = 256
			ctx.cgContext.translateBy(x: 256, y: 256)
			ctx.cgContext.rotate(by: .pi / 2)
			ctx.cgContext.move(to: CGPoint(x: length, y: 50))
			length *= 0.99

			for _ in 0..<255 {
				ctx.cgContext.rotate(by: .pi / 2)
				ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
				length *= 0.99
			}

			ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
			ctx.cgContext.strokePath()
		}

		imageView.image = img
	}

	private func drawImage() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
		let img = renderer.image { ctx in
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = .center
			let attrs: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 32),
				.paragraphStyle: paragraphStyle
			]
			let string = "Hello World"
			let attributedString = NSAttributedString(string: string, attributes: attrs)
			attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)

			let image = UIImage(named: "Image")
			image?.draw(at: CGPoint(x: 300, y: 150))
		}

		imageView.image = img
	}

	private func drawFace() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
		let img = renderer.image { ctx in
			ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
			ctx.cgContext.fillEllipse(in: CGRect(x: 6, y: 6, width: 500, height: 500))
			ctx.cgContext.setFillColor(UIColor.brown.cgColor)
			ctx.cgContext.fillEllipse(in: CGRect(x: 512 / 2 - 100, y: 512 / 2 - 75, width: 20, height: 45))
			ctx.cgContext.fillEllipse(in: CGRect(x: 512 / 2 + 80, y: 512 / 2 - 75, width: 20, height: 45))
			ctx.cgContext.fill(CGRect(x: 512 / 2 - 50, y: 512 / 2 + 50, width: 100, height: 10))
		}
		imageView.image = img
	}

	private func drawText() {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
		let img = renderer.image { ctx in
			let ctx = ctx.cgContext

			// T
			ctx.move(to: CGPoint(x: 0, y: 200))
			ctx.addLine(to: CGPoint(x: 100, y: 200))
			ctx.move(to: CGPoint(x: 50, y: 200))
			ctx.addLine(to: CGPoint(x: 50, y: 300))

			// W
			ctx.move(to: CGPoint(x: 100, y: 200))
			ctx.addLine(to: CGPoint(x: 120, y: 300))
			ctx.addLine(to: CGPoint(x: 140, y: 220))
			ctx.addLine(to: CGPoint(x: 160, y: 300))
			ctx.addLine(to: CGPoint(x: 180, y: 200))

			// I
			ctx.move(to: CGPoint(x: 200, y: 200))
			ctx.addLine(to: CGPoint(x: 220, y: 200))
			ctx.move(to: CGPoint(x: 210, y: 200))
			ctx.addLine(to: CGPoint(x: 210, y: 300))
			ctx.move(to: CGPoint(x: 200, y: 300))
			ctx.addLine(to: CGPoint(x: 220, y: 300))

			// N
			ctx.move(to: CGPoint(x: 250, y: 300))
			ctx.addLine(to: CGPoint(x: 250, y: 200))
			ctx.addLine(to: CGPoint(x: 300, y: 300))
			ctx.addLine(to: CGPoint(x: 300, y: 200))

			ctx.setLineWidth(2)
			ctx.strokePath()
		}
		imageView.image = img
	}

	@IBAction func buttonTapped(_ sender: UIButton) {
		drawType += 1

		switch drawType {
		case 0:
			drawRectangle()
		case 1:
			drawCircle()
		case 2:
			drawCheckerboard()
		case 3:
			drawRotatedSquares()
		case 4:
			drawLines()
		case 5:
			drawFace()
		case 6:
			drawText()
		default:
			break
		}
	}
}

