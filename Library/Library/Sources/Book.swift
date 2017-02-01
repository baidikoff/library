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
	
	open var path: Path?
	open var url: URL?
	
	open var isDownloaded: Bool
	
	init(name: String, path: Path) {
		self.name = name
		self.path = path
		self.isDownloaded = true
	}
	
	init(name: String, url: URL) {
		self.name = name
		self.url = url
		self.isDownloaded = false
	}
}
