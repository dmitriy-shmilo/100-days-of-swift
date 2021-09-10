//
//  DetailsViewController.swift
//  Project15.1
//
//  Created by Dmitriy Shmilo on 10.09.2021.
//

import UIKit

class DetailsViewController: UIViewController {
	
	var country: Country!
	
	@IBOutlet var flagImageView: UIImageView!
	@IBOutlet var populationLabel: UILabel!
	@IBOutlet var areaLabel: UILabel!
	@IBOutlet var statusLabel: UILabel!
	@IBOutlet var recognitionLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = country.name
		flagImageView.image = UIImage(named: country.flag)
		populationLabel.text = "\(country.population) people"
		areaLabel.text = "\(country.area) km²"
		statusLabel.text = country.status
		recognitionLabel.text = country.recognition
    }
	
	@IBAction func share(_ sender: Any) {
		let activity = UIActivityViewController(activityItems: [
													"\(country.name). \(country.status) \(country.recognition)", flagImageView.image!],
												applicationActivities: [])
		present(activity, animated: true)
	}

}
