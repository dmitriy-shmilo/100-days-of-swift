//
//  ViewController.swift
//  Project6.1
//
//  Created by Dmitriy Shmilo on 04.09.2021.
//

import UIKit

class ViewController: UITableViewController {
	
	private var items = [String]()

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		items.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableCell", for: indexPath)
		cell.textLabel?.text = items[indexPath.row]
		return cell
	}
	
	@IBAction func addItem(_ sender: Any) {
		let alert = UIAlertController(title: "Add Item", message: "Enter item name", preferredStyle: .alert)
		alert.addTextField(configurationHandler: nil)
		alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [unowned self, weak alert] action in
			guard let text = alert?.textFields?[0].text else {
				return
			}
			
			items.append(text)
			tableView.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .automatic)
		}))
		present(alert, animated: true)
	}
	
	@IBAction func clearList(_ sender: Any) {
		tableView.beginUpdates()
		tableView.deleteRows(at: (0..<items.count).map { IndexPath(row: $0, section: 0)}, with: .automatic)
		items.removeAll(keepingCapacity: true)
		tableView.endUpdates()
	}
	
	@IBAction func shareList(_ sender: Any) {
		let controller = UIActivityViewController(activityItems: [items.joined(separator: ",")], applicationActivities: [])
		present(controller, animated: true)
	}
}

