//
//  VKWorker.swift
//  Library
//
//  Created by Nick Baidikoff on 12/21/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation
import VK_ios_sdk

class VKWorker : NSObject, VKSdkDelegate, VKSdkUIDelegate {
	
	private let appID = "5245876"
	private let scope = [VK_PER_DOCS, VK_PER_NOTIFICATIONS, VK_PER_WALL, VK_PER_STATUS, VK_PER_OFFLINE]
	
	private var delegates: Array<VKWorkerDelegate?>
	private var UIDelegate: VKWorkerUIDelegate?
	
	init(delegate: VKWorkerDelegate) {
		self.delegates = [delegate]
		
		super.init()
		
		VKSdk.initialize(withAppId: appID)
		VKSdk.instance().uiDelegate = self
		VKSdk.instance().register(self)
		
		VKSdk.wakeUpSession(scope) { state, error in
			if error == nil {
				self.delegates.enumerated().forEach() {
					$1?.vkWorker(self, didWokeUpSessionWithState: state)
				}
			}
		}
	}
	
	open func register(UIDelegate: VKWorkerUIDelegate) {
		if self.UIDelegate == nil {
			self.UIDelegate = UIDelegate
		}
	}
	
	open func register(delegate: VKWorkerDelegate) {
		self.delegates.append(delegate)
	}
	
	open func unregister(delegate: VKWorkerDelegate) {
		self.delegates = self.delegates.filter{$0 !== delegate}
	}
	
	open func unregister(UIDelegate: VKWorkerUIDelegate) {
		self.UIDelegate = nil
	}
	
	open func wakeUpSession(withCompletionHandler handler: @escaping (_ state: VKAuthorizationState, _ error: Error?) -> Void) {
		VKSdk.wakeUpSession(self.scope, complete: handler)
	}
	
	open func authorize() {
		VKSdk.authorize(self.scope)
	}
	
	// MARK: - VKSdk Delegate
	func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
		self.delegates.enumerated().forEach {
			$1?.vkWorker(self, didFinishAuthorizationWithResult: result)
		}
	}
	
	func vkSdkUserAuthorizationFailed() {
		self.delegates.enumerated().forEach {
			$1?.vkWorkerDidFailAuthorization(self)
		}
	}
	
	func vkSdkTokenHasExpired(_ expiredToken: VKAccessToken!) {
		self.delegates.enumerated().forEach {
			$1?.vkWorkerTokenHasExpired(self)
		}
	}
	
	// MARK: - VKSdk UI Delegate
	func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
		self.UIDelegate?.vkWorker(self, needsCaptchaEnterWithError: captchaError)
	}
	
	func vkSdkDidDismiss(_ controller: UIViewController!) {
		self.UIDelegate?.vkWorker(self, didDismissViewController: controller)
	}
	
	func vkSdkWillDismiss(_ controller: UIViewController!) {
		self.UIDelegate?.vkWorker(self, willDismissViewController: controller)
	}
	
	func vkSdkShouldPresent(_ controller: UIViewController!) {
		self.UIDelegate?.vkWorker(self, shouldPresentViewController: controller)
	}
}
