//
//  BookCollectionManager.swift
//  SladerChallenge
//
//  Created by Leo on 7/8/18.
//  Copyright © 2018 Super Art Software. All rights reserved.
//

import UIKit
import SDWebImage

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
