//
//  BooksTableViewController.swift
//  Library
//
//  Created by Nick Baidikoff on 12/24/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit
import VK_ios_sdk
import UXMPDFKit
import DZNEmptyDataSet

let cellIdentifier = "bookCell"
let toAccountSegueIdentifier = "toAccount"

class BooksTableViewController: UITableViewController {
	fileprivate var isSearchActive = false
	fileprivate var booksWorker = BooksWorker()
	fileprivate var selectedRow = 0
	
	fileprivate var books: Array<Book>? = [Book]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	fileprivate var filteredBooks: Array<Book>? {
		didSet {
			isSearchActive = filteredBooks != nil
			tableView.reloadData()
		}
	}
	
	fileprivate var vkWorker: VKWorker? {
		didSet {
			vkWorker?.register(UIDelegate: self)
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
		super.viewDidLoad()
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.navigationBar.backgroundColor = .navigationBarColor
		
		vkWorker = VKWorker(delegate: self)
		
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		tableView.tableHeaderView = searchController.searchBar
		
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetDelegate = self
		
		fetch()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
	
	// MARK: Books
	open func fetch() {
		do {
			books = try booksWorker.fetch()
		} catch let error {
			let alert = UIAlertController(error: error)
			present(alert, animated: true, completion: nil)
			books = nil
		}
	}
	
	fileprivate func filterBooks(withPredicate predicate: String) {
		booksWorker.cancelActiveRequest()
		booksWorker.search(withPredicate: predicate) { self.filteredBooks = $0 }
	}
	
	// MARK: Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		searchController.dismiss(animated: true, completion: nil)
		
		if let identifier = segue.identifier, identifier == toAccountSegueIdentifier {
			(segue.destination as! AccountViewController).worker = vkWorker
		}
	}
}

// MARK: - VKWorker Delegate
extension BooksTableViewController: VKWorkerDelegate {
	func vkWorker(_ worker: VKWorker, didWokeUpSessionWithState state: VKAuthorizationState) -> Void {
		tableView.reloadEmptyDataSet()
	}
	
	func vkWorker(_ worker: VKWorker, didFinishAuthorizationWithResult result: VKAuthorizationResult) -> Void {
		tableView.reloadEmptyDataSet()
	}
}

// MARK: - VKWorker UIDelegate
extension BooksTableViewController: VKWorkerUIDelegate {
	func vkWorker(_ worker: VKWorker, shouldPresentViewController viewController: UIViewController) {
		present(viewController, animated: true, completion: nil)
	}
	
	func vkWorker(_ worker: VKWorker, needsCaptchaEnterWithError error: VKError) {
		let captchaVC = VKCaptchaViewController.captchaControllerWithError(error)
		if let captchaVC = captchaVC {
			present(captchaVC, animated: true, completion: nil)
		}
	}
}

// MARK: - UITableViewController Delegate
extension BooksTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedRow = indexPath.row
		if let book = isSearchActive ? filteredBooks?[selectedRow] : books?[selectedRow], book.isDownloaded {
			do {
				let document = try PDFDocument(filePath: book.path?.rawValue ?? "")
				let controller = PDFViewController(document: document)
				navigationController?.pushViewController(controller, animated: true)
				searchController.dismiss(animated: true, completion: nil)
			} catch let error {
				let alert = UIAlertController(error: error)
				present(alert, animated: true, completion: nil)
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete, let book = books?[indexPath.row] {
			let result = booksWorker.remove(book: book)
			if result == nil {
				tableView.beginUpdates()

				books?.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .left)
				
				tableView.endUpdates()
			} else {
				let alert = UIAlertController(error: result!)
				present(alert, animated: true, completion: nil)
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return !isSearchActive
	}
}

// MARK: - UITableViewController Data Source
extension BooksTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let count = isSearchActive ? filteredBooks?.count ?? 0 : books?.count ?? 0
		tableView.separatorStyle = count == 0 ? .none : .singleLine
		return count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookTableViewCell
		
		cell.delegate = self
		cell.book = isSearchActive ? self.filteredBooks?[indexPath.row] : self.books?[indexPath.row]
		
		return cell
	}
}

// MARK: - DZNEmptyDataSetSource
extension BooksTableViewController: DZNEmptyDataSetSource {
	func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		let attributes = [NSFontAttributeName : UIFont.emptyTitleFont]
		var title = NSAttributedString(string: "")
		
		if let worker = vkWorker {
			if worker.needsAuthorization {
				title = NSAttributedString(string: "Needs authorization", attributes: attributes)
			} else {
				title = NSAttributedString(string: "It's time to search for books", attributes: attributes)
			}
		}
		
		return title
	}
	
	func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		let attributes = [NSFontAttributeName : UIFont.emptyDescriptionFont]
		if let worker = vkWorker, worker.needsAuthorization {
			return NSAttributedString(string: "You need to authorize to VK to search for the books", attributes: attributes)
		}
		
		return NSAttributedString(string: "", attributes: attributes)
	}
	
	func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
		if let worker = vkWorker, worker.needsAuthorization {
			return state == .highlighted ? #imageLiteral(resourceName: "pressedLoginButton") : #imageLiteral(resourceName: "loginButton")
		} else {
			return nil
		}
	}
	
	func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
		return (tableView.tableHeaderView?.bounds.height ?? 0.0) * -1.0
	}
}

// MARK: - DZNEmptyDataSetDelegate
extension BooksTableViewController: DZNEmptyDataSetDelegate {
	func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
		vkWorker?.authorize()
	}
}

// MARK: - UISearchController Delegate
extension BooksTableViewController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		filteredBooks = [Book]()
	}
	
	func willDismissSearchController(_ searchController: UISearchController) {
		fetch()
		filteredBooks = nil
	}
	
	func didDismissSearchController(_ searchController: UISearchController) {
		tableView.reloadData()
	}
}

// MARK: - UISearchResultsUpdating
extension BooksTableViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text, text != "" else {
			return
		}
		
		if let worker = vkWorker, !worker.needsAuthorization {
			filterBooks(withPredicate: text)
		} else {
			tableView.reloadEmptyDataSet()
		}
	}
}

// MARK: - BookTableViewCellErrorDelegate
extension BooksTableViewController: BookTableViewCellErrorDelegate {
	func bookTableViewCell(cell: BookTableViewCell, didReceiveError error: Error) {
		let alert = UIAlertController(error: error)
		present(alert, animated: true, completion: nil)
	}
}
