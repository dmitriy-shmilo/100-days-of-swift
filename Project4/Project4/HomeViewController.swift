//
//  HomeViewController.swift
//  Project4
//
//  Created by Dmitriy Shmilo on 03.09.2021.
//

import UIKit

class HomeViewController: UITableViewController {
	let websites = ["github.com", "www.google.com", "www.apple.com"]
	
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebsiteTableCell", for: indexPath)
		cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let viewController
			= storyboard?.instantiateViewController(identifier: "WebViewController")
			as? ViewController {
			viewController.allowedHosts = websites
			viewController.website = websites[indexPath.row]
			navigationController?.pushViewController(viewController, animated: true)
		}
	}
}
