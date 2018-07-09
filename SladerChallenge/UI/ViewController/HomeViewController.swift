//
//  ViewController.swift
//  SladerChallenge
//
//  Created by Leo on 7/6/18.
//  Copyright © 2018 Super Art Software. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, RequiresDependency, RequiresBooks {

	@IBOutlet var settingsButton: UIButton!
	@IBOutlet var bookCollectionView: UICollectionView!
	@IBOutlet var tabCollectionView: UICollectionView!

	let bookCollectionManager = BookCollectionManager()
	let tabCollectionManager = TabCollectionManager()

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBookCollectionView()
		setupBookManager()
		setupTabBar()

		//	Setup navigation background image (logo text)
		let navbarImage = UIImage(named: "logo_text")!.stretchableImage(withLeftCapWidth: 1, topCapHeight: 1)
		UINavigationBar.appearance().setBackgroundImage(navbarImage, for: .default)

		//	Resize settingsButton
		settingsButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
		settingsButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
	}

	private func setupBookCollectionView() {
		bookCollectionView.delegate = bookCollectionManager
		bookCollectionView.dataSource = bookCollectionManager
		bookCollectionManager.selectHandler = { book in
			self.showAlert(message: "Book selected: \(book.title)")
		}
		bookCollectionManager.deleteHandler = { book, indexPath in
			self.bookCollectionManager.books = self.bookCollectionManager.books.filter { $0 != book }
			self.bookCollectionView.reloadData()
		}
	}

	private func setupBookManager() {
		//	TODO: move to view model
		bookManager.books.producer.startWithValues { books in
			guard !books.isEmpty else {
				return
			}
			self.bookCollectionManager.books = books
			self.bookCollectionView.reloadData()
		}
		bookManager.error.producer.startWithValues { error in
			if error != nil {
				self.showAlert(message: "BookManager failed: " + (error?.localizedDescription ?? "nil"))
			}
		}
		bookManager.request()
	}

	private func setupTabBar() {
		tabCollectionView.delegate = tabCollectionManager
		tabCollectionView.dataSource = tabCollectionManager
		tabCollectionManager.selectHandler = { type in
			self.showAlert(message: "Tab selected: \(type)")
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews() 
		//	Update collection view layouts when orientation changes
		tabCollectionView.collectionViewLayout.invalidateLayout()
		bookCollectionView.collectionViewLayout.invalidateLayout()
	}

	private func showAlert(message: String) {
		//	TODO: this is just a placeholder function
        let alert = UIAlertController(title: "Placeholder", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
	}

	@IBAction func actionSettings() {
		showAlert(message: "Settings")
	}
}

