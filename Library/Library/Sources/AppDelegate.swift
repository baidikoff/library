//
//  AppDelegate.swift
//  Library
//
//  Created by Nick Baidikoff on 12/20/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit
import VK_ios_sdk

let contentNavigationController = "contentNavigationController"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, VKWorkerDelegate {
	
	var window: UIWindow?
	
	private var worker: VKWorker? {
		didSet {
			worker?.register(delegate: self)
			worker?.wakeUpSession()
		}
	}
	
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		self.worker = VKWorker(delegate: self)
		return true
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		UINavigationBar.appearance().backgroundColor = UIColor.navigationBarColor
		UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont.navigationBarFont]
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		VKSdk.processOpen(url, fromApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!)
		return true
	}
	
	// MARK: - VKWorker Delegate
	func vkWorker(_ worker: VKWorker, didWokeUpSessionWithState state: VKAuthorizationState) {
		if state == .authorized {
			window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: contentNavigationController)
			((window?.rootViewController as! UINavigationController).topViewController as! BooksTableViewController).fetch()
		}
	}
	
	func vkWorkerTokenHasExpired(_ worker: VKWorker) {
		
	}
}

