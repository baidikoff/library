//
//  BooksTableViewController.swift
//  Library
//
//  Created by Nick Baidikoff on 12/24/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit

let cellIdentifier = "bookCell"

class BooksTableViewController: UITableViewController {
	
	fileprivate var isSearchActive = false
	fileprivate var worker = BooksWorker()
	fileprivate var books = Array<Book>() {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.clearsSelectionOnViewWillAppear = false
		self.navigationController?.navigationBar.isTranslucent = true
		
		do {
			self.books = try worker.fetch()
		} catch let error {
			print(error.localizedDescription)
		}
	}
}

// MARK: - UITableViewController Delegate
extension BooksTableViewController {
	
}

// MARK: - UITableViewController Data Source
extension BooksTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return isSearchActive ? 2 : 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return books.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		return cell
	}
}
