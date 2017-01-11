//
//  BooksWorker.swift
//  Library
//
//  Created by Nick Baidikoff on 12/26/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation
import CloudKit
import VK_ios_sdk
import SwiftyJSON

public enum BooksException: Error {
	case unknownPath
	case unknownFile
	
	case iCloudFetchError
}

class BooksWorker {
	
	let container: CKContainer
	let privateDatabase: CKDatabase
	
	fileprivate var activeRequest: VKRequest?
 
	init() {
		self.container = CKContainer.default()
		self.privateDatabase = self.container.privateCloudDatabase
	}
	
	private let record = "Book"
	private let booksPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first
	private let `extension` = ".pdf"
	private let truePredicate = NSPredicate(format: "TRUEPREDICATE")
	private let ckNameKey = "Name"
	private let ckUrlKey = "URL"
	
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
				
				directoryContents.enumerated().forEach() { _, element in
					let url = URL(string: element)
					
					if url != nil {
						var filename = url!.lastPathComponent
						
						if filename.hasSuffix(`extension`) {
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
		
		let query = CKQuery(recordType: record, predicate: truePredicate)
		self.privateDatabase.perform(query, inZoneWith: nil) { results, error in
			if error != nil {
				return
			}
			
			results?.forEach() { record in
				if let urlString = record[self.ckUrlKey] as? String {
					let url = URL(string: urlString)
					let name = record[self.ckNameKey] as? String
					
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
	
	private let searchMethod = "docs.search"
	private let itemsKey = "items"
	private let typeKey = "type"
	private let extensionKey = "ext"
	private let pdf = "pdf"
	private let nameKey = "name"
	private let urlKey = "url"
	
	open func search(withPredicate predicate: String, offset: Int, count: Int, completionHandler: @escaping (_ books: Array<Book>) -> Void) {
		activeRequest = VKRequest(method: searchMethod, parameters: [VK_API_Q: predicate, VK_API_OFFSET: offset, VK_API_COUNT: count])
		activeRequest?.execute(resultBlock: { responce in
			var books = Array<Book>()
			let json = JSON(responce?.json as! Dictionary)
			let items = json[self.itemsKey].array
			items?.enumerated().forEach { offset, element in
				if element[self.typeKey].uInt8 == 1, element[self.extensionKey].string == self.pdf {
					let name = element[self.nameKey].string
					let url = URL(string: element[self.urlKey].string!)
					
					if let name = name, let url = url {
						books.append(Book(name: name, url: url))
					}
				}
			}
			
			DispatchQueue.main.async {
				completionHandler(books)
			}
		}) { error in
			print(error?.localizedDescription ?? "hello")
		}
	}
	
	open func cancelActiveRequest() {
		activeRequest?.cancel()
	}
}
