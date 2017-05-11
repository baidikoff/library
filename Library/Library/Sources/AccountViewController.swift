//
//  AccountViewController.swift
//  Library
//
//  Created by Nick Baidikoff on 12/26/16.
//  Copyright © 2016 Nick Baidikoff. All rights reserved.
//

import UIKit
import VK_ios_sdk
import SwiftyUserDefaults

class AccountViewController: UIViewController {
	private let notAuthorizedText = "You're not authorized yet"
	
	@IBOutlet weak var name: UILabel! {
		didSet {
			name.text = Defaults[.user] ?? notAuthorizedText
		}
	}
	
	@IBOutlet weak var imageView: UIImageView! {
		didSet {
			imageView.image = Defaults[.photo]
			imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
			imageView.layer.borderWidth = 3.0
			imageView.layer.borderColor = UIColor.black.cgColor
			imageView.clipsToBounds = true
		}
	}
	
	@IBOutlet weak var logoutButton: UIButton! {
		didSet {
			logoutButton.setImage(#imageLiteral(resourceName: "pressedLogoutButton"), for: .highlighted)
		}
	}
	
	open var worker: VKWorker?
	
	@IBAction func onLogoutAction(_ sender: UIButton) {
		worker?.unauthorize()
		name.text = notAuthorizedText
		imageView.image = nil
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		view.backgroundColor = .navigationBarColor
	}
}
