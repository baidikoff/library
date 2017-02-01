//
//  BooksDownloader.swift
//  Library
//
//  Created by Nick Baidikoff on 1/30/17.
//  Copyright © 2017 Nick Baidikoff. All rights reserved.
//

import Foundation

protocol BooksDownloaderDelegate {
	func booksDownloader(downloader: BooksDownloader, didUpdatedProgress progress: Double) -> Void
}

class BooksDownloader : NSObject {
	
	open var delegate: BooksDownloaderDelegate?
	open var progress: Double = 0.0 {
		didSet {
			delegate?.booksDownloader(downloader: self, didUpdatedProgress: progress)
		}
	}

	private let book: Book
	private var session: URLSession?
	
	private let configuration: URLSessionConfiguration = {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.allowsCellularAccess = true

		return configuration
	}()
	
	init(book: Book) {
		self.book = book
		super.init()
		self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
	}

	open func download() {
		if !book.isDownloaded, let url = book.url {
			let request = URLRequest(url: url)
			session?.downloadTask(with: request).resume()
		}
	}
}

extension BooksDownloader : URLSessionDownloadDelegate {
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		DispatchQueue.main.async {
			self.progress = Double(totalBytesWritten / totalBytesExpectedToWrite)
		}
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		
	}
}
