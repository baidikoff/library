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
	
	private var worker: VKWorker? {
		didSet {
			worker?.register(UIDelegate: self)
			worker?.register(delegate: self)
		}
	}
	
	@IBOutlet weak var loginButton: UIButton! {
		didSet {
			loginButton.setImage(#imageLiteral(resourceName: "pressedLoginButton"), for: .highlighted)
		}
	}

	@IBAction func onLoginAction(_ sender: UIButton) {
		//worker?.authorize()
		performSegue()
	}
	
	func performSegue() {
		performSegue(withIdentifier: toLibrarySegue, sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationViewController = (segue.destination as! UINavigationController).topViewController as! BooksTableViewController
		destinationViewController.fetch()
	}
	
	// MARK: - VKWorker Delegate	
	func vkWorker(_ worker: VKWorker, didFinishAuthorizationWithResult result: VKAuthorizationResult) {
		performSegue()
	}
	
	func vkWorkerDidFailAuthorization(_ worker: VKWorker) {
		
	}
	
	// MARK: - VKWorker UI Delegate
	func vkWorker(_ worker: VKWorker, needsCaptchaEnterWithError error: VKError) {
		let controller = VKCaptchaViewController.captchaControllerWithError(error)
		controller?.present(in: self)
	}
	
	func vkWorker(_ worker: VKWorker, willDismissViewController viewController: UIViewController) {
		
	}
	
	func vkWorker(_ worker: VKWorker, didDismissViewController viewController: UIViewController) {
		
	}
	
	func vkWorker(_ worker: VKWorker, shouldPresentViewController viewController: UIViewController) {
		present(viewController, animated: true, completion: nil)
	}
}
