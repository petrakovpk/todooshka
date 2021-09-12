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
  private var viewModel: OnboardingViewModel!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<OnboardingSectionModel>!
  private var selectedOnboardingScreen = BehaviorRelay<SelectedOnboardingScreen>(value: .first)
  
  //MARK: - Constants
  static let collectionViewHeight = CGFloat(575.0)
  
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
  
  private let skipButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Пропустить", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  private let authButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Войти в аккаунт / Зарегестрироваться", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
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
    layout.itemSize = CGSize(width: UIScreen.main.bounds.width , height: OnboardingViewController.collectionViewHeight)
    return layout
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    configureColor()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    
    view.addSubview(backgroundImageView)
    backgroundImageView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
    
    view.addSubview(headerLabel)
    headerLabel.anchor(top: view.topAnchor, topConstant: 84)
    headerLabel.anchorCenterXToSuperview()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
    collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: OnboardingCollectionViewCell.reuseID)
    
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isPagingEnabled = true
    
    view.addSubview(collectionView)
    collectionView.anchor(top: headerLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 76, heightConstant: OnboardingViewController.collectionViewHeight)
    
    firstDot.cornerRadius = 3
    secondDot.cornerRadius = 3
    thirdDot.cornerRadius = 3
    
    firstDot.backgroundColor = .blueRibbon
    secondDot.backgroundColor = UIColor(named: "onboardingDotBackground")
    thirdDot.backgroundColor = UIColor(named: "onboardingDotBackground")
    
    view.addSubview(firstDot)
    view.addSubview(secondDot)
    view.addSubview(thirdDot)
    
    view.addSubview(skipButton)
    skipButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, bottomConstant: 16)
    skipButton.anchorCenterXToSuperview()
    
    view.addSubview(authButton)
    authButton.anchor(left: view.leftAnchor, bottom: skipButton.topAnchor, right: view.rightAnchor, leftConstant: 16, bottomConstant: 26, rightConstant: 16, heightConstant: 50)
    
    authButton.cornerRadius = 25
    
    secondDot.anchor(bottom: authButton.topAnchor, bottomConstant: 74, widthConstant: 6, heightConstant: 6)
    secondDot.anchorCenterXToSuperview()
    
    firstDot.removeAllConstraints()
    firstDot.anchor(top: secondDot.topAnchor, right: secondDot.leftAnchor, rightConstant: 10.0, widthConstant: 25, heightConstant: 6)
    
    thirdDot.removeAllConstraints()
    thirdDot.anchor(top: secondDot.topAnchor, left: secondDot.rightAnchor, leftConstant: 10.0, widthConstant: 6, heightConstant: 6)
    
  }
  
  func setDotWidth(firstDotPercent: Int, secondDotPercent: Int, thirdDotPercent: Int) {
    
    secondDot.removeAllConstraints()
    secondDot.anchor(bottom: authButton.topAnchor, bottomConstant: 74, widthConstant: CGFloat(6 + 19 * secondDotPercent / 100), heightConstant: 6)
    secondDot.anchorCenterXToSuperview()
    
    firstDot.removeAllConstraints()
    firstDot.anchor(top: secondDot.topAnchor, right: secondDot.leftAnchor, rightConstant: 10.0, widthConstant: CGFloat(6 + 19 * firstDotPercent / 100), heightConstant: 6)
    
    thirdDot.removeAllConstraints()
    thirdDot.anchor(top: secondDot.topAnchor, left: secondDot.rightAnchor, leftConstant: 10.0, widthConstant: CGFloat(6 + 19 * thirdDotPercent / 100), heightConstant: 6)
    
    if firstDotPercent == 0 { firstDot.backgroundColor = UIColor(named: "onboardingDotBackground") } else { firstDot.backgroundColor = .blueRibbon }
    if secondDotPercent == 0 { secondDot.backgroundColor = UIColor(named: "onboardingDotBackground") } else { secondDot.backgroundColor = .blueRibbon }
    if thirdDotPercent == 0 { thirdDot.backgroundColor = UIColor(named: "onboardingDotBackground") } else { thirdDot.backgroundColor = .blueRibbon }
    
    guard let title = skipButton.titleLabel?.text else { return }
    
    if firstDotPercent == 100  {
      selectedOnboardingScreen.value == .first ? nil : selectedOnboardingScreen.accept(.first)
    }
    
    if  secondDotPercent == 100 {
      selectedOnboardingScreen.value == .second ? nil : selectedOnboardingScreen.accept(.second)
    }
    
    if thirdDotPercent == 100 {
      selectedOnboardingScreen.value == .third ? nil : selectedOnboardingScreen.accept(.third)
    }
   
    
    self.view.layoutIfNeeded()
  }
  
  //MARK: - Setup CollectionView
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<OnboardingSectionModel>(
      configureCell: { (_, collectionView, indexPath, onboardingSectionItem) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.reuseID, for: indexPath) as! OnboardingCollectionViewCell
        let cellViewModel = OnboardingCollectionViewCellModel(services: self.viewModel.services, onboardingSectionItem: onboardingSectionItem)
        cell.bindToViewModel(viewModel: cellViewModel)
        return cell
      })
    
    viewModel.dataSource.asDriver()
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.didScroll.bind{ [weak self]  _ in
      guard let self = self else { return }
      let cells = self.collectionView.visibleCells
      
      var firstDotPercent = 0
      var secondDotPercent = 0
      var thirdDotPercent = 0
      
      for cell in cells {
        let f = cell.frame
        let w = self.view.window!
        let rect = w.convert(f, from: cell.superview!)
        let inter = rect.intersection(w.bounds)
        let ratio = (inter.width * inter.height) / (f.width * f.height)
        
        if let indexPath = self.collectionView.indexPath(for: cell) {
          switch indexPath.section {
          case 0:
            firstDotPercent = Int(ratio * 100)
            
          case 1:
            secondDotPercent = Int(ratio * 100)
            
          case 2:
            thirdDotPercent = Int(ratio * 100)
            
          default:
            return
          }
        }
      }
      
      self.setDotWidth(firstDotPercent: firstDotPercent, secondDotPercent: secondDotPercent, thirdDotPercent: thirdDotPercent)
      
    }.disposed(by: disposeBag)
    
  }
  
  //MARK: - Bind To
  func bindTo(with viewModel: OnboardingViewModel) {
    self.viewModel = viewModel
    
    skipButton.rx.tap.bind{ [weak self] _ in
      guard let self = self else { return }
      guard let title = self.skipButton.titleLabel?.text else { return }
      
      if title == "Пропустить" {
        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 2), at: .right, animated: true)
      }
      
      if title == "Начать" {
        self.viewModel.skipButtonClick()
      }
    }.disposed(by: disposeBag)
    
    authButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.authButtonClick() }.disposed(by: disposeBag)
    
    viewModel.authButtonIsHidden.bind(to: authButton.rx.isHidden).disposed(by: disposeBag)
    
    selectedOnboardingScreen.throttle(.seconds(1), scheduler: MainScheduler.instance).bind{ [weak self] selectedScreen in
      guard let self = self else { return }
      switch selectedScreen {
      case .first:
        UIView.transition(with:  self.backgroundImageView,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.backgroundImageView.image = UIImage(named: "Onboarding1Background")
                          }, completion: nil)
        
        let attrString = NSAttributedString(string: "Пропустить", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        self.skipButton.setAttributedTitle(attrString, for: .normal)
        self.skipButton.setTitleColor(.santasGray, for: .normal)
      case .second:
        UIView.transition(with:  self.backgroundImageView,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.backgroundImageView.image = UIImage(named: "Onboarding2Background")
                          }, completion: nil)
        
        let attrString = NSAttributedString(string: "Пропустить", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        self.skipButton.setAttributedTitle(attrString, for: .normal)
        self.skipButton.setTitleColor(.santasGray, for: .normal)
      case .third:
        UIView.transition(with:  self.backgroundImageView,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.backgroundImageView.image = UIImage(named: "Onboarding3Background")
                          }, completion: nil)
        
          let attrString = NSAttributedString(string: "Начать", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        self.skipButton.setAttributedTitle(attrString, for: .normal)
        self.skipButton.setTitleColor(.burntSienna, for: .normal)
      }
    }.disposed(by: disposeBag)
    
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
    
    skipButton.backgroundColor = .clear
    skipButton.setTitleColor(.santasGray, for: .normal)
  }
  
  
}
