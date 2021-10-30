//
//  UserProfileViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class UserProfileViewController: UIViewController {
  
  //MARK: - Properties
  var collectionView: UICollectionView!
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<UserProfileSectionModel>!
  var viewModel: UserProfileViewModel!
  
  let disposeBag = DisposeBag()
  
  //MARK: - UI Elements
  let helloLabel = UILabel()
  let typeLabel1 = UILabel()
  let typeLabel2 = UILabel()
  let typeLabel3 = UILabel()
  let typeLabel4 = UILabel()
  let monthLabel = UILabel()
  let completedTasksLabel = UILabel()
  
  let settingsButton =  TDTopRoundButton(type: .system) 
  let previousMonthButton = UIButton(type: .custom)
  let nextMonthButton = UIButton(type: .custom)
 
  let wreathImageView: UIImageView = {
    let imageView = UIImageView()
    let image = UIImage(named: "wreath")
    imageView.image = image
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  let dayStatusBackgroundView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 53.superAdjusted / 2
    view.backgroundColor = UIColor(red: 0, green: 0.34, blue: 1, alpha: 1)
    return view
  }()
  
  let dayStatusLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.textColor = .white
    return label
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureUI()
    configureDataSource()
    bindViewModel()
    configureColor()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.tabBarController?.tabBar.isHidden = false
  }
    
  //MARK: - Configure UI
  func configureUI() {
    view.addSubview(settingsButton)
    settingsButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, topConstant: 8, rightConstant: 16, widthConstant: 50.adjusted, heightConstant: 50.adjusted)
    
    helloLabel.text = "Добро пожаловать!"
    helloLabel.font = UIFont.systemFont(ofSize: 19.superAdjusted, weight: .medium)
    
    view.addSubview(helloLabel)
    helloLabel.anchor( left: view.leftAnchor,  right: settingsButton.leftAnchor, leftConstant: 16, rightConstant: 16)
    helloLabel.centerYAnchor.constraint(equalTo: settingsButton.centerYAnchor).isActive = true
    
    view.addSubview(wreathImageView)
    wreathImageView.anchor(top: settingsButton.bottomAnchor, topConstant: 20.superAdjusted, heightConstant: 119.superAdjusted)
    wreathImageView.anchorCenterXToSuperview()
    
    completedTasksLabel.font = UIFont.systemFont(ofSize: 35, weight: .medium)
    
    wreathImageView.addSubview(completedTasksLabel)
    completedTasksLabel.anchorCenterXToSuperview()
    completedTasksLabel.anchor(bottom: wreathImageView.bottomAnchor, bottomConstant: (119 / 2).superAdjusted)
    
    let label = UILabel()
    label.text = "Задач"
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    
    wreathImageView.addSubview(label)
    label.anchorCenterXToSuperview()
    label.anchor(top: completedTasksLabel.bottomAnchor, topConstant: 2)
    
    typeLabel1.textAlignment = .center
    typeLabel2.textAlignment = .center
    typeLabel3.textAlignment = .center
    typeLabel4.textAlignment = .center
    
    typeLabel1.textColor = UIColor(red: 0.286, green: 0.302, blue: 0.502, alpha: 1)
    typeLabel2.textColor = UIColor(red: 0.286, green: 0.302, blue: 0.502, alpha: 1)
    typeLabel3.textColor = UIColor(red: 0.286, green: 0.302, blue: 0.502, alpha: 1)
    typeLabel4.textColor = UIColor(red: 0.286, green: 0.302, blue: 0.502, alpha: 1)
    
    typeLabel1.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    typeLabel2.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    typeLabel3.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    typeLabel4.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    
    let roundImage = UIImage(named: "point")?.original
    
    let roundImageView = UIImageView(image: roundImage)
    let roundImageView1 = UIImageView(image: roundImage)
    let roundImageView2 = UIImageView(image: roundImage)
    
    roundImageView.backgroundColor = UIColor.clear
    roundImageView1.backgroundColor = UIColor.clear
    roundImageView2.backgroundColor = UIColor.clear
    
    roundImageView.contentMode = .center
    roundImageView1.contentMode = .center
    roundImageView2.contentMode = .center
    
    let stackView = UIStackView(arrangedSubviews: [typeLabel1, roundImageView, typeLabel2, roundImageView1, typeLabel3, roundImageView2, typeLabel4])
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    
    view.addSubview(stackView)
    stackView.anchor(top: wreathImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 19.superAdjusted, leftConstant: 32, rightConstant: 32,  heightConstant: 15.superAdjusted)
  
    view.addSubview(dayStatusBackgroundView)
    dayStatusBackgroundView.anchorCenterXToSuperview()
    dayStatusBackgroundView.anchor(top: typeLabel1.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 30.superAdjusted, leftConstant: 16, rightConstant: 16,  heightConstant: 53.superAdjusted)
    
    dayStatusBackgroundView.addSubview(dayStatusLabel)
    dayStatusLabel.anchorCenterXToSuperview()
    dayStatusLabel.anchorCenterYToSuperview()
    
    let calendarView = UIView()
    calendarView.backgroundColor = UIColor(named: "userProfileCalendarBackground")
    calendarView.cornerRadius = 11
    
    view.addSubview(calendarView)
    calendarView.anchor(top: dayStatusBackgroundView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 30.superAdjusted, leftConstant: 16, bottomConstant: 32.superAdjusted, rightConstant: 16)
    
    monthLabel.textAlignment = .center
    monthLabel.textColor = UIColor(named: "appText")
    monthLabel.font = UIFont.systemFont(ofSize: 17.superAdjusted, weight: .semibold)
    
    calendarView.addSubview(monthLabel)
    monthLabel.anchorCenterXToSuperview()
    monthLabel.anchor(top: calendarView.topAnchor, topConstant: 20.superAdjusted)
    
    let dividerView = UIView()
    dividerView.backgroundColor = UIColor(named: "userProfileCalendarDividerBackground")
    
    calendarView.addSubview(dividerView)
    dividerView.anchor(top: monthLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 20.superAdjusted, heightConstant: 1.0)
    
    previousMonthButton.setImage(UIImage(named: "arrow-left-custom")?.template, for: .normal)
    previousMonthButton.imageView?.tintColor = UIColor(named: "userProfileCalendarArrow")
    
    calendarView.addSubview(previousMonthButton)
    previousMonthButton.anchor(top: calendarView.topAnchor, left: calendarView.leftAnchor, bottom: dividerView.topAnchor, right: monthLabel.leftAnchor)
    
    nextMonthButton.setImage(UIImage(named: "arrow-right-custom")?.template, for: .normal)
    nextMonthButton.imageView?.tintColor = UIColor(named: "userProfileCalendarArrow")
    
    calendarView.addSubview(nextMonthButton)
    nextMonthButton.anchor(top: calendarView.topAnchor, left: monthLabel.rightAnchor, bottom: dividerView.topAnchor, right: calendarView.rightAnchor)
    
    collectionView = UICollectionView(frame: .zero , collectionViewLayout: createCompositionalLayout())
    collectionView.register(UserProfileDayCollectionViewCell.self, forCellWithReuseIdentifier: UserProfileDayCollectionViewCell.reuseID )
    collectionView.backgroundColor = UIColor.clear
    collectionView.isScrollEnabled = false
    collectionView.alwaysBounceVertical = false
    collectionView.alwaysBounceHorizontal = false
    
    calendarView.addSubview(collectionView)
    collectionView.anchor(top: dividerView.topAnchor, left: calendarView.leftAnchor, bottom: calendarView.bottomAnchor, right: calendarView.rightAnchor, topConstant: 16.superAdjusted, leftConstant: 16.adjusted, bottomConstant: 16.superAdjusted, rightConstant: 16.adjusted )
    
    settingsButton.configure(image: UIImage(named: "setting")?.template, blurEffect: false)
  }
  
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection{
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(45.adjusted), heightDimension: .absolute(45.adjusted))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(45.adjusted))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .fixed(5.adjusted)
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.interGroupSpacing = 5.adjusted
    
    return section
  }
  
  //MARK: - Bind To
  func bindViewModel() {
    
    let input = UserProfileViewModel.Input(
      wreathImageViewTrigger: wreathImageView.rx.tapGesture().when(.recognized).map{ _ in return }.asDriver(onErrorJustReturn: ()) ,
      leftButtonClickTrigger: previousMonthButton.rx.tap.asDriver() ,
      rightButtonClickTrigger: nextMonthButton.rx.tap.asDriver() ,
      settingsButtonClickTrigger: settingsButton.rx.tap.asDriver() ,
      selection: collectionView.rx.itemSelected.asDriver()
    )
    
    let output = viewModel.transform(input: input)
    
    output.completedTaskCount.drive(completedTasksLabel.rx.text).disposed(by: disposeBag)
    output.completedTaskStatus.drive(dayStatusLabel.rx.text).disposed(by: disposeBag)
    output.monthText.drive(monthLabel.rx.text).disposed(by: disposeBag)
    output.selectedCalendarDay.drive().disposed(by: disposeBag)
    output.dataSource.drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    output.settingsButtonClicked.drive().disposed(by: disposeBag)
    output.completedTasksGroupedByType.drive(typeLabelsBinder).disposed(by: disposeBag)
    output.wreathImageViewClick.drive().disposed(by: disposeBag)
  }
  
  var typeLabelsBinder: Binder<[String]> {
    return Binder(self, binding: { (vc, typeTexts) in
      vc.typeLabel1.text = typeTexts[safe: 0] ?? ""
      vc.typeLabel2.text = typeTexts[safe: 1] ?? ""
      vc.typeLabel3.text = typeTexts[safe: 2] ?? ""
      vc.typeLabel4.text = typeTexts[safe: 3] ?? ""
    })
  }

  
  //MARK: - Configure Data Source
  func configureDataSource() {
    dataSource = RxCollectionViewSectionedAnimatedDataSource<UserProfileSectionModel>(configureCell: { [weak self] (_, collectionView, indexPath, calendarDay) in
      guard let self = self else { return UICollectionViewCell() }
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileDayCollectionViewCell.reuseID, for: indexPath) as! UserProfileDayCollectionViewCell
      let cellViewModel = UserProfileDayCollectionViewCellModel(services: self.viewModel.services, calendarDay: calendarDay)
      cell.viewModel = cellViewModel
      cell.bindViewModel()
      return cell
    })
  }
  
}


extension UserProfileViewController: ConfigureColorProtocol {
  
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
  }
}
