//
//  AppDelegate.swift
//  Library
//
//  Created by Nick Baidikoff on 12/20/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit
import VK_ios_sdk
import ChameleonFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		BuddyBuildSDK.setup()
		
		Chameleon.setGlobalThemeUsingPrimaryColor(.navigationBarColor, withSecondaryColor: .clear, usingFontName: "Georgia", andContentStyle: .contrast)
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		VKSdk.processOpen(url, fromApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!)
		return true
	}
}
