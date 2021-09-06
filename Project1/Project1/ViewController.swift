//
//  ViewController.swift
//  Project1
//
//  Created by Dmitriy Shmilo on 01.09.2021.
//

import UIKit

class ViewController: UICollectionViewController {
	
	var pictures = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		DispatchQueue.global(qos: .userInitiated).async { [self] in
			
			
			let fm = FileManager.default
			let path = Bundle.main.resourcePath!
			let items = try! fm.contentsOfDirectory(atPath: path)
			
			for item in items.sorted() {
				if item.hasPrefix("nssl") {
					pictures.append(item)
				}
			}
			
			DispatchQueue.main.async {
				collectionView.reloadData()
			}
		}
		
		title = NSLocalizedString("Storm Viewer", comment: "")
		navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		pictures.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? PictureCollectionViewCell else {
			fatalError()
		}
		cell.label.text = pictures[indexPath.item]
		cell.imageView.image = UIImage(named: pictures[indexPath.item])
		return cell
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let viewController = storyboard?.instantiateViewController(identifier: "Details") as? DetailsViewController {
			viewController.imageCount = pictures.count
			viewController.imageIndex = indexPath.row
			viewController.selectedImage = pictures[indexPath.item]
			navigationController?.pushViewController(viewController, animated: true)
		}
	}
	
	
}

