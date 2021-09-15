//
//  DetailsViewController.swift
//  Project21.1
//
//  Created by Dmitriy Shmilo on 14.09.2021.
//

import UIKit

protocol NoteChangeDelegate: AnyObject {
	func noteDidChange(_ note: Note)
	func noteWillBeDeleted(_ note: Note)
}

class DetailsViewController: UIViewController {
	
	var note: Note!
	@IBOutlet var textView: UITextView!
	weak var delegate: NoteChangeDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = note.title
		textView.text = note.body
    }
    
	override func viewWillDisappear(_ animated: Bool) {
		note.body = textView.text
		delegate?.noteDidChange(note)
	}
	
	@IBAction func shareNote(_ sender: Any) {
		let controller = UIActivityViewController(activityItems: [textView.text ?? ""], applicationActivities: [])
		controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?[1]
		present(controller, animated: true)
	}
	
	@IBAction func deleteNote(_ sender: Any) {
		navigationController?.popViewController(animated: true)
		self.delegate?.noteWillBeDeleted(self.note)
	}
}
