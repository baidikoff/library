//
//  Books.swift
//  Library
//
//  Created by Nick Baidikoff on 12/26/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation

class Book {
	var name: String
	var url: URL
	
	init(name: String, url:URL) {
		self.name = name
		self.url = url
	}
}
