//
//  BooksTableViewController.swift
//  Library
//
//  Created by Nick Baidikoff on 12/24/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit
import VK_ios_sdk

let cellIdentifier = "bookCell"
let toBookSegueIdentifier = "toBook"

class BooksTableViewController: UITableViewController {
	// MARK: Properties
	fileprivate var isSearchActive = false
	fileprivate var worker = BooksWorker()
		
	fileprivate var offset = 0
	fileprivate let count = 50
	
	fileprivate var books: Array<Book>? {
		didSet {
			reload()
		}
	}
	
	fileprivate var vkWorker: VKWorker? {
		didSet {
			vkWorker?.register(UIDelegate: self)
		}
	}
	
	fileprivate var filteredBooks: Array<Book>? {
		didSet {
			isSearchActive = filteredBooks != nil
			reload()
		}
	}
	
	fileprivate var searchController: UISearchController = {
		let searchController = UISearchController(searchResultsController: nil)
		
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.dimsBackgroundDuringPresentation = false
		searchController.searchBar.barTintColor = UIColor(hue: 1.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
		searchController.searchBar.placeholder = "Search"
		
		return searchController
	}()
	
	// MARK: VC Lifecycle
	override func viewDidLoad() {
		books = [Book]()
		vkWorker = VKWorker(delegate: self)
		
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		tableView.tableHeaderView = searchController.searchBar
		
		fetch()
	}
	
	// MARK: Books
	open func fetch() {
		do {
			books = try worker.fetch()
		} catch let error {
			let alert = UIAlertController(error: error)
			present(alert, animated: true, completion: nil)
			books = nil
		}
	}
	
	fileprivate func filterBooks(withPredicate predicate: String) {
		worker.cancelActiveRequest()
		worker.search(withPredicate: predicate, offset: offset, count: count) { self.filteredBooks = $0 }
	}
	
	fileprivate func reload() {
		tableView.reloadData()
		if let state = vkWorker?.authorizationState, state != .authorized {
			showUnathorizedAlert()
		} else {
			if !isSearchActive && books?.count == 0 {
				showEmptyTableView()
			} else {
				tableView.clearBackground()
			}
		}
	}
	
	// MARK: Empty tableView
	fileprivate func showEmptyTableView() {
		let message = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height))
		message.text = "It's time to search for some books"
		message.textColor = .black
		message.textAlignment = .center
		message.backgroundColor = .white
		
		tableView.setBackground(view: message)
	}
	
	fileprivate func showUnathorizedAlert() {
		let alert = UIAlertController(title: "Authorization", message: "You need to be authorized to VK to search for the documents", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Login", style: .default, handler: {
			if $0.style == .default {
				self.vkWorker?.authorize()
			}
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	// MARK: Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let identifier = segue.identifier {
			if identifier == toBookSegueIdentifier {
			
			}
		}
	}
}

// MARK: - VKWorker Delegate
extension BooksTableViewController: VKWorkerDelegate {
	func vkWorker(_ worker: VKWorker, didWokeUpSessionWithState state: VKAuthorizationState) -> Void {
	}
	
	func vkWorker(_ worker: VKWorker, didFinishAuthorizationWithResult result: VKAuthorizationResult) -> Void {
	}
}

// MARK: - VKWorker UIDelegate
extension BooksTableViewController: VKWorkerUIDelegate {
	func vkWorker(_ worker: VKWorker, shouldPresentViewController viewController: UIViewController) {
		present(viewController, animated: true, completion: nil)
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
		return 70.0
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isSearchActive ? filteredBooks?.count ?? 0 : books?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookTableViewCell
		cell.book = isSearchActive ? self.filteredBooks?[indexPath.row] : self.books?[indexPath.row]
		
		return cell
	}
}

// MARK: - UISearchController Delegate
extension BooksTableViewController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		fetch()
		filteredBooks = [Book]()
	}
	
	func didDismissSearchController(_ searchController: UISearchController) {
		fetch()
		filteredBooks = nil
	}
}

// MARK: - UISearchResultsUpdating
extension BooksTableViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text, text != "" else {
			return
		}
		
		if vkWorker?.authorizationState == .authorized {
			filterBooks(withPredicate: text)
		} else if vkWorker?.authorizationState != .initialized {
			showUnathorizedAlert()
		}
	}
}
