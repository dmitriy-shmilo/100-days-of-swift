//
//  ViewController.swift
//  Project7
//
//  Created by Dmitriy Shmilo on 04.09.2021.
//

import UIKit

class ViewController: UITableViewController {
	
	var petitions = [Petition]()
	var filteredPetitions = [Petition]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let url = navigationController?.tabBarItem.tag == 0
			? "https://www.hackingwithswift.com/samples/petitions-1.json"
			: "https://www.hackingwithswift.com/samples/petitions-2.json"
		if let url = URL(string: url) {
			if let data = try? Data(contentsOf: url) {
				parse(json: data)
			} else {
				showError()
			}
		} else {
			showError()
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		filteredPetitions.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
		let petition = filteredPetitions[indexPath.row]
		cell.textLabel?.text = petition.title
		cell.detailTextLabel?.text = petition.body
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let petition = filteredPetitions[indexPath.row]
		let detailsController = DetailsViewController()
		detailsController.item = petition
		navigationController?.pushViewController(detailsController, animated: true)
	}
	
	@IBAction func showFilter() {
		let alert = UIAlertController(title: "Filter", message: "Enter text to filter by", preferredStyle: .alert)
		alert.addTextField()
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Filter", style: .default, handler: { [unowned self, weak alert] _ in
			guard let text = alert?.textFields?[0].text?.lowercased() else {
				return
			}
			
			filteredPetitions = petitions.filter {
				text.count == 0 || $0.title.lowercased().contains(text) || $0.body.lowercased().contains(text)
			}
			tableView.reloadData()
		}))
		present(alert, animated: true)
	}
	
	@IBAction func showCredits() {
		let alert = UIAlertController(title: "Credits", message: "This application uses We The People API of the Whitehouse.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel))
		present(alert, animated: true)
	}
	
	private func parse(json: Data) {
		let decoder = JSONDecoder()
		
		if let data = try? decoder.decode(Petitions.self, from: json) {
			petitions = data.results
			filteredPetitions = petitions
			tableView.reloadData()
		}
	}
	
	private func showError() {
		let alert = UIAlertController(title: "Loading error", message: "There was a problem loading petitions.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel))
		present(alert, animated: true)
	}
}

