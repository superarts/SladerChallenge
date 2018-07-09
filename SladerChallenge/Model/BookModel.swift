//
//  BookModel.swift
//  SladerChallenge
//
//  Created by Leo on 7/8/18.
//  Copyright © 2018 Super Art Software. All rights reserved.
//

import Foundation

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
