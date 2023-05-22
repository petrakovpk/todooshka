//
//  ProfileViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.01.2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture

class UserProfileViewController: TDViewController {
  public var viewModel: UserProfileViewModel!
  public var viewControllers: [UIViewController] = []
  
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Elements
  private let pleaseAuthContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = Style.App.background
    view.layer.zPosition = 10
    return view
  }()
  
  private let authButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Войти в систему", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.cornerRadius = 8
    button.backgroundColor = Palette.SingleColors.Cerise
    return button
  }()
  
  private let avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 15
    imageView.layer.masksToBounds = true
    imageView.backgroundColor = .black.withAlphaComponent(0.2)
    return imageView
  }()
  
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "Robert"
    label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
    label.textAlignment = .center
    return label
  }()
  
  private var subscriptionStackView: UIStackView!
  
  private let subscriptionValueLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = "0"
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return label
  }()
  
  private let subscriptionNameLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = "Подписки"
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  private var followersStackView: UIStackView!
  
  private let followersValueLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = "0"
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return label
  }()
  
  private let followersNameLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = "Подписчики"
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  private let publicationsView: UIView = {
    let view = UIView()
    
    return view
  }()
  
  private let publicationsValueLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = "0"
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return label
  }()
  
  private let publicationsNameLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = "Публикации"
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  private let subscribeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Подписаться", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.cornerRadius = 4
    button.borderWidth = 1.0
    button.borderColor = Style.App.text
    return button
  }()
  
  private let topDividerView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.2)
    return view
  }()
  
  private let publicationListButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Публикации", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    return button
  }()
  
  private let taskListButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Задачи", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    return button
  }()
  
  private let bottomDividerView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.2)
    return view
  }()
  
  private var pageViewController: UIPageViewController!
  
  // MARK: - Lifecycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.tabBarController?.tabBar.isHidden = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configurePageViewController()
    bindViewModel()
    
    for viewController in viewControllers {
      if let viewController = viewController as? UserProfileTaskListViewContoller {
        viewController.configureUI()
        viewController.configureDataSource()
        viewController.bindViewModel()
      }
      
      if let viewController = viewController as? UserProfilePublicationsViewController {
        viewController.configureUI()
        viewController.configureDataSource()
        viewController.bindViewModel()
      }
    }
  }

  // MARK: - Configure UI
  func configureUI() {
    subscriptionStackView = UIStackView(arrangedSubviews: [subscriptionValueLabel, subscriptionNameLabel])
    subscriptionStackView.axis = .vertical
    subscriptionStackView.distribution = .fillEqually
    
    followersStackView = UIStackView(arrangedSubviews: [followersValueLabel, followersNameLabel])
    followersStackView.axis = .vertical
    followersStackView.distribution = .fillEqually
    
    let publicationsStackView = UIStackView(arrangedSubviews: [publicationsValueLabel, publicationsNameLabel])
    publicationsStackView.axis = .vertical
    publicationsStackView.distribution = .fillEqually

    let statStackView = UIStackView(arrangedSubviews: [subscriptionStackView, followersStackView, publicationsStackView])
    statStackView.axis = .horizontal
    statStackView.distribution = .fillEqually
    
    let buttonStackView = UIStackView(arrangedSubviews: [publicationListButton, taskListButton])
    buttonStackView.axis = .horizontal
    buttonStackView.distribution = .fillEqually
    
    pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    pageViewController.delegate = self
    pageViewController.dataSource = self
    
    settingsButton.isHidden = false
    
    addChild(pageViewController)
    
    view.addSubviews([
      avatarImageView,
      nameLabel,
      statStackView,
      subscribeButton,
      topDividerView,
      buttonStackView,
      bottomDividerView,
      pageViewController.view,
      pleaseAuthContainerView
    ])
    
    pleaseAuthContainerView.addSubviews([
      authButton
    ])
    
    pleaseAuthContainerView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor
    )
    
    authButton.anchorCenterXToSuperview()
    authButton.anchorCenterYToSuperview()
    authButton.anchor(
      widthConstant: 200,
      heightConstant: 40
    )

    avatarImageView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 100,
      heightConstant: 100
    )
    
    subscribeButton.anchor(
      left: avatarImageView.rightAnchor,
      bottom: avatarImageView.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 30
    )
    
    statStackView.anchor(
      top: avatarImageView.topAnchor,
      left: avatarImageView.rightAnchor,
      bottom: subscribeButton.topAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 8,
      rightConstant: 16
    )
  
    topDividerView.anchor(
      top: avatarImageView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      heightConstant: 0.5
    )
    
    buttonStackView.anchor(
      top: topDividerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      heightConstant: 30
    )
    
    bottomDividerView.anchor(
      top: buttonStackView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      heightConstant: 0.5
    )
    
    pageViewController.view.anchor(
      top: bottomDividerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor
    )

  }
  
  func configurePageViewController() {
    if let firstVC = viewControllers.first {
      self.pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
     }
  }
  
  // MARK: - Setup Collection View
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }

  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(62))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 5, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 0, trailing: 0)
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)
    section.boundarySupplementaryItems = [header]
    return section
  }
  

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = UserProfileViewModel.Input(
      // header
      settingsButtonClickTrigger: settingsButton.rx.tap.asDriver(),
      // auth
      authButtonClickTrigger: authButton.rx.tap.asDriver(),
      // avatar
      avatarImageViewClickTrigger: avatarImageView.rx.tapGesture().when(.recognized).mapToVoid().asDriver(onErrorJustReturn: ()),
      // subscription
      subscribeButtonClickTrigger: subscribeButton.rx.tap.asDriver(),
      // subscriptions and followers
      subscriptionsLabelClickTrigger: subscriptionStackView.rx.tapGesture().when(.recognized).mapToVoid().asDriver(onErrorJustReturn: ()),
      followersLabelClickTrigger: followersStackView.rx.tapGesture().when(.recognized).mapToVoid().asDriver(onErrorJustReturn: ()),
      // publications and tasks
      publicationListButtonClickTrigger: publicationListButton.rx.tap.asDriver(),
      taskListButtonClickTrigger: taskListButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      // header
      outputs.titleText.drive(titleLabel.rx.text),
      outputs.openSettings.drive(),
      // pleaseAuthContainerViewIsHidden
      outputs.pleaseAuthContainerViewIsHidden.drive(pleaseAuthContainerView.rx.isHidden),
      // avatar
      outputs.extUserDataImage.drive(avatarImageView.rx.image),
      outputs.openAvatar.drive(),
      // auth
      outputs.auth.drive(),
      //
      outputs.openFollowers.drive(),
      outputs.openSubscriptions.drive(),
      // pageViewController
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
  }
  
}

extension UserProfileViewController: UIPageViewControllerDataSource {
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

extension UserProfileViewController: UIPageViewControllerDelegate {
  
}

