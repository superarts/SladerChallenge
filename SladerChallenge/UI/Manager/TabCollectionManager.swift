//
//  TabCollectionManager.swift
//  SladerChallenge
//
//  Created by Leo on 7/8/18.
//  Copyright © 2018 Super Art Software. All rights reserved.
//

import UIKit

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
		//	TODO: handle cell logic in its view model
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
