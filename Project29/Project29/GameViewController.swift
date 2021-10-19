//
//  GameViewController.swift
//  Project29
//
//  Created by Dmitriy Shmilo on 15.10.2021.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

	var scene: GameScene!

	@IBOutlet private var angleSlider: UISlider!
	@IBOutlet private var angleLabel: UILabel!
	@IBOutlet private var velocitySlider: UISlider!
	@IBOutlet private var velocityLabel: UILabel!
	@IBOutlet private var launchButton: UIButton!
	@IBOutlet private var playerLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		if let view = self.view as! SKView? {
			// Load the SKScene from 'GameScene.sks'
			if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
				// Set the scale mode to scale to fit the window
				scene.scaleMode = .aspectFill

				// Present the scene
				view.presentScene(scene)
				self.scene = scene
				scene.viewController = self
			}

			view.ignoresSiblingOrder = true

			view.showsFPS = true
			view.showsNodeCount = true
		}

		angleChanged(angleSlider)
		velocityChanged(velocitySlider)
	}

	override var shouldAutorotate: Bool {
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return .allButUpsideDown
		} else {
			return .all
		}
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	func activatePlayer(number: Int) {
		switch number {
		case 0:
			playerLabel.text = "PLAYER ONE"
		case 1:
			playerLabel.text = "PLAYER TWO"
		default:
			fatalError("Unknown player number")
		}

		angleSlider.isHidden = false
		angleLabel.isHidden = false

		velocitySlider.isHidden = false
		velocityLabel.isHidden = false

		launchButton.isHidden = false
	}

	@IBAction private func angleChanged(_ sender: UISlider) {
		angleLabel.text = "\(Int(angleSlider.value))°"
	}

	@IBAction private func velocityChanged(_ sender: UISlider) {
		velocityLabel.text = "\(Int(velocitySlider.value))"
	}

	@IBAction private func launchPressed(_ sender: UIButton) {
		angleSlider.isHidden = true
		angleLabel.isHidden = true

		velocitySlider.isHidden = true
		velocityLabel.isHidden = true

		launchButton.isHidden = true

		scene.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
	}
}
