//
//  ViewController.swift
//  Project25
//
//  Created by Dmitriy Shmilo on 01.10.2021.
//

import UIKit
import MultipeerConnectivity

class ViewController:
	UICollectionViewController,
	UIImagePickerControllerDelegate & UINavigationControllerDelegate,
	MCSessionDelegate,
	MCBrowserViewControllerDelegate {

	private static let ServiceType: String = "dsh-project25"

	private var peerID = MCPeerID(displayName: UIDevice.current.name)
	private var mcSession: MCSession?
	private var mcAdvAssistant: MCAdvertiserAssistant?
		
	private var images = [UIImage]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
		mcSession?.delegate = self
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		images.count
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
		
		if let imageView = cell.viewWithTag(1000) as? UIImageView {
			imageView.image = images[indexPath.item]
		}
		
		return cell
	}
	
	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.originalImage] as? UIImage else {
			return
		}
		
		dismiss(animated: true)
		
		images.insert(image, at: 0)
		collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
		
		guard let mcSession = mcSession else {
			return
		}

		if !mcSession.connectedPeers.isEmpty {
			if let imageData = image.pngData() {
				do {
					try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
				}
				catch {
					print("\(error.localizedDescription)")
				}
			}
		}
	}
	
	func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
		dismiss(animated: true)
	}
	
	func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
		dismiss(animated: true)
	}

	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		switch state {
		case .connected:
			print("\(peerID.displayName) connected")
		case .connecting:
			print("\(peerID.displayName) connecting")
		case .notConnected:
			print("\(peerID.displayName) disconnected")
		@unknown default:
			print("\(peerID.displayName) state changed to \(state.rawValue)")
		}
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		DispatchQueue.main.async { [weak self] in
			guard let image = UIImage(data: data) else {
				return
			}
			
			self?.images.insert(image, at: 0)
			self?.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
		}
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		
	}
	
	func onHostSelected(_ action: UIAlertAction) {
		guard let mcSession = mcSession else {
			return
		}
		
		mcAdvAssistant = MCAdvertiserAssistant(serviceType: Self.ServiceType, discoveryInfo: nil, session: mcSession)
		mcAdvAssistant?.start()
	}
	
	func onJoinSelected(_ action: UIAlertAction) {
		guard let mcSession = mcSession else {
			return
		}

		let mcBrowser = MCBrowserViewController(serviceType: Self.ServiceType, session: mcSession)
		mcBrowser.delegate = self
		present(mcBrowser, animated: true)
	}

	@IBAction func importPicture(_ sender: Any) {
		let picker = UIImagePickerController()
		picker.delegate = self
		present(picker, animated: true)
	}
	
	@IBAction func showConnectionPrompt(_ sender: Any) {
		let alert = UIAlertController(title: "Connect", message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Host", style: .default, handler: onHostSelected))
		alert.addAction(UIAlertAction(title: "Join", style: .default, handler: onJoinSelected))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(alert, animated: true)
	}

}

