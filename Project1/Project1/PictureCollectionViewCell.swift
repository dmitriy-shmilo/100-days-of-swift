//
//  PictureCollectionViewCell.swift
//  Project1
//
//  Created by Dmitriy Shmilo on 06.09.2021.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var label: UILabel!
	@IBOutlet var viewCountLabel: UILabel!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		layer.borderWidth = 1.0
		layer.borderColor = UIColor.lightGray.cgColor
		layer.cornerRadius = 8.0
	}
}
