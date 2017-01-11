//
//  BooksTableViewController.swift
//  Library
//
//  Created by Nick Baidikoff on 12/24/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit

let cellIdentifier = "bookCell"
let toBookSegueIdentifier = "toBook"

class BooksTableViewController: UITableViewController {
	fileprivate var isSearchActive = false
	fileprivate var worker = BooksWorker()
	
	fileprivate var offset = 0
	fileprivate let count = 50
	
	fileprivate var books = Array<Book>() {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	fileprivate var filteredBooks: Array<Book>? {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	fileprivate var searchController: UISearchController? {
		didSet {
			searchController?.searchResultsUpdater = self
			searchController?.hidesNavigationBarDuringPresentation = false
			searchController?.dimsBackgroundDuringPresentation = false
			
			searchController?.searchBar.barTintColor = UIColor(hue: 1.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
			searchController?.searchBar.placeholder = "Search"
			
			tableView.tableHeaderView = searchController?.searchBar
		}
	}
	
	override func viewDidLoad() {
		searchController = UISearchController(searchResultsController: nil)
	}
	
	open func fetch() {
		do {
			try worker.fetch() { self.books = $0 }
		} catch let error {
			print(error.localizedDescription)
		}
	}
	
	fileprivate func filterBooks(withPredicate predicate: String) {
		worker.cancelActiveRequest()
		worker.search(withPredicate: predicate, offset: offset, count: count) { self.filteredBooks = $0 }
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let identifier = segue.identifier, identifier == toBookSegueIdentifier {
			
		}
	}
}

// MARK: - UITableViewController Delegate
extension BooksTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: toBookSegueIdentifier, sender: self)
	}
}

// MARK: - UITableViewController Data Source
extension BooksTableViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100.0
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return isSearchActive ? 2 : 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return books.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookTableViewCell
		cell.book = self.books[indexPath.row]
		return cell
	}
}

// MARK: - UISearchBar Delegate
extension BooksTableViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		filterBooks(withPredicate: searchController.searchBar.text ?? "")
	}
}
