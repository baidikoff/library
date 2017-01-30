//
//  BooksWorker.swift
//  Library
//
//  Created by Nick Baidikoff on 12/26/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import Foundation
import VK_ios_sdk
import SwiftyJSON

private let record = "Book"
private let booksPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first
private let `extension` = ".pdf"
private let truePredicate = NSPredicate(format: "TRUEPREDICATE")
private let ckNameKey = "Name"
private let ckUrlKey = "URL"

private let searchMethod = "docs.search"
private let itemsKey = "items"
private let typeKey = "type"
private let extensionKey = "ext"
private let pdf = "pdf"
private let nameKey = "title"
private let urlKey = "url"
private let queue = DispatchQueue(label: (Bundle.main.bundleIdentifier?.appending(String(describing: BooksWorker.self)))!)

public enum BooksException: Error {
	case unknownPath
	case unknownFile
}

class BooksWorker {
	fileprivate var activeRequest: VKRequest?
	
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
					
					if let url = url {
						var filename = url.lastPathComponent
						
						if filename.hasSuffix(`extension`) {
							let book = Book(name: filename.characters.split(separator: ".").map(String.init).first!, url: url)
							book.isDownloaded = true
							books.append(book)
						}
					}
				}
			} else {
				throw BooksException.unknownFile
			}
		} else {
			try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
		}
	}
	
	open func search(withPredicate predicate: String, offset: Int, count: Int, completionHandler: @escaping (_ books: Array<Book>) -> Void) {
		queue.async {
			self.activeRequest = VKRequest(method: searchMethod, parameters: [VK_API_Q: predicate, VK_API_OFFSET: offset, VK_API_COUNT: 100])
			self.activeRequest?.execute(resultBlock: { responce in
				var books = Array<Book>()
				let json = JSON(responce?.json as! Dictionary<String, Any>)
				
				defer {
					DispatchQueue.main.async {
						completionHandler(books)
					}
				}
				
				guard let items = json[itemsKey].array else {
					return
				}
				
				for item: JSON in items {
					guard let dictionary = item.dictionary,
								let type = dictionary[typeKey]?.uInt8,
								let ext = dictionary[extensionKey]?.string else {
						continue
					}
					
					if type == 1 && ext == "pdf" {
						let name = dictionary[nameKey]?.string
						let url = URL(string: dictionary[urlKey]?.string ?? "")
						
						if let name = name, let url = url {
							books.append(Book(name: name, url: url))
						}
					}
				}
			}) { error in
				print(error?.localizedDescription ?? "hello")
			}
		}
	}
	
	open func cancelActiveRequest() {
		activeRequest?.cancel()
	}
}
