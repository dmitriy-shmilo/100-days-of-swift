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
		default:
			break
		}
	}
}

