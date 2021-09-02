//
//  ViewController.swift
//  Project2
//
//  Created by Dmitriy Shmilo on 02.09.2021.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet weak var button1: UIButton!
	@IBOutlet weak var button2: UIButton!
	@IBOutlet weak var button3: UIButton!
	
	let totalQuestionCount = 10

	private var countries = [String]()
	private var score = 0
	private var correctAnswer = 0
	private var currentQuestionIndex = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		
		[button1, button2, button3].forEach {
			$0?.layer.borderWidth = 1.0
			$0?.layer.borderColor = UIColor.lightGray.cgColor
		}
		
		countries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(showScoreTapped))
		
		newGame()
	}
	
	private func newGame(action: UIAlertAction! = nil) {
		currentQuestionIndex = 0
		score = 0

		askQuestion()
	}
	
	private func askQuestion(action: UIAlertAction! = nil) {
		countries.shuffle()
		
		button1.setImage(UIImage(named: countries[0]), for: .normal)
		button2.setImage(UIImage(named: countries[1]), for: .normal)
		button3.setImage(UIImage(named: countries[2]), for: .normal)
		
		correctAnswer = Int.random(in: 0...2)
		title = "Guess: \(countries[correctAnswer].uppercased()) | Score: \(score)"
	}
	
	private func gameOver() {
		let alert = UIAlertController(title: "Game Over", message: "Your final score is \(score)", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "New Game", style: .default, handler: newGame))
		present(alert, animated: true)
	}
	
	@objc private func showScoreTapped() {
		let alert = UIAlertController(title: "Your score", message: "\(score)/\(totalQuestionCount)", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in }))
		present(alert, animated: true)
	}

	@IBAction func buttonTapped(_ sender: UIButton) {
		currentQuestionIndex += 1
		
		if sender.tag == correctAnswer {
			score += 1
			
			if currentQuestionIndex >= totalQuestionCount {
				gameOver()
			} else {
				askQuestion()
			}
		} else {
			let alert = UIAlertController(title: "Wrong", message: "That's \(countries[sender.tag].capitalized)", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Continue", style: .default) { [self] a in
				if currentQuestionIndex >= totalQuestionCount {
					gameOver()
				} else {
					askQuestion(action: a)
				}
			})
			present(alert, animated: true)
			score -= 1
		}
	}
}

