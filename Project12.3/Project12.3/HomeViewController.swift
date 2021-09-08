//
//  ViewController.swift
//  Project12.3
//
//  Created by Dmitriy Shmilo on 07.09.2021.
//

import UIKit

class HomeViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	var photos = [Photo]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let data = UserDefaults.standard.object(forKey: "photos") as? Data {
			if let decoded = try? JSONDecoder().decode([Photo].self, from: data) {
				photos = decoded
				tableView.insertRows(
					at: (0...photos.count).map { IndexPath(row: $0, section: 0)},
					with: .automatic
				)
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		photos.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
		let photo = photos[indexPath.row]
		let url = FileManager.default.urls(for: .documentDirectory,
										   in: .userDomainMask)[0].appendingPathComponent(photo.name)
		if let data = try? Data(contentsOf: url) {
			cell.imageView?.image = UIImage(data: data)
		}
		cell.textLabel?.text = photo.caption
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let photo = photos[indexPath.row]
		if let controller = storyboard?.instantiateViewController(identifier: "DetailsViewController") as? DetailsViewController {
			controller.photo = photo
			navigationController?.pushViewController(controller, animated: true)
		}
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.originalImage] as? UIImage else {
			return
		}
		
		let name = UUID().uuidString
		let url = FileManager.default.urls(for: .documentDirectory,
										   in: .userDomainMask)[0].appendingPathComponent(name)
		if let data = image.jpegData(compressionQuality: 0.8) {
			do {
				try data.write(to: url)
			} catch {
				print("Couldn't save image")
				return
			}
		}
		picker.dismiss(animated: true)
		
		let alert = UIAlertController(title: "Name your photo", message: nil, preferredStyle: .alert)
		alert.addTextField()
		alert.textFields?[0].text = "Untitled"
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
			[weak alert, unowned self] _ in
			
			let photo = Photo(name: name, caption: alert?.textFields?[0].text ?? "")
			
			self.photos.insert(photo, at: 0)
			self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
			
			if let data = try? JSONEncoder().encode(self.photos) {
				UserDefaults.standard.set(data, forKey: "photos")
			}
		}))
		present(alert, animated: true, completion: {
			[weak alert] in
			alert?.textFields?[0].becomeFirstResponder()
			alert?.textFields?[0].selectAll(nil)
		})
	}
	
	@IBAction func addPhoto(_ sender: Any) {
		let picker = UIImagePickerController()
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			picker.sourceType = .camera
		} else {
			picker.sourceType = .photoLibrary
		}
		picker.delegate = self
		picker.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		
		present(picker, animated: true)
	}
}

