//
//  ViewController.swift
//  Project21
//
//  Created by Dmitriy Shmilo on 14.09.2021.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse,
		withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		var title = "Unknown"
		
		if let customData = userInfo["customData"] as? String {
			print("Custom data received: \(customData)")
			
			switch response.actionIdentifier {
			case UNNotificationDefaultActionIdentifier:
				title = "Default ID"
				break
			case "show":
				title = "Show me more"
				break
			case "remind":
				title = "Remind me later"
				scheduleNotification(interval: 5.0)
				break
			default:
				break
			}
		}
		
		let alert = UIAlertController(title: "Action pressed:", message: title, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel))
		present(alert, animated: true)
		
		completionHandler()
	}
	
	@IBAction func registerLocal(_ sender: Any) {
		let center = UNUserNotificationCenter.current()
		
		center.requestAuthorization(
			options: [.alert, .badge, .sound]
		) { (granted, error) in
			self.registerCategories()
		}
	}
	
	@IBAction func scheduleLocal(_ sender: Any) {
		scheduleNotification(interval: 5.0)
	}
	
	private func scheduleNotification(interval: TimeInterval) {
		let center = UNUserNotificationCenter.current()
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
		
		let content = UNMutableNotificationContent()
		content.title = "Project 21, Title"
		content.body = "Project 21, Body"
		content.categoryIdentifier = "Project21CategoryIdentifier"
		content.userInfo = ["customData" : "data"]
		content.sound = .default
		
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
		center.add(request)
	}

	private func registerCategories() {
		let center = UNUserNotificationCenter.current()
		center.delegate = self
		
		let showAction = UNNotificationAction(identifier: "show", title: "Show me more", options: [.foreground])
		let remindAction = UNNotificationAction(identifier: "remind", title: "Remind me later", options: [])
		let category = UNNotificationCategory(identifier: "Project21CategoryIdentifier", actions: [showAction, remindAction], intentIdentifiers: [])
		center.setNotificationCategories([category])
	}
}

