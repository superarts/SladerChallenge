//
//  ViewController.swift
//  SladerChallenge
//
//  Created by Leo on 7/6/18.
//  Copyright © 2018 Super Art Software. All rights reserved.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController {

	@IBOutlet var settingsButton: UIButton!
	@IBOutlet var bookCollectionView: UICollectionView!
	@IBOutlet var tabCollectionView: UICollectionView!

	let bookCollectionManager = BookCollectionManager()
	let tabCollectionManager = TabCollectionManager()

	override func viewDidLoad() {
		super.viewDidLoad()

		//	Load example data
		let jsonString = stringFromMainBundle(filename: "example_books", type: "json")
        if let jsonData = jsonString?.data(using: .utf8) {
            let response = try? JSONDecoder().decode(BooksResponseModel.self, from: jsonData)
			bookCollectionManager.books = response?.books ?? [BookModel]()
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

		tabCollectionView.delegate = tabCollectionManager
		tabCollectionView.dataSource = tabCollectionManager
		tabCollectionManager.selectHandler = { type in
			self.showAlert(message: "Tab selected: \(type)")
		}

		//	Setup navigation background image (logo text)
		let navbarImage = UIImage(named: "logo_text")!.stretchableImage(withLeftCapWidth: 1, topCapHeight: 1)
		UINavigationBar.appearance().setBackgroundImage(navbarImage, for: .default)

		//	Resize settingsButton
		settingsButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
		settingsButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func stringFromMainBundle(filename: String, type: String) -> String? {
		if let filepath = Bundle.main.path(forResource: filename, ofType: type) {
			do {
				return try String(contentsOfFile: filepath)
			} catch {
				//	Failed reading contents
				return nil
			}
		} else {
			//	File not found
			return nil
		}
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

//	Change `Decodable` to `Codable` when encoding is required
struct BookModel: Decodable {
	var title: String
	var isbn: String
	var coverImageURL: String

	enum CodingKeys: String, CodingKey {
		case title, isbn
		case coverImageURL = "coverImageUrl:"		//	<- This is just a workaround. Please fix server JSON.
	}
}

extension BookModel: Equatable {
	static func == (lhs: BookModel, rhs: BookModel) -> Bool {
		return lhs.isbn == rhs.isbn
	}
}

//	Wrapper model to handle response JSON
struct BooksResponseModel: Decodable {
	var books: [BookModel]
}

class BookCollectionManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

	public var selectHandler: ((BookModel) -> Void)?
	public var deleteHandler: ((BookModel, IndexPath) -> Void)?
	public var books = [BookModel]()

	private let rowMax = 3
}

// MARK: UICollectionViewDelegate
extension BookCollectionManager {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
		let book = books[indexPath.section * rowMax + indexPath.row]

		cell.titleLabel.text = book.title
		cell.isbnLabel.text = book.isbn
		cell.coverImage.sd_setImage(with: URL(string: book.coverImageURL), placeholderImage: UIImage(named: "default_book_thumbnail.png"))
		cell.coverImage.layer.cornerRadius = 5
		cell.coverImage.clipsToBounds = true
		cell.deleteHandler = {
			self.deleteHandler?(book, indexPath)
		}

        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(ceil(Float(books.count) / Float(rowMax)))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (section < books.count / rowMax) ? rowMax : (books.count % rowMax)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension BookCollectionManager {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (collectionView.bounds.width - 10 * 2 - 10 * 2) / CGFloat(rowMax)
        return CGSize(width: width, height: width * 2)
    }
}

// MARK: UICollectionViewDelegate
extension BookCollectionManager {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let book = books[indexPath.section * rowMax + indexPath.row]
		selectHandler?(book)
	}
}

class BookCell: UICollectionViewCell {

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var isbnLabel: UILabel!
	@IBOutlet var coverImage: UIImageView!
	@IBOutlet var longPressView: UIView!

	public var deleteHandler: (() -> Void)?

	private var longPressGesture: UILongPressGestureRecognizer!
	private let wiggleAnimation = CAKeyframeAnimation()
	private var isAnimating = false

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupGesture()
		setupAnimation()
	}

	private func setupGesture() {
		longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
		self.addGestureRecognizer(longPressGesture)
	}

	private func setupAnimation() {
		let force: CGFloat = 0.5
		wiggleAnimation.keyPath = "transform.rotation"
		wiggleAnimation.values = [0, 0.1*force, -0.1*force, 0.1*force, 0]
		wiggleAnimation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
		wiggleAnimation.duration = CFTimeInterval(1)
		wiggleAnimation.repeatCount = .infinity
		wiggleAnimation.beginTime = CACurrentMediaTime()
	}

	@objc func onLongPress(_ gesture: UIPanGestureRecognizer) {
		if !isAnimating {
			isAnimating = true
			layer.add(wiggleAnimation, forKey: "wiggle")
			UIView.animate(withDuration: 0.3, animations: {
				self.longPressView.alpha = 1
			})
		}
	}

	@IBAction func actionDismiss() {
		layer.removeAllAnimations()
		isAnimating = false
		UIView.animate(withDuration: 0.3, animations: {
			self.longPressView.alpha = 0
		})
	}

	@IBAction func actionDelete() {
		longPressView.alpha = 0
		deleteHandler?()
	}
}

class TabCollectionManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

	public enum ItemType {
		case search, scan, browse
	}

	public var selectHandler: ((ItemType) -> Void)?
	public var books = [BookModel]()
	
	private let items = [ (
		type: ItemType.search,
		title: "SEARCH",
		icon: "icon_search"
	), (
		type: ItemType.scan,
		title: "SCAN",
		icon: "icon_scan"
	), (
		type: ItemType.browse,
		title: "BROWSE",
		icon: "icon_browse"
	) ]
}


// MARK: UICollectionViewDelegate
extension TabCollectionManager {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as! TabCell
		let item = items[indexPath.row]
		cell.titleLabel.text = item.title
		cell.iconImage.image = UIImage(named: item.icon)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension TabCollectionManager {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = collectionView.bounds.width / CGFloat(items.count)
        return CGSize(width: width, height: 80)
    }
}

// MARK: UICollectionViewDelegate
extension TabCollectionManager {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = items[indexPath.row]
		selectHandler?(item.type)
	}
}

class TabCell: UICollectionViewCell {
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var iconImage: UIImageView!
}