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
  
  private let skipButton = UIButton(type: .system)
  
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
    skipButton.cornerRadius = 25
    skipButton.backgroundColor = Palette.SingleColors.BlueRibbon
    skipButton.setTitleColor(.white, for: .normal)
    skipButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor , right: view.rightAnchor, leftConstant: 16, bottomConstant: (26 + 50).adjusted, rightConstant: 16, heightConstant: 50.adjusted)
    
    // collectionView
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundColor = .clear
    collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: OnboardingCollectionViewCell.reuseID)
    collectionView.anchor(left: view.leftAnchor, bottom: skipButton.topAnchor, right: view.rightAnchor, topConstant: 0, bottomConstant: 0, heightConstant: UIScreen.main.bounds.height * 0.57)
    
    // headerLabel
    headerLabel.textColor = Theme.App.text
    headerLabel.anchor(bottom: collectionView.topAnchor, bottomConstant: 80.adjusted)
    headerLabel.anchorCenterXToSuperview()
    
    // centralDot
    centralDot.cornerRadius = 3
    centralDot.backgroundColor = Theme.Onboarding.dotBackground
    centralDot.anchorCenterXToSuperview()
    centralDot.anchor(bottom: skipButton.topAnchor, bottomConstant: 74.adjusted , widthConstant: 6, heightConstant: 6)
    
    // leftDot
    leftDot.cornerRadius = 3
    leftDot.backgroundColor = Palette.SingleColors.BlueRibbon
    leftDot.removeAllConstraints()
    leftDot.anchor(top: centralDot.topAnchor, right: centralDot.leftAnchor, rightConstant: 10.0, widthConstant: 25, heightConstant: 6)
    
    // rightDot
    rightDot.cornerRadius = 3
    rightDot.backgroundColor = Theme.Onboarding.dotBackground
    rightDot.removeAllConstraints()
    rightDot.anchor(top: centralDot.topAnchor, left: centralDot.rightAnchor, leftConstant: 10.0, widthConstant: 6, heightConstant: 6)
    
  }
  
  func setDotWidth(leftDotPercent: Int, centralDotPercent: Int, rightDotPercent: Int) {
    
    // centralDot
    centralDot.removeAllConstraints()
    centralDot.anchorCenterXToSuperview()
    centralDot.anchor(bottom: skipButton.topAnchor, bottomConstant: 74.adjusted , widthConstant: CGFloat(6 + 19 * centralDotPercent / 100).adjusted, heightConstant: 6)
    centralDotPercent == 0 ? (leftDot.backgroundColor = Theme.Onboarding.dotBackground) : (centralDot.backgroundColor = Palette.SingleColors.BlueRibbon)
    
    // leftDot
    leftDot.removeAllConstraints()
    leftDot.anchor(top: centralDot.topAnchor, right: centralDot.leftAnchor, rightConstant: 10.0, widthConstant: CGFloat(6 + 19 * leftDotPercent / 100).adjusted, heightConstant: 6)
    leftDotPercent == 0 ? (centralDot.backgroundColor = Theme.Onboarding.dotBackground) : (leftDot.backgroundColor = Palette.SingleColors.BlueRibbon)
    
    // rightDot
    rightDot.removeAllConstraints()
    rightDot.anchor(top: centralDot.topAnchor, left: centralDot.rightAnchor, leftConstant: 10.0, widthConstant: CGFloat(6 + 19 * rightDotPercent / 100).adjusted, heightConstant: 6)
    rightDotPercent == 0 ? (rightDot.backgroundColor = Theme.Onboarding.dotBackground) : (rightDot.backgroundColor = Palette.SingleColors.BlueRibbon)
    
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
    
    let cellScrolled = collectionView.rx.didScroll.map { _ -> Int in
      var leftDotPercent = 0
      var centralDotPercent = 0
      var rightDotPercent = 0
      
      let cells = self.collectionView.visibleCells
      for cell in cells {
        let f = cell.frame
        guard let w = self.view.window else { return 0 }
        let rect = w.convert(f, from: cell.superview!)
        let inter = rect.intersection(w.bounds)
        let ratio = (inter.width * inter.height) / (f.width * f.height)
        if let indexPath = self.collectionView.indexPath(for: cell) {
          if indexPath.section == 0 { leftDotPercent = Int(ratio * 100) }
          if indexPath.section == 1 { centralDotPercent = Int(ratio * 100) }
          if indexPath.section == 2 { rightDotPercent = Int(ratio * 100) }
        }
      }
      
      self.setDotWidth(leftDotPercent: leftDotPercent, centralDotPercent: centralDotPercent, rightDotPercent: rightDotPercent)
      
      let array = [leftDotPercent, centralDotPercent, rightDotPercent]
      return array.firstIndex(of: array.max() ?? 0) ?? 0
    }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: 0)
      .startWith(0)
    
    let input = OnboardingViewModel.Input (
      skipButtonClickTrigger: skipButton.rx.tap.asDriver(),
      cellScrolled: cellScrolled
    )
    
    let output = viewModel.transform(input: input)
    output.dataSource.drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    output.skipButtonClick.drive(skipButtonClickBinder).disposed(by: disposeBag)
    output.skipButtonTitle.drive(skipButtonTitleBinder).disposed(by: disposeBag)
    output.cellScrolled.drive().disposed(by: disposeBag)
    output.backgroundImage.drive(backgroundImageViewBinder).disposed(by: disposeBag)
  }
  
  var skipButtonClickBinder: Binder<Int?> {
    return Binder(self, binding: { (vc, section) in
      guard let section = section else { return }
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
  
  var backgroundImageViewBinder: Binder<UIImage?> {
    return Binder(self, binding: { (vc, image) in
      UIView.transition(with:  vc.backgroundImageView,
                        duration: 0.4,
                        options: .transitionCrossDissolve,
                        animations: {
        self.backgroundImageView.image = image
      }, completion: nil)
    })
  }
}


