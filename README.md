# Requirements

## General Instructions

- The goal is to recreate the Slader homescreen
- You only have to implement the state where books are available
- You do not have to implement the ad part nor do you have to consider the case where there are no books for display

## Design Specifics

- On a tap on settings/search/scan/browse/book, simply show a dismisable alert view controller
- Do not forget the top-right image behind the books
- For sizing, feel free to estimate
- The font used is Helvetica Neue
- Colors used are white (#ffffff), black (#000000) and light gray (#efefef)

## Bonus

- On a short tap on a book, show a dismissable alert view controller. On a long tap on the book, shake the book infinitely and show the dismiss/delete option.

# About SladerChallenge

## UI

Although the original Slader app only supports portrait mode on iPhone, in this project safe area and orientation are supported. Most UI customization has been done in storyboard, which works great for small team.

`BookCollectionManager` and `TabCollectionManager` handles `UICollectionViews` in `HomeViewController`.

For proper architecture, view models for `UIViewControllers` and `UICollectionViewCells` should be implemented. Also, a `NavigationManager` should be built to handle navigation. See my other projects for samples.

## About Protocols

To eliminate Singleton Pattern, protocols are used to "hide" singleton instances and indicate dependencies. For example, even though books are stored in a shared instance of `BookManager` (which is `ExampleBookManager` in this example), components that depends on it need to confirm to protocol `RequiresBooks` to access the shared `bookManager` instance. This is to prevent global level dependency: nothing should be required by everything.

Also, protocols are widely used as interfaces. In theory all non UI modules should provides protocols to make unit tests easier, and even UI related modules can work in this way to support multiple implementation. Currently only one example implementation `ExampleBookManager` is provided.

## About Dependency Injection

`DependencyManager`, which is based on `Dip`, handles runtime dependency injection. Even `DependencyManager` can be replaced by other implementations like `Swinject` easily, as long as it's renamed to `DipDependencyManager` and a `protocol DependencyManager` is created. As mentioned in `About Protocols`, even though the manager itself is a shared singleton instance, it should only be accessed by classes that confirm to protocol `RequiresDependency`.

## Vendor library

`GradientView` has been added to implement shadow effect on top of tab bar in `HomeViewController`. It's fully `@IBInspectable`.

## Unit tests

To-do.