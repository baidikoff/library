//
//  UIKit + Library.swift
//  Library
//
//  Created by Nick Baidikoff on 4/26/17.
//  Copyright © 2017 Nick Baidikoff. All rights reserved.
//

import Foundation
import UIKit

protocol ErrorHandler: class {
	func handle(_ error: Error)
}

extension ErrorHandler where Self: NSObject {
	func handle(_ error: Error) {
		print(error.localizedDescription)
	}
}

extension ErrorHandler where Self: UIViewController {
	func handle(_ error: Error) {
		let alert = UIAlertController(error: error)
		present(alert, animated: true, completion: nil)
	}
}
