//
//  SearchViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 24.05.2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchViewController: TDViewController {
  private let disposeBag = DisposeBag()

  public var viewModel: SearchViewModel!
  public var viewControllers: [UIViewController] = []
  
  private let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.backgroundColor = Style.App.background
    searchBar.placeholder = "Дела, люди"
    searchBar.barTintColor = Style.App.background
    searchBar.borderWidth = 0.0
    searchBar.backgroundImage = UIImage()
    searchBar.searchTextField.backgroundColor = Style.TextFields.AuthTextField.Background
    return searchBar
  }()
  
  private let questsPageButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Квесты",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
    let button = UIButton(type: .system)
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    return button
  }()
  
  private let usersPageButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Люди",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
    let button = UIButton(type: .system)
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    return button
  }()
  
  private let searchButtonLeftDividerView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.7)
    return view
  }()
  
  private let searchButtonRightDividerView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.2)
    return view
  }()
  
  private var pageViewController: UIPageViewController!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configurePageViewController()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    titleLabel.text = "Задания"
    backButton.isHidden = false
    
    hideKeyboardWhenTappedAround()
    searchBar.becomeFirstResponder()
   
    let searchButtonsStackView = UIStackView(arrangedSubviews: [questsPageButton, usersPageButton])
    searchButtonsStackView.axis = .horizontal
    searchButtonsStackView.distribution = .fillEqually
    
    pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    pageViewController.delegate = self
    pageViewController.dataSource = self
    
    addChild(pageViewController)
    
    view.addSubviews([
      searchBar,
      searchButtonsStackView,
      searchButtonLeftDividerView,
      searchButtonRightDividerView,
      pageViewController.view
    ])
    
    searchBar.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      heightConstant: 40
    )
    
    searchButtonsStackView.anchor(
      top: searchBar.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      heightConstant: 30
    )
    
    searchButtonLeftDividerView.anchor(
      top: searchButtonsStackView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 4,
      widthConstant: UIScreen.main.bounds.width / 2,
      heightConstant: 0.5
    )
    
    searchButtonRightDividerView.anchor(
      top: searchButtonsStackView.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 4,
      widthConstant: UIScreen.main.bounds.width / 2,
      heightConstant: 0.5
    )
    
    pageViewController.view.anchor(
      top: searchButtonLeftDividerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor
    )
  }
  
  func configurePageViewController() {
    for viewController in viewControllers {
//      if let viewController = viewController as? UserProfileTaskListViewContoller {
//        viewController.configureUI()
//        viewController.configureDataSource()
//        viewController.bindViewModel()
//      }
//      
//      if let viewController = viewController as? UserProfilePublicationsViewController {
//        viewController.configureUI()
//        viewController.configureDataSource()
//        viewController.bindViewModel()
//      }
    }
    
    if let firstVC = viewControllers.first {
      self.pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
     }
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = SearchViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      // search
      questsButtonClickTrigger: questsPageButton.rx.tap.asDriver(),
      usersButtonClickTrigger: usersPageButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)
    
    [
      outputs.navigateBack.drive(),
      outputs.scrollToPage.drive(scrollToPageBinder)
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  // MARK: - Binder
  var scrollToPageBinder: Binder<Int> {
    return Binder(self, binding: { vc, targetIndex in
      vc.scrollToPage(index: targetIndex, animated: true)
    })
  }
  
  func scrollToPage(index: Int, animated: Bool) {
    guard index >= 0, index < viewControllers.count else {
      print("Invalid index")
      return
    }
    
    let direction: UIPageViewController.NavigationDirection = index > (viewControllers.first.flatMap(viewControllers.firstIndex) ?? 0) ? .forward : .reverse
    pageViewController.setViewControllers([viewControllers[index]], direction: direction, animated: animated, completion: nil)
    
    if index == 0 {
      searchButtonLeftDividerView.backgroundColor = .black.withAlphaComponent(0.7)
      searchButtonRightDividerView.backgroundColor = .black.withAlphaComponent(0.2)
    } else {
      searchButtonLeftDividerView.backgroundColor = .black.withAlphaComponent(0.2)
      searchButtonRightDividerView.backgroundColor = .black.withAlphaComponent(0.7)
    }
  }
}


extension SearchViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let index = viewControllers.firstIndex(of: viewController) else { return nil }
    
    let previousIndex = index - 1
    
    guard previousIndex >= 0 else { return nil }
    guard viewControllers.count > previousIndex else { return nil }
    
    return viewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let index = viewControllers.firstIndex(of: viewController) else { return nil }
    
    let nextIndex = index + 1
    
    guard viewControllers.count != nextIndex else { return nil }
    guard viewControllers.count > nextIndex else { return nil }
    
    return viewControllers[nextIndex]
  }
}

extension SearchViewController: UIPageViewControllerDelegate {
  
}

