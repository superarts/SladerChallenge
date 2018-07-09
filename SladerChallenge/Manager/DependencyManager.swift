//
//  DependencyManager.swift
//  SladerChallenge
//
//  Created by Leo on 7/8/18.
//  Copyright © 2018 Super Art Software. All rights reserved.
//

import Dip

/**
* Protocol: dependency resolving is required
*/
protocol RequiresDependency {
	var dependencyManager: DependencyManager! { get }
}

extension RequiresDependency {
	var dependencyManager: DependencyManager! {
		return DependencyManager.shared
	}
}

/**
* A dependency manager powered by Dip
*/

// swiftlint:disable force_try
// Dependency checking is performed in WWDependencyTests.  It doesn't make sense to catch exceptions here,
// as broken dependencies will definitely crash the app and should always be fixed before merging to master/develop branch.

class DependencyManager {
	public static var shared = DependencyManager()
	
	let container = DependencyContainer.setup()
	
	// Resolving singleton instance
	public func bookManager() -> BookManager {
		let type = try! container.resolve() as BookManager.Type
		return type.shared
	}
	
	// Resolving new class instance
	/*
	func viewModel() -> ViewModel {
	return try! container.resolve() as ViewModel
	}
	*/
}

/// Actual dependencies
extension DependencyContainer {
	static func setup() -> DependencyContainer {
		return DependencyContainer { container in
			unowned let container = container
			
			//container.register { DummyViewModel() as ViewModel }
			
			container.register { ExampleBookManager.self as BookManager.Type }
		}
	}
}
