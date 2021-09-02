//
//  ViewController.swift
//  Project3.1
//
//  Created by Dmitriy Shmilo on 02.09.2021.
//

import UIKit

class ViewController: UITableViewController {

	private let countries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		countries.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FlagTableViewCell", for: indexPath)
		cell.imageView?.image = UIImage(named: countries[indexPath.row])
		cell.imageView?.layer.borderWidth = 1.0
		cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
		cell.textLabel?.text = countries[indexPath.row].uppercased()
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let detailsViewController = storyboard?.instantiateViewController(identifier: "Details") as? DetailsViewController {
			detailsViewController.selectedCountry = countries[indexPath.row]
			navigationController?.pushViewController(detailsViewController, animated: true)
		}
	}
}

