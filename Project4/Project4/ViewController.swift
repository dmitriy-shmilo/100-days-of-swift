//
//  ViewController.swift
//  Project4
//
//  Created by Dmitriy Shmilo on 02.09.2021.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
	
	var allowedHosts: [String]!
	var website: String!
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
		let back = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector(webView.goBack))
		let forward = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector(webView.goForward))
		let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
		toolbarItems = [progressButton, spacer, back, refresh, forward]
		navigationController?.isToolbarHidden = false
		
		webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
		let url = URL(string: "https://\(website!)")
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
			if allowedHosts.contains(where: { $0.hasSuffix(host) })
			{
				decisionHandler(.allow)
				return
			}
			
			let alert = UIAlertController(title: "Access Denied", message: "\(host) host is not allowed", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			present(alert, animated: true)
		}
		
		
		
		decisionHandler(.cancel)
	}
	
	private func openPage(_ action: UIAlertAction) {
		let url = URL(string: "https://\(action.title!)")!
		webView.load(URLRequest(url: url))
	}
}

