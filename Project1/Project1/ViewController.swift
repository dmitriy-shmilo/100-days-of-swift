//
//  ViewController.swift
//  Project1
//
//  Created by Dmitriy Shmilo on 01.09.2021.
//

import UIKit

class ViewController: UICollectionViewController {
	
	var pictures = [String]()
	var pictureInfo = [String: PictureInfo]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		DispatchQueue.global(qos: .userInitiated).async { [self] in
			let fm = FileManager.default
			let path = Bundle.main.resourcePath!
			let items = try! fm.contentsOfDirectory(atPath: path)
			
			pictures = items.sorted().filter { $0.hasPrefix("nssl") };
			
			if let data = UserDefaults.standard.data(forKey: "pictureInfo"),
			   let decoded = try? JSONDecoder().decode([String: PictureInfo].self, from: data) {
				pictureInfo = decoded
			} else {
				pictureInfo =  Dictionary(
					uniqueKeysWithValues: pictures.map {
						($0, PictureInfo(name: $0, viewCount: 0))
					}
				)
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
		let picture = pictures[indexPath.item]
		cell.label.text = picture
		cell.imageView.image = UIImage(named: pictures[indexPath.item])
		cell.viewCountLabel.text = "\(pictureInfo[picture]?.viewCount ?? 0) views"
		return cell
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let viewController = storyboard?.instantiateViewController(identifier: "Details") as? DetailsViewController {
			let picture = pictures[indexPath.item]
			
			if pictureInfo[picture] == nil {
				pictureInfo[picture] = PictureInfo(name: picture, viewCount: 0)
			}
			
			var info = pictureInfo[picture]!
			info.viewCount += 1
			pictureInfo[picture] = info
			
			collectionView.reloadItems(at: [indexPath])

			viewController.imageCount = pictures.count
			viewController.imageIndex = indexPath.row
			viewController.selectedImage = picture
			navigationController?.pushViewController(viewController, animated: true)
			
			if let data = try? JSONEncoder().encode(pictureInfo) {
				UserDefaults.standard.setValue(data, forKey: "pictureInfo")
			}
		}
	}
	
	
}

