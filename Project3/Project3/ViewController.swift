//
//  ViewController.swift
//  Project3
//
//  Created by Dmitriy Shmilo on 01.09.2021.
//

import UIKit

class ViewController: UITableViewController {

	var pictures = [String]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let fm = FileManager.default
		let path = Bundle.main.resourcePath!
		let items = try! fm.contentsOfDirectory(atPath: path)
		
		for item in items.sorted() {
			if item.hasPrefix("nssl") {
				pictures.append(item)
			}
		}
		
		title = NSLocalizedString("Storm Viewer", comment: "")
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		pictures.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
		cell.textLabel?.text = pictures[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let viewController = storyboard?.instantiateViewController(identifier: "Details") as? DetailsViewController {
			viewController.imageCount = pictures.count
			viewController.imageIndex = indexPath.row
			viewController.selectedImage = pictures[indexPath.row]
			navigationController?.pushViewController(viewController, animated: true)
		}
	}
	
	@objc private func shareTapped() {
		let viewController = UIActivityViewController(activityItems: [Bundle.main.object(forInfoDictionaryKey: "CFBundleName")!, URL(string: "https://www.hackingwithswift.com/100")!], applicationActivities: [])
		viewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(viewController, animated: true)
	}
}

