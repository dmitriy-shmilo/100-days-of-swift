//
//  ViewController.swift
//  Project4
//
//  Created by Dmitriy Shmilo on 02.09.2021.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
	
	let websites = ["github.com", "www.google.com", "www.apple.com"]
	var webView: WKWebView!
	var progressView: UIProgressView!
	
	override func loadView() {
		webView = WKWebView()
		webView.navigationDelegate = self
		view = webView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		progressView = UIProgressView(progressViewStyle: .default)
		progressView.sizeToFit()
		let progressButton = UIBarButtonItem(customView: progressView)
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(webView.reload))
		toolbarItems = [progressButton, spacer, refresh]
		navigationController?.isToolbarHidden = false
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
		
		webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
		let url = URL(string: "https://\(websites[0])")
		webView.load(URLRequest(url: url!))
		webView.allowsBackForwardNavigationGestures = true
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "estimatedProgress" {
			progressView.progress = Float(webView.estimatedProgress)
		}
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		title = webView.title
	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		let url = navigationAction.request.url
		
		if let host = url?.host {
			if websites.contains(where: { $0.hasSuffix(host) })
			{
				decisionHandler(.allow)
				return
			}
		}
		
		decisionHandler(.cancel)
	}
	
	private func openPage(_ action: UIAlertAction) {
		let url = URL(string: "https://\(action.title!)")!
		webView.load(URLRequest(url: url))
	}
	
	@objc private func openTapped() {
		let alert = UIAlertController(title: "Open", message: nil, preferredStyle: .actionSheet)
		websites.forEach {
			alert.addAction(UIAlertAction(title: $0, style: .default, handler: openPage))
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(alert, animated: true)
	}
	
	
}

