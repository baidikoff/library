//
//  VKWorkerDelegate.swift
//  Library
//
//  Created by Nick Baidikoff on 12/22/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation
import VK_ios_sdk

protocol VKWorkerDelegate: class {
	func vkWorker(_ worker: VKWorker, didWokeUpSessionWithState state: VKAuthorizationState) -> Void
	func vkWorker(_ worker: VKWorker, didFinishAuthorizationWithResult result: VKAuthorizationResult) -> Void
	func vkWorkerDidFailAuthorization(_ worker: VKWorker) -> Void
	
	func vkWorkerTokenHasExpired(_ worker: VKWorker) -> Void
}

protocol VKWorkerUIDelegate {
	func vkWorker(_ worker: VKWorker, needsCaptchaEnterWithError error: VKError) -> Void
	
	func vkWorker(_ worker: VKWorker, willDismissViewController viewController: UIViewController) -> Void
	func vkWorker(_ worker: VKWorker, didDismissViewController viewController: UIViewController) -> Void
	
	func vkWorker(_ worker: VKWorker, shouldPresentViewController viewController: UIViewController) -> Void
}
