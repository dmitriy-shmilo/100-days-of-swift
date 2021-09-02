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
	
	var countries = [String]()
	var score = 0
	var correctAnswer = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		
		[button1, button2, button3].forEach {
			$0?.layer.borderWidth = 1.0
			$0?.layer.borderColor = UIColor.lightGray.cgColor
		}
		
		countries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
		
		
		askQuestion()
	}
	
	private func askQuestion(action: UIAlertAction! = nil) {
		countries.shuffle()
		
		button1.setImage(UIImage(named: countries[0]), for: .normal)
		button2.setImage(UIImage(named: countries[1]), for: .normal)
		button3.setImage(UIImage(named: countries[2]), for: .normal)
		
		correctAnswer = Int.random(in: 0...2)
		title = countries[correctAnswer].uppercased()
	}

	@IBAction func buttonTapped(_ sender: UIButton) {
		var title = "Correct"
		if sender.tag == correctAnswer {
			score += 1
		} else {
			title = "Wrong"
			score -= 1
		}
		
		let alert = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
		present(alert, animated: true)
	}

}

