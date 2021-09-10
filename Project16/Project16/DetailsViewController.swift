//
//  DetailsViewController.swift
//  Project16
//
//  Created by Dmitriy Shmilo on 10.09.2021.
//

import UIKit
import WebKit
class DetailsViewController: UIViewController {
	
	var city: String!
	@IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
		title = city
		webView.load(URLRequest(url: URL(string: "https://en.wikipedia.org/wiki/\(city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")!))
    }

}
