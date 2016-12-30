//
//  BooksWorker.swift
//  Library
//
//  Created by Nick Baidikoff on 12/26/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation

let booksPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first

public enum BooksException: Error {
	case unknownPath
	case unknownFile
}

class BooksWorker {
	
	open func fetch() throws -> Array<Book> {
		var books = Array<Book>()
		let fileManager = FileManager.default
		
		var isDirectory : ObjCBool = false
		
		guard let path = booksPath else {
			throw BooksException.unknownPath
		}
		
		if fileManager.fileExists(atPath: path, isDirectory: &isDirectory) {
			if isDirectory.boolValue {
				let directoryContents = try fileManager.contentsOfDirectory(atPath: path)
				
				directoryContents.enumerated().forEach() { offset, element in
					let url = URL(string: element)
					
					if url != nil {
						var filename = url!.lastPathComponent
						
						if filename.hasSuffix(".pdf") {
							filename = filename.characters.split(separator: ".").map(String.init).first!
							books.append(Book(name: filename, url: url!))
						}
					}
				}
			} else {
				throw BooksException.unknownFile
			}
		} else {
			try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
		}
		
		return books
	}
}
