//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var dirty = false
	private var items = [String]() // this is the array that will store the filenames to load
	private var cacheFolder: URL?
	private let thumbSize = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Reactionist"
		
		tableView.rowHeight = 90
		tableView.separatorStyle = .none
		
		// load all the JPEGs into our array
		let fm = FileManager.default
		
		cacheFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
			for item in tempItems {
				if item.range(of: "Large") != nil {
					items.append(item)
					
					if let path = Bundle.main.path(forResource: item, ofType: nil),
					   let original = UIImage(contentsOfFile: path) {
						
						let renderer = UIGraphicsImageRenderer(size: thumbSize.size)
						
						let rounded = renderer.image { ctx in
							ctx.cgContext.addEllipse(in: thumbSize)
							ctx.cgContext.clip()
							
							original.draw(in: thumbSize)
						}
						
						if let path = cacheFolder?.appendingPathComponent(item) {
							do {
								try rounded.pngData()?.write(to: path)
							} catch {
								print("Failed to save thumb for \(item)")
							}
						}
					}
				}
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// Return the number of sections.
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Return the number of rows in the section.
		return items.count * 10
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
		if cell == nil {
			cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
		}
		
		// find the image for this cell, and load its thumbnail
		let currentImage = items[indexPath.row % items.count]
		
		
		if let path = cacheFolder?.appendingPathComponent(currentImage),
		   let img = UIImage(contentsOfFile: path.path) {
			// give the images a nice shadow to make them look a bit more dramatic
			cell.imageView?.image = img
			cell.imageView?.layer.shadowColor = UIColor.black.cgColor
			cell.imageView?.layer.shadowOpacity = 1
			cell.imageView?.layer.shadowRadius = 10
			cell.imageView?.layer.shadowOffset = CGSize.zero
			cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: thumbSize).cgPath
		}
		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self
		
		// mark us as not needing a counter reload when we return
		dirty = false
		
		navigationController!.pushViewController(vc, animated: true)
	}
}
