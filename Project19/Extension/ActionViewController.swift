//
//  ActionViewController.swift
//  Extension
//
//  Created by Dmitriy Shmilo on 11.09.2021.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var scriptTextView: UITextView!
	
	var currentScript = Script(id: UUID(), title: "Untitled", body: "")
	var scripts = [Script]()
	var pageTitle = ""
	var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
		if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
			if let itemProvider = inputItem.attachments?.first {
				itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) {
					[weak self] (dict, error) in
					guard let dictionary = dict as? NSDictionary else { return }
					guard let values = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
					self?.pageTitle = values["title"] as? String ?? ""
					self?.pageURL = values["URL"] as? String ?? ""
					
					if let data = UserDefaults.standard.data(forKey: "scripts") {
						if let decoded = try? JSONDecoder().decode([Script].self, from: data) {
							self?.scripts = decoded
							self?.currentScript = self?.scripts[0] ?? Script(id: UUID(), title: "Untitled", body: "")
						}
					}
					
					DispatchQueue.main.async {
						self?.title = self?.currentScript.title
						self?.scriptTextView.text = self?.currentScript.body
					}
				}
			}
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(adjustforKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(adjustforKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func done() {
		self.currentScript.body = self.scriptTextView.text
		self.scripts.removeAll { $0.id == currentScript.id }
		self.scripts.append(currentScript)
		self.save()
		
        let item = NSExtensionItem()
		let arg: NSDictionary = ["customJavaScript": self.scriptTextView.text ?? ""]
		let finalizeArg: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: arg]
		let customJavascript = NSItemProvider(item: finalizeArg, typeIdentifier: kUTTypePropertyList as String)
		item.attachments = [customJavascript]
		extensionContext?.completeRequest(returningItems: [item])
    }
	
	@IBAction func rename(_ sender: Any) {
		let alert = UIAlertController(title: "Rename script", message: nil, preferredStyle: .alert)
		alert.addTextField()
		alert.textFields?[0].text = self.currentScript.title
		alert.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self, weak alert] _ in
			self?.currentScript.title = alert?.textFields?[0].text ?? "Untitled"
			self?.scripts.removeAll { $0.id == self?.currentScript.id }
			if let script = self?.currentScript {
				self?.scripts.append(script)
				self?.title = script.title
				self?.save()
			}
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(alert, animated: true)
	}
	
	@IBAction func load(_ sender: Any) {
		let sheet = UIAlertController(title: "Load script", message: nil, preferredStyle: .actionSheet)
		self.scripts.map { script in
			UIAlertAction(title: script.title, style: .default, handler: { [weak self] _ in
				self?.load(script: script)
			})
		}.forEach {
			sheet.addAction($0)
		}
		sheet.addAction(UIAlertAction(title: "Create New", style: .default, handler: { [weak self] _ in
			self?.save()
			self?.currentScript = Script(id: UUID(), title: "Untitled", body: "// new script")
			
			if let script = self?.currentScript {
				self?.title = script.title
				self?.scriptTextView.text = script.body
			}
		}))
		sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(sheet, animated: true)
	}
	
	@objc func adjustforKeyboard(notification: Notification) {
		guard let kbValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
			return
		}
		let kbScreenEndFrame = kbValue.cgRectValue
		let kbViewEndFrame = view.convert(kbScreenEndFrame, from: view.window)
		
		if notification.name == UIResponder.keyboardWillHideNotification {
			scriptTextView.contentInset = .zero
		} else {
			scriptTextView.contentInset = .init(top: 0, left: 0, bottom: kbViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
		}
		scriptTextView.scrollIndicatorInsets = scriptTextView.contentInset
		
		let selectedRange = scriptTextView.selectedRange
		scriptTextView.scrollRangeToVisible(selectedRange)
	}
	
	private func load(script: Script) {
		self.currentScript = script
		self.scriptTextView.text = script.body
		self.title = script.title
	}
	
	private func save() {
		DispatchQueue.global().async {
			if let data = try? JSONEncoder().encode(self.scripts) {
				UserDefaults.standard.set(data, forKey: "scripts")
			}
		}
	}
}
