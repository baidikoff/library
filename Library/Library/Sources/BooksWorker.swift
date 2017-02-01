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
import FileKit

private let booksDirectory = Path.userDocuments + "books"

private let searchMethod = "docs.search"
private let itemsKey = "items"
private let typeKey = "type"
private let extensionKey = "ext"
private let pdf = "pdf"
private let nameKey = "title"
private let urlKey = "url"
private let queue = DispatchQueue(label: (Bundle.main.bundleIdentifier?.appending(String(describing: BooksWorker.self)))!)

class BooksWorker {
	fileprivate var activeRequest: VKRequest?
	
	open func fetch() throws -> Array<Book> {
		var books = Array<Book>()
		
		if !booksDirectory.exists {
			try booksDirectory.createDirectory()
		}
		
		for bookPath in booksDirectory {
			guard let bookName = bookPath.components.last?.rawValue.characters.split(separator: ".").map(String.init).first else { continue }
			
			let book = Book(name: bookName, path: bookPath)
			books.append(book)
		}
		
		return books
	}
	
	open func search(withPredicate predicate: String, offset: Int, count: Int, completionHandler: @escaping (_ books: Array<Book>) -> Void) {
		queue.async {
			self.activeRequest = VKRequest(method: searchMethod, parameters: [VK_API_Q: predicate, VK_API_OFFSET: offset, VK_API_COUNT: count])
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
					
					if type == 1 && ext == pdf {
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
