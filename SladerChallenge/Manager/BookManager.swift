//
//  BookManager.swift
//  SladerChallenge
//
//  Created by Leo on 7/8/18.
//  Copyright © 2018 Super Art Software. All rights reserved.
//

import ReactiveSwift

/**
* Protocol: books management is required
*/
protocol RequiresBooks: RequiresDependency {
	var bookManager: BookManager! { get }
}

extension RequiresBooks {
	var bookManager: BookManager! {
		return dependencyManager.bookManager()
	}
}

/**
* Reactive book manager. Call `request()` to start loading, and subscribe `books`, `error` for response.
*/
protocol BookManager {
	static var shared: BookManager { get }
	
	var books: MutableProperty<[BookModel]> { get }
	var error: MutableProperty<Error?> { get }
	
	func request()
}

/**
* Book manager reads local JSON for example data.
*/
struct ExampleBookManager: BookManager {
	public static var shared: BookManager = ExampleBookManager()
	
	public var books = MutableProperty<[BookModel]>([BookModel]())
	public var error = MutableProperty<Error?>(nil)
	
	public func request() {
		let jsonString = stringFromMainBundle(filename: "example_books", type: "json")
		if let jsonData = jsonString?.data(using: .utf8) {
			if let response = try? JSONDecoder().decode(BooksResponseModel.self, from: jsonData) {
				self.books.value = response.books
			} else {
				// TODO: add error handling here
			}
		}
	}
	
	private func stringFromMainBundle(filename: String, type: String) -> String? {
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
}

//	TODO: NetworkBookManger that reads book data from API endpoint.
