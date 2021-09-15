//
//  ViewController.swift
//  Project21.1
//
//  Created by Dmitriy Shmilo on 14.09.2021.
//

import UIKit

class HomeViewController: UITableViewController, NoteChangeDelegate {

	private var notes = [Note]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			if let data = UserDefaults.standard.data(forKey: "notes") {
				if let decodedNotes = try? JSONDecoder().decode([Note].self, from: data) {
					DispatchQueue.main.async {
						self?.notes = decodedNotes
						self?.tableView.reloadData()
					}
				}
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		notes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let note = notes[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
		cell.textLabel?.text = note.title
		cell.detailTextLabel?.text = note.subtitle
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let detailsController = storyboard?.instantiateViewController(identifier: "DetailsViewController") as? DetailsViewController {
			let note = notes[indexPath.row]
			detailsController.note = note
			detailsController.delegate = self
			navigationController?.pushViewController(detailsController, animated: true)
		}
	}
	
	func noteDidChange(_ note: Note) {
		if let index = notes.firstIndex(where: { $0.id == note.id }) {
			notes[index] = note
			tableView.reloadData()
			//tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
			saveNotes()
		}
	}
	
	func noteWillBeDeleted(_ note: Note) {
		notes.removeAll(where: { $0.id == note.id })
		tableView.reloadData()
		saveNotes()
	}

	@IBAction func composeNote(_ sender: Any) {
		if let detailsController = storyboard?.instantiateViewController(identifier: "DetailsViewController") as? DetailsViewController {
			let note = Note(id: UUID(), body: "")
			notes.append(note)
			detailsController.note = note
			detailsController.delegate = self
			navigationController?.pushViewController(detailsController, animated: true)
		}
	}
	
	private func saveNotes() {
		DispatchQueue.global().async {
			if let data = try? JSONEncoder().encode(self.notes) {
				UserDefaults.standard.set(data, forKey: "notes")
			}
		}
	}
}

