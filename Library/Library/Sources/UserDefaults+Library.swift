//
//  UserDefaults+Library.swift
//  Library
//
//  Created by Nick Baidikoff on 2/1/17.
//  Copyright © 2017 Nick Baidikoff. All rights reserved.
//

import Foundation
import VK_ios_sdk
import SwiftyUserDefaults

extension UserDefaults {
	subscript(key: DefaultsKey<UIImage?>) -> UIImage? {
		get {
			return unarchive(key)
		}
		set {
			archive(key, newValue)
		}
	}
}


extension DefaultsKeys {
	open static let user = DefaultsKey<String?>("user")
	open static let photoURL = DefaultsKey<String?>("photoURL")
	open static let photo = DefaultsKey<UIImage?>("photo")
}

