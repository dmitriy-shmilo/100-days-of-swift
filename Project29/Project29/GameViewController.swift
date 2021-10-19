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
	@IBOutlet private var player1ScoreLabel: UILabel!
	@IBOutlet private var player2ScoreLabel: UILabel!
	@IBOutlet private var windLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		if let view = self.view as! SKView? {
			if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
				scene.scaleMode = .aspectFill

				self.scene = scene
				scene.viewController = self
				view.presentScene(scene)

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

	func updateWind(_ wind: CGFloat) {
		windLabel.text = "Wind: \(wind > 0 ? ">" : "<") \(Int(wind * 10))"
	}

	func updateScore(_ score: Int, for player: Int) {
		guard 0...1 ~= player else {
			fatalError("Incorrect player number: \(player)")
		}

		if player == 0 {
			player1ScoreLabel.text = "P1: \(score)"
		} else if player == 1 {
			player2ScoreLabel.text = "P2: \(score)"
		}
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
