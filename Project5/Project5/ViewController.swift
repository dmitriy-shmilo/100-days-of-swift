//
//  ViewController.swift
//  Project5
//
//  Created by Dmitriy Shmilo on 03.09.2021.
//

import UIKit

class ViewController: UITableViewController {
	
	let minWordLength = 3
	var allWords = [String]()
	var usedWords = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
		
		if let url = Bundle.main.url(forResource: "start", withExtension: "txt") {
			if let words = try? String(contentsOf: url) {
				allWords = words.components(separatedBy: "\n")
			}
		}
		
		if allWords.isEmpty {
			allWords.append("silkworm")
		}
		
		startGame()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		usedWords.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "WordTableCell", for: indexPath)
		cell.textLabel?.text = usedWords[indexPath.row]
		return cell
	}
	
	@objc private func promptForAnswer() {
		let alert = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
		alert.addTextField()
		let action = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alert] _ in
			guard let answer = alert?.textFields?[0].text else { return }
			self?.submit(answer)
		}
		
		alert.addAction(action)
		present(alert, animated: true)
	}
	
	@objc private func startGame() {
		title = allWords.randomElement()
		usedWords.removeAll(keepingCapacity: true)
		tableView.reloadData()
	}
	
	private func submit(_ answer: String) {
		let answer = answer.lowercased()
		
		if !isLongEnough(word: answer) {
			showError(title: "Too short", message: "Words should be at least \(minWordLength) characters long")
			return
		}

		if !isPossible(word: answer) {
			showError(title: "Not a word", message: "\(answer) doesn't seem to be a word")
			return
		}

		if !isOriginal(word: answer) {
			showError(title: "Already used", message: "\(answer) is alredy in the list")
			return
		}

		if !isReal(word: answer) {
			showError(title: "Impossible", message: "\(answer) can't be made of \(title ?? "") letters")
			return
		}
		
		usedWords.insert(answer, at: 0)
		tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
	}
	
	private func showError(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		present(alert, animated: true)
	}
	
	private func isPossible(word: String) -> Bool {
		guard var tmp = title?.lowercased() else {
			return false
		}
		
		for letter in word {
			if let position = tmp.firstIndex(of: letter) {
				tmp.remove(at: position)
			} else {
				return false
			}
		}
		
		return true
	}
	
	private func isOriginal(word: String) -> Bool {
		guard let title = title?.lowercased() else {
			return false
		}
		
		return title != word && !usedWords.contains(word)
	}
	
	private func isReal(word: String) -> Bool {
		let checker = UITextChecker()
		let range = NSRange(location: 0, length: word.utf16.count)
		let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
		
		return misspelledRange.location == NSNotFound
	}
	
	private func isLongEnough(word: String) -> Bool {
		return word.count >= minWordLength
	}
}

