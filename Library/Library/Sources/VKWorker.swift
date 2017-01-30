//
//  VKWorker.swift
//  Library
//
//  Created by Nick Baidikoff on 12/21/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation
import VK_ios_sdk

class VKWorker : NSObject {
	
	open var authorizationResult: VKAuthorizationResult? {
		get {
			return result
		}
	}
	
	open var authorizationState: VKAuthorizationState? {
		get {
			return state
		}
	}
	
	fileprivate var result: VKAuthorizationResult? {
		didSet {
			state = result?.state
		}
	}
	
	fileprivate var state: VKAuthorizationState?
	
	fileprivate var delegates: Array<VKWorkerDelegate?>
	fileprivate var UIDelegate: VKWorkerUIDelegate?
	
	private let appID = "5245876"
	private let scope = [VK_PER_DOCS, VK_PER_OFFLINE]
	
	init(delegate: VKWorkerDelegate) {
		self.delegates = [delegate]
		
		super.init()
		
		VKSdk.initialize(withAppId: appID)
		VKSdk.instance().uiDelegate = self
		VKSdk.instance().register(self)
		
		VKSdk.wakeUpSession(scope) { state, error in
			self.state = state
			if error == nil {
				for delegate in self.delegates {
					delegate?.vkWorker?(self, didWokeUpSessionWithState: state)
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
		self.delegates = self.delegates.filter { $0 !== delegate }
	}
	
	open func unregister(UIDelegate: VKWorkerUIDelegate) {
		self.UIDelegate = nil
	}
	
	open func authorize() {
		VKSdk.authorize(self.scope)
	}
	
	open func unauthorize() {
		VKSdk.forceLogout()
	}
}

// MARK: - VKSdk Delegate
extension VKWorker : VKSdkDelegate {
	func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
		self.result = result
		self.delegates.enumerated().forEach {
			$1?.vkWorker?(self, didFinishAuthorizationWithResult: result)
		}
	}
	
	func vkSdkUserAuthorizationFailed() {
		self.delegates.enumerated().forEach {
			$1?.vkWorkerDidFailAuthorization?(self)
		}
	}
	
	func vkSdkTokenHasExpired(_ expiredToken: VKAccessToken!) {
		self.delegates.enumerated().forEach {
			$1?.vkWorkerTokenHasExpired?(self)
		}
	}
}

// MARK: - VKSdk UI Delegate
extension VKWorker : VKSdkUIDelegate {
	func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
		self.UIDelegate?.vkWorker?(self, needsCaptchaEnterWithError: captchaError)
	}
	
	func vkSdkDidDismiss(_ controller: UIViewController!) {
		self.UIDelegate?.vkWorker?(self, didDismissViewController: controller)
	}
	
	func vkSdkWillDismiss(_ controller: UIViewController!) {
		self.UIDelegate?.vkWorker?(self, willDismissViewController: controller)
	}
	
	func vkSdkShouldPresent(_ controller: UIViewController!) {
		self.UIDelegate?.vkWorker?(self, shouldPresentViewController: controller)
	}
}
