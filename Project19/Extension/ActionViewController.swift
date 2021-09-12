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
					
					DispatchQueue.main.async {
						self?.title = self?.pageTitle
					}
				}
			}
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(adjustforKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(adjustforKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func done() {
        let item = NSExtensionItem()
		let arg: NSDictionary = ["customJavaScript": scriptTextView.text ?? ""]
		let finalizeArg: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: arg]
		let customJavascript = NSItemProvider(item: finalizeArg, typeIdentifier: kUTTypePropertyList as String)
		item.attachments = [customJavascript]
		extensionContext?.completeRequest(returningItems: [item])
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

}
