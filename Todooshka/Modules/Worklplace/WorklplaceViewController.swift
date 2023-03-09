//
//  WorklplaceViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.01.2023.
//

import RxCocoa
import RxSwift
import UIKit

class WorklplaceViewController: UIViewController {
  public var viewModel: WorklplaceViewModel!
  public var nestedViewControllers: [UIViewController] = []
  
  private let disposeBag = DisposeBag()
  
  private lazy var pageViewController: UIPageViewController = {
      let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
      page.view.translatesAutoresizingMaskIntoConstraints = false
      page.delegate = self
      page.dataSource = self
      return page
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  func configureUI() {
    view.addSubviews([
      pageViewController.view
    ])
    
    pageViewController.view.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor
    )
    
    if let firstVC = nestedViewControllers.first {
      pageViewController.setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
    }
  }
  
  func bindViewModel() {
    let input = WorklplaceViewModel.Input()
    
    let outputs = viewModel.transform(input: input)
    
//    [
//     
//    ]
//      .forEach { $0.disposed(by: disposeBag) }
  }
  
  // MARK: - Binders
  var scrollToPageBinder: Binder<Int> {
    return Binder(self, binding: { vc, newIndex in
      guard
        let pageViewControllers = vc.pageViewController.viewControllers,
        let presentedViewController = pageViewControllers.first,
        let presentedIndex = vc.nestedViewControllers.firstIndex(of: presentedViewController),
        let newViewController = vc.nestedViewControllers[safe: newIndex]
      else { return }
      
      vc.pageViewController.setViewControllers(
        [newViewController],
        direction: (newIndex > presentedIndex) ? .forward : .reverse,
        animated: true)
    })
  }

}

// MARK: - UIPageViewControllerDataSource
extension WorklplaceViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = nestedViewControllers.firstIndex(of: viewController), index > 0 else { return nil }
        return nestedViewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = nestedViewControllers.firstIndex(of: viewController), index < nestedViewControllers.count - 1 else { return nil }
        return nestedViewControllers[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension WorklplaceViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
            let currentViewController = pageViewController.viewControllers?.first,
            let index = nestedViewControllers.firstIndex(of: currentViewController) else {
            return
        }
    }
}
