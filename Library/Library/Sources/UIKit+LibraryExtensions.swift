//
//  UIColor+LibraryExtensions.swift
//  Library
//
//  Created by Nick Baidikoff on 12/21/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit

extension UIColor {
	open class var navigationBarColor: UIColor {
		get {
			return UIColor(red: 250 / 255, green: 215 / 255, blue: 154 / 255, alpha: 1.0)
		}
	}
}

extension UIFont {
	open class var navigationBarFont: UIFont {
		get {
			return UIFont(name: "Georgia", size: 18.0) ?? UIFont.navigationBarFont
		}
	}
	
	open class var emptyTitleFont: UIFont {
		get {
			return UIFont(name: "Georgia", size: 20.0) ?? UIFont.preferredFont(forTextStyle: .title1)
		}
	}
	
	open class var emptyDescriptionFont: UIFont {
		get {
			return UIFont(name: "Georgia", size: 16.0) ?? UIFont.preferredFont(forTextStyle: .title3)
		}
	}
}

extension UIAlertController {
	public convenience init(error: Error) {
		self.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
		addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
	}
}
