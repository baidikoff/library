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

	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	
	open var worker: VKWorker?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		name.text = Defaults[.user] ?? ""
		imageView.image = Defaults[.photo]
	}
	
	@IBAction func onLogoutAction(_ sender: UIButton) {
		worker?.unauthorize()
	}
}
