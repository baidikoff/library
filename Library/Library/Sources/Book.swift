//
//  Books.swift
//  Library
//
//  Created by Nick Baidikoff on 12/26/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation

class Book {
	open let name: String
	open let url: URL
	open var isDownloaded = false
	
	init(name: String, url: URL) {
		self.name = name
		self.url = url
	}
	
	open func download() {
		isDownloaded = true
	}
}
