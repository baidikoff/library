//
//  Books.swift
//  Library
//
//  Created by Nick Baidikoff on 12/26/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation
import FileKit

class Book {
	open let name: String
	open let path: Path
	open var isDownloaded = false
	
	init(name: String, path: Path) {
		self.name = name
		self.path = path
	}
	
	open func download() {
		isDownloaded = true
	}
}
