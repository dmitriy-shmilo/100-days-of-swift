//
//  ViewController.swift
//  Project9.1
//
//  Created by Dmitriy Shmilo on 05.09.2021.
//

import UIKit

class ViewController: UIViewController {
	
	let maxTries = 7

	@IBOutlet var scoreLabel: UILabel!
	@IBOutlet var wordLabel: UILabel!
	
	private var usedLetters = [Character]()
	private var word: String!
	private var score = 0 {
		didSet {
			DispatchQueue.main.async { [self] in
				scoreLabel.text = "\(score)"
			}
		}
	}
	

	override func viewDidLoad() {
		super.viewDidLoad()
		loadLevel()
	}

	@IBAction func promptLetter(_ sender: Any) {
		let alert = UIAlertController(title: "Enter a letter", message: nil, preferredStyle: .alert)
		alert.addTextField()
		alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [unowned self, weak alert] _ in
			if let letter = alert?.textFields?[0].text?.first {
				let letter = Character(letter.uppercased())
				submitLetter(letter: letter)
			}
		}))
		present(alert, animated: true)
	}
	
	private func loadLevel() {
		DispatchQueue.global(qos: .userInitiated).async { [self] in
			if let url = Bundle.main.url(forResource: "words", withExtension: "txt") {
				if let words = try? String(contentsOf: url).components(separatedBy: "\n").filter({ $0.count > 1 }) {
					word = words[Int.random(in: 0..<words.count)].uppercased()
					usedLetters.removeAll(keepingCapacity: true)
					score = maxTries
					
					DispatchQueue.main.async {
						wordLabel.text = String(word.map { _ in Character("?") })
					}
				}
			}
		}
	}
	
	private func submitLetter(letter: Character) {
		
		if !usedLetters.contains(letter) {
			usedLetters.append(letter)
			
			if word.contains(letter) {
				wordLabel.text = String(word.map { c in usedLetters.contains(c) ? c : Character("?") })
				
				if !(wordLabel.text?.contains(Character("?")) ?? false) {
					win()
				}
			} else {
				score -= 1
				
				if score <= 0 {
					lose()
				}
			}
		}
	}
	
	private func win() {
		let alert = UIAlertController(title: "Victory", message: "You've guessed the word", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
			self?.loadLevel()
		}))
		present(alert, animated: true)
	}
	
	private func lose() {
		let alert = UIAlertController(title: "You lose", message: "The word was \(word!)", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
			self?.loadLevel()
		}))
		present(alert, animated: true)
	}
}

