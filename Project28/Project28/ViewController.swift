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

	@objc func saveSecretMessage() {
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
							print(error.debugDescription)
							let ac = UIAlertController(
								title: "Authentication failed",
								message: "You could not be verified; please try again.",
								preferredStyle: .alert
							)
							ac.addAction(UIAlertAction(title: "OK", style: .cancel))
							self?.present(ac, animated: true)
						}
					}
			}
		} else {
			let ac = UIAlertController(
				title: "Biometry unavailable",
				message: "Your device is not configured for biometric authentication.",
				preferredStyle: .alert
			)
			ac.addAction(UIAlertAction(title: "OK", style: .cancel))
			self.present(ac, animated: true)
		}

	}

	private func unlockSecretMessage() {
		textView.isHidden = false

		if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
			textView.text = text
		}
	}


}

