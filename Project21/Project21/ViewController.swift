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
		registerCategories()
	}
	
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse,
		withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		
		if let customData = userInfo["customData"] as? String {
			print("Custom data received: \(customData)")
			
			switch response.actionIdentifier {
			case UNNotificationDefaultActionIdentifier:
				print("Default ID")
			case "showAction":
				print("Show me more")
			default:
				break
			}
		}
		
		completionHandler()
	}
	
	@IBAction func registerLocal(_ sender: Any) {
		let center = UNUserNotificationCenter.current()
		
		center.requestAuthorization(
			options: [.alert, .badge, .sound]
		) { (granted, error) in
			
		}
	}
	
	@IBAction func scheduleLocal(_ sender: Any) {
		let center = UNUserNotificationCenter.current()
		var dateComponents = DateComponents()
		dateComponents.hour = 10
		dateComponents.minute = 30
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
		
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
		let category = UNNotificationCategory(identifier: "Project21CategoryIdentifier", actions: [showAction], intentIdentifiers: [])
		center.setNotificationCategories([category])
	}
	
}

