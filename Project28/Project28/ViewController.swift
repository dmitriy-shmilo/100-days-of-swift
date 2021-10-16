//
//  ViewController.swift
//  Project28
//
//  Created by Dmitriy Shmilo on 13.10.2021.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

	@IBOutlet private var textView: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(adjustforKeyboard(notification:)),
			name: UIResponder.keyboardWillChangeFrameNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(adjustforKeyboard(notification:)),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(saveSecretMessage),
			name: UIApplication.willResignActiveNotification,
			object: nil
		)

		if KeychainWrapper.standard.string(forKey: "Password") == nil {
			showPasswordPrompt(title: "Set fallback password") { pass in
				if let pass = pass {
					KeychainWrapper.standard.set(pass, forKey: "Password")
				} else {
					fatalError("Missing password")
				}
			}
		}
	}

	@objc func adjustforKeyboard(notification: Notification) {
		guard let kbValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
			return
		}
		let kbScreenEndFrame = kbValue.cgRectValue
		let kbViewEndFrame = view.convert(kbScreenEndFrame, from: view.window)

		if notification.name == UIResponder.keyboardWillHideNotification {
			textView.contentInset = .zero
		} else {
			textView.contentInset = .init(top: 0, left: 0, bottom: kbViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
		}
		textView.scrollIndicatorInsets = textView.contentInset

		let selectedRange = textView.selectedRange
		textView.scrollRangeToVisible(selectedRange)
	}

	@IBAction func saveSecretMessage() {
		guard !textView.isHidden else {
			return
		}

		KeychainWrapper.standard.set(textView.textStorage, forKey: "SecretMessage")
		textView.resignFirstResponder()
		textView.isHidden = true
	}

	@IBAction private func authenticate(_ sender: Any) {
		let context = LAContext()
		var error: NSError?

		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "Identify yourself"
			context.evaluatePolicy(
				.deviceOwnerAuthenticationWithBiometrics,
				localizedReason: reason) { [weak self] success, error in

					DispatchQueue.main.async {
						if success {
							self?.unlockSecretMessage()
						} else {
							if let error = error {
								print(error)
							}
							self?.passwordFallback()
						}
					}
			}
		} else {
			passwordFallback()
		}
	}

	private func unlockSecretMessage() {
		textView.isHidden = false

		if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
			textView.text = text
		}
	}

	private func passwordFallback() {
		showPasswordPrompt(title: "Enter the password:") { [weak self] pass in
			if let storedPass = KeychainWrapper.standard.string(forKey: "Password") {
				if pass == storedPass {
					self?.unlockSecretMessage()
				} else {
					self?.showErrorMessage(title: "Incorrect password", message: "")
				}
			} else {
				fatalError("Missing password")
			}
		}
	}

	private func showPasswordPrompt(title: String, action: @escaping (String?) -> ()) {
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		alert.addTextField()
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] _ in action(alert?.textFields?[0].text) }))
		present(alert, animated: true)
	}

	private func showErrorMessage(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel))
		present(alert, animated: true)
	}
}

