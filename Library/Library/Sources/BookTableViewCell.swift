//
//  BookTableViewCell.swift
//  Library
//
//  Created by Nick Baidikoff on 12/30/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
	
	open var book : Book? {
		didSet {
			bookTitleLabel.text = book?.name
		}
	}
	
	@IBOutlet weak var bookCoverView: UIImageView! {
		didSet {
			bookCoverView.image = #imageLiteral(resourceName: "defaultBookIcon")
		}
	}
	
	@IBOutlet weak var bookTitleLabel: UILabel!
}
