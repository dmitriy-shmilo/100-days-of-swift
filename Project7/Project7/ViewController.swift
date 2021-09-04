//
//  ViewController.swift
//  Project7
//
//  Created by Dmitriy Shmilo on 04.09.2021.
//

import UIKit

class ViewController: UITableViewController {
	
	var petitions = [Petition]()

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
		petitions.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
		let petition = petitions[indexPath.row]
		cell.textLabel?.text = petition.title
		cell.detailTextLabel?.text = petition.body
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let petition = petitions[indexPath.row]
		let detailsController = DetailsViewController()
		detailsController.item = petition
		navigationController?.pushViewController(detailsController, animated: true)
	}
	
	private func parse(json: Data) {
		let decoder = JSONDecoder()
		
		if let data = try? decoder.decode(Petitions.self, from: json) {
			petitions = data.results
			tableView.reloadData()
		}
	}
	
	private func showError() {
		let alert = UIAlertController(title: "Loading error", message: "There was a problem loading petitions.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel))
		present(alert, animated: true)
	}
}

