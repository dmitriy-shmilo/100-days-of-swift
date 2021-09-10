//
//  ViewController.swift
//  Project15.1
//
//  Created by Dmitriy Shmilo on 10.09.2021.
//

import UIKit

class HomeViewController: UITableViewController {
	
	var countries = [Country]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			if let url = Bundle.main.url(forResource: "data", withExtension: "json") {
				if let data = try? Data(contentsOf: url) {
					if let countries = try? JSONDecoder().decode([Country].self, from: data) {
						self?.countries = countries
						
						DispatchQueue.main.async {
							self?.tableView.reloadData()
						}
					}
				}
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		countries.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let country = countries[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
		cell.textLabel?.text = country.name
		cell.imageView?.image = UIImage(named: country.flag)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let country = countries[indexPath.row]
		if let details =
			storyboard?.instantiateViewController(identifier: "DetailsViewController") as? DetailsViewController {
			details.country = country
			navigationController?.pushViewController(details, animated: true)
		}
	}
}

