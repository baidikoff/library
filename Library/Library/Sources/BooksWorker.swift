//
//  BooksWorker.swift
//  Library
//
//  Created by Nick Baidikoff on 12/26/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation
import CloudKit

let record = "Book"
let booksPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first

public enum BooksException: Error {
	case unknownPath
	case unknownFile
	
	case iCloudFetchError
}

class BooksWorker {
	
	let container: CKContainer
	let privateDatabase: CKDatabase
 
	init() {
		self.container = CKContainer.default()
		self.privateDatabase = self.container.privateCloudDatabase
	}
	
	open func fetch(_ completionHandler: @escaping (Array<Book>) -> Void) throws {
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
		
		let query = CKQuery(recordType: record, predicate: NSPredicate(format: "TRUEPREDICATE"))
		self.privateDatabase.perform(query, inZoneWith: nil) { results, error in
			if error != nil {
				return
			}
			
			results?.forEach() { record in
				if let urlString = record["URL"] as? String {
					let url = URL(string: urlString)
					let name = record["Name"] as? String
					
					if name != nil && url != nil {
						books.append(Book(name: name!, url: url!))
					}
				}
			}
			
			DispatchQueue.main.async {
				completionHandler(books)
			}
		}
	}
}
