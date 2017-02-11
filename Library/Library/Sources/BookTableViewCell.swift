//
//  BookTableViewCell.swift
//  Library
//
//  Created by Nick Baidikoff on 12/30/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class BookTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var bookTitleLabel: UILabel!
	@IBOutlet weak var downloadButton: UIButton!
	
	@IBOutlet weak var progressView: MBCircularProgressBarView! {
		didSet {
			progressView.isHidden = true
		}
	}
	
	fileprivate var downloader: BooksDownloader?
	fileprivate var progress: Double? {
		didSet {
			DispatchQueue.main.async {
				UIView.animate(withDuration: 0.1) {
					self.progressView.value = CGFloat(self.progress ?? 0.0)
				}
			}
		}
	}
	
	open var book : Book? {
		didSet {
			bookTitleLabel.text = book?.name
			accessoryType = (book?.isDownloaded ?? false) ? .disclosureIndicator : .none
			downloadButton.isHidden = book?.isDownloaded ?? false
			titleWidthConstraint.constant = downloadButton.isHidden ? -50.0 : 8.0
		}
	}

	@IBAction func download(_ sender: UIButton) {
		if let book = book {
			downloader = BooksDownloader(book: book)
			downloader?.delegate = self
			downloader?.download()
			
			downloadButton.isHidden = true
			progressView.isHidden = false
		}
	}
}

extension BookTableViewCell: BooksDownloaderDelegate {
	func booksDownloader(downloader: BooksDownloader, didUpdatedProgress progress: Double) {
		self.progress = progress
	}
	
	func booksDownloader(downloader: BooksDownloader, didFinishDownloadBook book: Book) {
		accessoryType = .disclosureIndicator
		progressView.isHidden = true
		titleWidthConstraint.constant = -50.0
	}
}
