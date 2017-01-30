//
//  UIColor+LibraryExtensions.swift
//  Library
//
//  Created by Nick Baidikoff on 12/21/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit

extension UIColor {
	open class var navigationBarColor : UIColor {
		get {
			return UIColor(red: 255 / 255, green: 221 / 255, blue: 171 / 255, alpha: 1.0)
		}
	}
}

extension UIFont {
	open class var navigationBarFont : UIFont {
		get {
			return UIFont(name: "Georgia", size: 18.0) ?? UIFont.navigationBarFont
		}
	}
}

extension UIAlertController {
	public convenience init(error: Error) {
		self.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
		addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
	}
}

extension UITableView {
	open func setBackground(view : UIView) {
		backgroundView = view
		isScrollEnabled = false
		separatorStyle = .none
	}
	
	open func clearBackground() {
		backgroundView = nil
		separatorStyle = .singleLine
		isScrollEnabled = true
	}
}
