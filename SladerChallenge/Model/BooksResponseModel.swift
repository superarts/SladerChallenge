//
//  BooksResponseModel.swift
//  SladerChallenge
//
//  Created by Leo on 7/8/18.
//  Copyright © 2018 Super Art Software. All rights reserved.
//

import Foundation

//	Wrapper model to handle response JSON
struct BooksResponseModel: Decodable {
	var books: [BookModel]
}

