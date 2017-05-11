//
//  VKWorkerDelegate.swift
//  Library
//
//  Created by Nick Baidikoff on 12/22/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation
import VK_ios_sdk

@objc protocol VKWorkerDelegate: class {
	@objc optional func vkWorker(_ worker: VKWorker, didWokeUpSessionWithState state: VKAuthorizationState) -> Void
	@objc optional func vkWorker(_ worker: VKWorker, didFinishAuthorizationWithResult result: VKAuthorizationResult) -> Void
	@objc optional func vkWorkerDidFailAuthorization(_ worker: VKWorker) -> Void
	
	@objc optional func vkWorkerTokenHasExpired(_ worker: VKWorker) -> Void
}

@objc protocol VKWorkerUIDelegate: class {
	@objc optional func vkWorker(_ worker: VKWorker, needsCaptchaEnterWithError error: VKError) -> Void
	
	@objc optional func vkWorker(_ worker: VKWorker, willDismissViewController viewController: UIViewController) -> Void
	@objc optional func vkWorker(_ worker: VKWorker, didDismissViewController viewController: UIViewController) -> Void
	
	@objc optional func vkWorker(_ worker: VKWorker, shouldPresentViewController viewController: UIViewController) -> Void
}
