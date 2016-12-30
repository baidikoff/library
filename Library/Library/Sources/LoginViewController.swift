//
//  LoginViewController.swift
//  Library
//
//  Created by Nick Baidikoff on 12/21/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation
import UIKit
import VK_ios_sdk

let toLibrarySegue = "toLibrary"

class LoginViewController : UIViewController, VKWorkerUIDelegate, VKWorkerDelegate {
	
	@IBOutlet weak var loginButton: UIButton! {
		didSet {
			loginButton.setImage(#imageLiteral(resourceName: "pressedLoginButton"), for: .highlighted)
		}
	}
	
	private var worker: VKWorker? {
		didSet {
			worker?.register(UIDelegate: self)
			worker?.register(delegate: self)
			worker?.wakeUpSession { state, error in
				if state == .authorized {
					self.perform(#selector(LoginViewController.performSegue as (LoginViewController) -> () -> ()), with: nil, afterDelay: 0.2)
				} else if error != nil {
					let controller = UIAlertController(error: error!)
					self.present(controller, animated: true, completion: nil)
				}
			}
		}
	}
	
	override func viewDidLoad() {
		self.worker = VKWorker(delegate: self)
	}
	
	@IBAction func onLoginAction(_ sender: UIButton) {
		worker?.authorize()
	}
	
	func performSegue() {
		performSegue(withIdentifier: toLibrarySegue, sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationViewController = (segue.destination as! UINavigationController).topViewController as! BooksTableViewController
		destinationViewController.fetch()
	}
	
	// MARK: - VKWorker UI Delegate
	func vkWorker(_ worker: VKWorker, needsCaptchaEnterWithError error: VKError) {
		let controller = VKCaptchaViewController.captchaControllerWithError(error)
		controller?.present(in: navigationController?.topViewController)
	}
	
	func vkWorker(_ worker: VKWorker, willDismissViewController viewController: UIViewController) {
		
	}
	
	func vkWorker(_ worker: VKWorker, didDismissViewController viewController: UIViewController) {
		
	}
	
	func vkWorker(_ worker: VKWorker, shouldPresentViewController viewController: UIViewController) {
		present(viewController, animated: true, completion: nil)
	}
	
	// MARK: - VKWorker Delegate
	func vkWorker(_ worker: VKWorker, didWokeUpSessionWithState state: VKAuthorizationState) {
		if state == .authorized {
			performSegue()
		}
	}
	
	func vkWorker(_ worker: VKWorker, didFinishAuthorizationWithResult result: VKAuthorizationResult) {
		performSegue()
	}
	
	func vkWorkerDidFailAuthorization(_ worker: VKWorker) {
		
	}
	
	func vkWorkerTokenHasExpired(_ worker: VKWorker) {
		
	}
}
