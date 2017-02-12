//
//  BooksDownloader.swift
//  Library
//
//  Created by Nick Baidikoff on 1/30/17.
//  Copyright © 2017 Nick Baidikoff. All rights reserved.
//

import Foundation
import FileKit

protocol BooksDownloaderDelegate {
	func booksDownloader(downloader: BooksDownloader, didUpdatedProgress progress: Double) -> Void
	func booksDownloader(downloader: BooksDownloader, didFinishDownloadBook book: Book) -> Void
	func booksDownloader(downloader: BooksDownloader, didCompleteWithError error: Error) -> Void
}

class BooksDownloader: NSObject {
	open var delegate: BooksDownloaderDelegate?
	open var progress: Double = 0.0 {
		didSet {
			delegate?.booksDownloader(downloader: self, didUpdatedProgress: progress)
		}
	}
	
	fileprivate let book: Book
	
	private var session: URLSession?
	private let configuration: URLSessionConfiguration = {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.allowsCellularAccess = true
		
		return configuration
	}()
	
	// MARK: - Init
	init(book: Book) {
		self.book = book
		super.init()
		self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
	}
	
	// MARK: - Download
	open func download() {
		if !book.isDownloaded, let url = book.url {
			let request = URLRequest(url: url)
			session?.downloadTask(with: request).resume()
		}
	}
}

// MARK: - URLSessionDownloadDelegate
extension BooksDownloader: URLSessionDownloadDelegate {
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		self.progress = Double(totalBytesWritten * 100 / totalBytesExpectedToWrite)
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		let path = Path.userDocuments + "books" + book.name
		var bookPath = path

		var i = 0
		while bookPath.exists {
			i += 1
			bookPath = "\(path.rawValue.characters.split(separator: ".").map(String.init).dropLast().joined())(\(i)).pdf"
		}
		
		let downloadPath = Path(url: location)
		if let downloadPath = downloadPath {
			do {
				try downloadPath.moveFile(to: bookPath)
				
				book.isDownloaded = true
				book.path = bookPath
				
				delegate?.booksDownloader(downloader: self, didFinishDownloadBook: book)
			} catch let error {
				delegate?.booksDownloader(downloader: self, didCompleteWithError: error)
			}
		}
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let error = error {
			delegate?.booksDownloader(downloader: self, didCompleteWithError: error)
		}
	}
}
