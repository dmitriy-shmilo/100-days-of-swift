//
//  DetailsViewController.swift
//  Project7
//
//  Created by Dmitriy Shmilo on 04.09.2021.
//

import UIKit
import WebKit

class DetailsViewController: UIViewController {

	var webView: WKWebView!
	var item: Petition?

	override func loadView() {
		webView = WKWebView()
		view = webView
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		guard let item = item else {
			return
		}
		
		let html = """
		<html>
		<head>
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<style> body { font-size: 150%; } </style>
		</head>
		<body>
		\(item.body)
		</body>
		</html>
		"""
		
		webView.loadHTMLString(html, baseURL: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
