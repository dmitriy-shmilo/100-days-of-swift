//
//  ViewController.swift
//  Project15
//
//  Created by Dmitriy Shmilo on 10.09.2021.
//

import UIKit

class ViewController: UIViewController {
	
	private var imageView: UIImageView!
	private var currentAnimation = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageView = UIImageView(image: UIImage(named: "penguin"))
		imageView.center = view.center
		view.addSubview(imageView)
	}

	@IBAction func tap(_ sender: UIButton) {
		sender.isHidden = true
		
		UIView.animate(
			withDuration: 1,
			delay: 0,
			usingSpringWithDamping: 0.5,
			initialSpringVelocity: 5.0,
			options: [],
			animations: {
				switch self.currentAnimation {
				case 0:
					self.imageView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
					break
				case 2:
					self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)
					break
				case 4:
					self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
				case 1, 3, 5:
					self.imageView.transform = CGAffineTransform.identity
					break
				case 6:
					self.imageView.alpha = 0.1
					self.imageView.backgroundColor = .green
					break
				case 7:
					self.imageView.alpha = 1.0
					self.imageView.backgroundColor = .clear
				default:
					break
				}
			}) { finished in
			sender.isHidden = false
		}
		
		currentAnimation += 1
		currentAnimation %= 8
	}

}

