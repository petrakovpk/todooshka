//
//  OnboardingViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.08.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum SelectedOnboardingScreen {
  case first, second, third
}

final class OnboardingViewController: UIViewController {
  
  //MARK: - Properties
  private let disposeBag = DisposeBag()
  var viewModel: OnboardingViewModel!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<OnboardingSectionModel>!
  
  //MARK: - UI Elements
  private let leftDot = UIView()
  private let centralDot = UIView()
  private let rightDot = UIView()
  
  private let headerLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    label.text = "TODOOSHKA"
    return label
  }()
  
  private let skipButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 25
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let authButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Войти в аккаунт / Зарегестрироваться", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    button.isHidden = true
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let backgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "Onboarding1Background")
    imageView.backgroundColor = .clear
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  private var collectionView: UICollectionView!
  private let collectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height * 0.57)
    return layout
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    
    // def
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
    
    // adding
    view.addSubview(backgroundImageView)
    view.addSubview(skipButton)
    view.addSubview(collectionView)
    view.addSubview(headerLabel)
    view.addSubview(leftDot)
    view.addSubview(centralDot)
    view.addSubview(rightDot)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // backgroundImageView
    backgroundImageView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
    
    // skipButton
    skipButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: Sizes.Buttons.skipButton.width,
      rightConstant: 16,
      heightConstant: Sizes.Buttons.appButton.height
    )
    
    // collectionView
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundColor = .clear
    collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: OnboardingCollectionViewCell.reuseID)
    collectionView.anchor(left: view.leftAnchor, bottom: skipButton.topAnchor, right: view.rightAnchor, topConstant: 0, bottomConstant: 0, heightConstant: UIScreen.main.bounds.height * 0.57)
    
    // headerLabel
    headerLabel.textColor = Theme.App.text
    headerLabel.anchor(bottom: collectionView.topAnchor, bottomConstant: Sizes.Labels.onboardingHeaderLabel.bottomConstant)
    headerLabel.anchorCenterXToSuperview()
    
    // centralDot
    centralDot.cornerRadius = 3
    centralDot.backgroundColor = Theme.Onboarding.Dot
    centralDot.anchorCenterXToSuperview()
    centralDot.anchor(bottom: skipButton.topAnchor, bottomConstant: Sizes.Views.Dot.bottomConstant , widthConstant: 6, heightConstant: 6)
    
    // leftDot
    leftDot.cornerRadius = 3
    leftDot.backgroundColor = Palette.SingleColors.BlueRibbon
    leftDot.removeAllConstraints()
    leftDot.anchor(top: centralDot.topAnchor, right: centralDot.leftAnchor, rightConstant: 10.0, widthConstant: 25, heightConstant: 6)
    
    // rightDot
    rightDot.cornerRadius = 3
    rightDot.backgroundColor = Theme.Onboarding.Dot
    rightDot.removeAllConstraints()
    rightDot.anchor(top: centralDot.topAnchor, left: centralDot.rightAnchor, leftConstant: 10.0, widthConstant: 6, heightConstant: 6)
    
  }
  
  func setDotWidth(leftDotPercent: Int, centralDotPercent: Int, rightDotPercent: Int) {
    
    // centralDot
    centralDot.removeAllConstraints()
    centralDot.anchorCenterXToSuperview()
    centralDot.anchor(
      bottom: skipButton.topAnchor,
      bottomConstant: Sizes.Views.Dot.bottomConstant,
      widthConstant: CGFloat(6 + 19 * centralDotPercent / 100).adjustByWidth,
      heightConstant: 6
    )
    
    centralDotPercent == 0 ? (centralDot.backgroundColor = Theme.Onboarding.Dot) : (centralDot.backgroundColor = Palette.SingleColors.BlueRibbon)
    
    // leftDot
    leftDot.removeAllConstraints()
    leftDot.anchor(
      top: centralDot.topAnchor,
      right: centralDot.leftAnchor,
      rightConstant: 10.0,
      widthConstant: CGFloat(6 + 19 * leftDotPercent / 100).adjustByWidth,
      heightConstant: 6
    )
    leftDotPercent == 0 ? (leftDot.backgroundColor = Theme.Onboarding.Dot) : (leftDot.backgroundColor = Palette.SingleColors.BlueRibbon)
    
    // rightDot
    rightDot.removeAllConstraints()
    rightDot.anchor(
      top: centralDot.topAnchor,
      left: centralDot.rightAnchor,
      leftConstant: 10.0,
      widthConstant: CGFloat(6 + 19 * rightDotPercent / 100).adjustByWidth,
      heightConstant: 6
    )
    rightDotPercent == 0 ? (rightDot.backgroundColor = Theme.Onboarding.Dot) : (rightDot.backgroundColor = Palette.SingleColors.BlueRibbon)
    
    self.view.layoutIfNeeded()
  }
  
  //MARK: - Setup CollectionView
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<OnboardingSectionModel>(
      configureCell: { (_, collectionView, indexPath, onboardingSectionItem) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.reuseID, for: indexPath) as! OnboardingCollectionViewCell
        let cellViewModel = OnboardingCollectionViewCellModel(services: self.viewModel.services, onboardingSectionItem: onboardingSectionItem)
        cell.viewModel = cellViewModel
        return cell
      })
  }
  
  //MARK: - Bind To
  func bindViewModel() {

    let input = OnboardingViewModel.Input (
      didScroll: collectionView.rx.didScroll.asDriver(),
      skipButtonClickTrigger: skipButton.rx.tap.asDriver(),
      willDisplayCell: collectionView.rx.willDisplayCell.asDriver()
    )
    
    let output = viewModel.transform(input: input)
    
    [
      output.backgroundImage.drive(backgroundImageBinder),
      output.completeOnboarding.drive(),
      output.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      output.reloadPoints.drive(reloadPointsBinder),
      output.scrollToSection.drive(scrollToSectionBinder),
      output.skipButtonTitle.drive(skipButtonTitleBinder),
    ]
      .forEach({ $0.disposed(by: disposeBag) })

  }
  
  var backgroundImageBinder: Binder<UIImage?> {
    return Binder(self, binding: { (vc, image) in
      UIView.transition(
        with:  vc.backgroundImageView,
        duration: 0.4,
        options: .transitionCrossDissolve,
        animations: {
          self.backgroundImageView.image = image
        }, completion: nil)
    })
  }
  
  var reloadPointsBinder: Binder<Void> {
    return Binder(self, binding: { (vc, section) in
      var leftDotPercent = 0
      var centralDotPercent = 0
      var rightDotPercent = 0
      for cell in vc.collectionView.visibleCells {
        let f = cell.frame
        guard let w = self.view.window else { return }
        let rect = w.convert(f, from: cell.superview!)
        let inter = rect.intersection(w.bounds)
        let ratio = (inter.width * inter.height) / (f.width * f.height)
        if let indexPath = self.collectionView.indexPath(for: cell) {
          switch indexPath.section {
          case 0: leftDotPercent = Int(ratio * 100)
          case 1: centralDotPercent = Int(ratio * 100)
          case 2: rightDotPercent = Int(ratio * 100)
          default: return
          }
        }
      }
      self.setDotWidth(leftDotPercent: leftDotPercent, centralDotPercent: centralDotPercent, rightDotPercent: rightDotPercent)
    })
  }
  
  var scrollToSectionBinder: Binder<Int> {
    return Binder(self, binding: { (vc, section) in
      vc.collectionView.isPagingEnabled = false
      vc.collectionView.scrollToItem(at: IndexPath(item: 0, section: section), at: .right, animated: true)
      vc.collectionView.isPagingEnabled = true
    })
  }
  
  var skipButtonTitleBinder: Binder<String> {
    return Binder(self, binding: { (vc, title) in
      UIView.performWithoutAnimation {
        let attrString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        vc.skipButton.setAttributedTitle(attrString, for: .normal)
        vc.skipButton.layoutIfNeeded()
      }
    })
  }
  

}


