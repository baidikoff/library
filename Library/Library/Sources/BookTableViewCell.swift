//
//  BookTableViewCell.swift
//  Library
//
//  Created by Nick Baidikoff on 12/30/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
	
	@IBOutlet weak var bookTitleLabel: UILabel!
	@IBOutlet weak var downloadButton: UIButton!
	
	open var book : Book? {
		didSet {
			bookTitleLabel.text = book?.name
			accessoryType = (book?.isDownloaded ?? false) ? .disclosureIndicator : .none
			downloadButton.isHidden = book?.isDownloaded ?? false
		}
	}

	@IBAction func download(_ sender: UIButton) {

	}
}
