//
//  VKWorker.swift
//  Library
//
//  Created by Nick Baidikoff on 12/21/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation
import VK_ios_sdk
import SwiftyUserDefaults


class VKWorker: NSObject {
	open var authorizationState: VKAuthorizationState? {
		get {
			return state
		}
	}
	
	open var needsAuthorization: Bool {
		get {
			guard let state = state else {
				return false
			}
			
			return state == .initialized
		}
	}
	
	fileprivate var state: VKAuthorizationState?
	
	fileprivate var delegates: Array<VKWorkerDelegate?>
	fileprivate var UIDelegate: VKWorkerUIDelegate?
	
	private let appID = "5245876"
	private let scope = [VK_PER_DOCS, VK_PER_OFFLINE]
	private let queue = DispatchQueue(label: (Bundle.main.bundleIdentifier?.appending(String(describing: VKWorker.self)))!)
	
	init(delegate: VKWorkerDelegate) {
		self.delegates = [delegate]
		
		super.init()
		
		VKSdk.initialize(withAppId: appID)
		VKSdk.instance().uiDelegate = self
		VKSdk.instance().register(self)
		
		VKSdk.wakeUpSession(scope) { state, error in
			self.state = state
			self.sync()
			if error == nil {
				for delegate in self.delegates {
					delegate?.vkWorker?(self, didWokeUpSessionWithState: state)
				}
			}
		}
	}
	
	fileprivate func sync() {
		queue.async {
			VKApi.users().get([VK_API_FIELDS : "first_name,last_name,photo_max_orig"]).execute(resultBlock: {responce in
				if let user = (responce?.parsedModel as! VKUsersArray).firstObject() {
					Defaults[.user] = "\(user.first_name ?? "") \(user.last_name ?? "")"
					Defaults[.photoURL] = user.photo_max_orig
					
					if let url = URL(string: user.photo_max_orig) {
						Defaults[.photo] = UIImage(url: url)
					}
				}
			}, errorBlock: nil)
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
		Defaults.remove(.photoURL)
		Defaults.remove(.photo)
		Defaults.remove(.user)
		
		VKSdk.forceLogout()
	}
}

// MARK: - VKSdk Delegate
extension VKWorker: VKSdkDelegate {
	public func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
		self.state = result.state
		self.delegates.enumerated().forEach {
			$1?.vkWorker?(self, didFinishAuthorizationWithResult: result)
		}
	}
	
	func vkSdkAuthorizationStateUpdated(with result: VKAuthorizationResult!) {
		self.state = result.state
		sync()
	}
	
	func vkSdkAccessTokenUpdated(_ newToken: VKAccessToken!, oldToken: VKAccessToken!) {
		if newToken == nil {
			self.state = .initialized
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
extension VKWorker: VKSdkUIDelegate {
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
