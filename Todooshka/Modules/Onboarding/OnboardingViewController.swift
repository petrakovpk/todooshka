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
  private let firstDot = UIView()
  private let secondDot = UIView()
  private let thirdDot = UIView()
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
    configureColor()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    
    view.addSubview(backgroundImageView)
    backgroundImageView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
    
    view.addSubview(skipButton)
    skipButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor , right: view.rightAnchor, leftConstant: 16, bottomConstant: (26 + 50).adjusted, rightConstant: 16, heightConstant: 50.adjusted)
    skipButton.cornerRadius = 25
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
    collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: OnboardingCollectionViewCell.reuseID)
    
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isPagingEnabled = true
    
    view.addSubview(collectionView)
    collectionView.anchor(left: view.leftAnchor, bottom: skipButton.topAnchor, right: view.rightAnchor, topConstant: 0, bottomConstant: 0, heightConstant: UIScreen.main.bounds.height * 0.57)
    
    view.addSubview(headerLabel)
    headerLabel.anchor(bottom: collectionView.topAnchor, bottomConstant: 80.adjusted)
    headerLabel.anchorCenterXToSuperview()
    
    firstDot.cornerRadius = 3
    secondDot.cornerRadius = 3
    thirdDot.cornerRadius = 3
    
    firstDot.backgroundColor = .blueRibbon
    secondDot.backgroundColor = UIColor(named: "onboardingDotBackground")
    thirdDot.backgroundColor = UIColor(named: "onboardingDotBackground")
    
    view.addSubview(firstDot)
    view.addSubview(secondDot)
    view.addSubview(thirdDot)
    
    secondDot.anchor(bottom: skipButton.topAnchor, bottomConstant: 74.adjusted , widthConstant: 6, heightConstant: 6)
    secondDot.anchorCenterXToSuperview()
    
    firstDot.removeAllConstraints()
    firstDot.anchor(top: secondDot.topAnchor, right: secondDot.leftAnchor, rightConstant: 10.0, widthConstant: 25, heightConstant: 6)
    
    thirdDot.removeAllConstraints()
    thirdDot.anchor(top: secondDot.topAnchor, left: secondDot.rightAnchor, leftConstant: 10.0, widthConstant: 6, heightConstant: 6)
    
  }
  
  func setDotWidth(firstDotPercent: Int, secondDotPercent: Int, thirdDotPercent: Int) {
    secondDot.removeAllConstraints()
    secondDot.anchor(bottom: skipButton.topAnchor, bottomConstant: 74.adjusted , widthConstant: CGFloat(6 + 19 * secondDotPercent / 100).adjusted, heightConstant: 6)
    secondDot.anchorCenterXToSuperview()
    
    firstDot.removeAllConstraints()
    firstDot.anchor(top: secondDot.topAnchor, right: secondDot.leftAnchor, rightConstant: 10.0, widthConstant: CGFloat(6 + 19 * firstDotPercent / 100).adjusted, heightConstant: 6)
    
    thirdDot.removeAllConstraints()
    thirdDot.anchor(top: secondDot.topAnchor, left: secondDot.rightAnchor, leftConstant: 10.0, widthConstant: CGFloat(6 + 19 * thirdDotPercent / 100).adjusted, heightConstant: 6)
    
    if firstDotPercent == 0 { firstDot.backgroundColor = UIColor(named: "onboardingDotBackground") } else { firstDot.backgroundColor = .blueRibbon }
    if secondDotPercent == 0 { secondDot.backgroundColor = UIColor(named: "onboardingDotBackground") } else { secondDot.backgroundColor = .blueRibbon }
    if thirdDotPercent == 0 { thirdDot.backgroundColor = UIColor(named: "onboardingDotBackground") } else { thirdDot.backgroundColor = .blueRibbon }
    
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
      var firstDotPercent = 0
      var secondDotPercent = 0
      var thirdDotPercent = 0
      
      let cells = self.collectionView.visibleCells
      for cell in cells {
        let f = cell.frame
        guard let w = self.view.window else { return 0 }
        let rect = w.convert(f, from: cell.superview!)
        let inter = rect.intersection(w.bounds)
        let ratio = (inter.width * inter.height) / (f.width * f.height)
        if let indexPath = self.collectionView.indexPath(for: cell) {
          if indexPath.section == 0 { firstDotPercent = Int(ratio * 100) }
          if indexPath.section == 1 { secondDotPercent = Int(ratio * 100) }
          if indexPath.section == 2 { thirdDotPercent = Int(ratio * 100) }
        }
      }
      
      self.setDotWidth(firstDotPercent: firstDotPercent, secondDotPercent: secondDotPercent, thirdDotPercent: thirdDotPercent)
      
      let array = [firstDotPercent, secondDotPercent, thirdDotPercent]
      return array.firstIndex(of: array.max() ?? 0) ?? 0 }
    
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

//MARK: - Colors and Texts
extension OnboardingViewController: ConfigureColorProtocol {
  func configureColor() {
    
    view.backgroundColor = UIColor(named: "appBackground")
    
    collectionView.backgroundColor = .clear
    
    headerLabel.textColor = UIColor(named: "appText")
    
    authButton.backgroundColor = .blueRibbon
    authButton.setTitleColor(.white, for: .normal)
    
    skipButton.backgroundColor = .blueRibbon
    skipButton.setTitleColor(.white, for: .normal)
  }
  
}
