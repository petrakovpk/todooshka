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
  
  let settingsButton = TDTopRoundButton(image: UIImage(named: "setting")?.template, blurEffect: false )
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
    view.layer.cornerRadius = 53 / 2
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
    configureColor()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.tabBarController?.tabBar.isHidden = false
  }
    
  //MARK: - Configure UI
  func configureUI() {
    view.addSubview(settingsButton)
    settingsButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, topConstant: 8, rightConstant: 16, widthConstant: 50, heightConstant: 50)
    
    helloLabel.text = "Добро пожаловать!"
    helloLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
    
    view.addSubview(helloLabel)
    helloLabel.anchor( left: view.leftAnchor,  right: settingsButton.leftAnchor, leftConstant: 16, rightConstant: 16)
    helloLabel.centerYAnchor.constraint(equalTo: settingsButton.centerYAnchor).isActive = true
    
    view.addSubview(wreathImageView)
    wreathImageView.anchor(top: settingsButton.bottomAnchor, topConstant: 20, heightConstant: 119)
    wreathImageView.anchorCenterXToSuperview()
    
    completedTasksLabel.font = UIFont.systemFont(ofSize: 35, weight: .medium)
    
    wreathImageView.addSubview(completedTasksLabel)
    completedTasksLabel.anchorCenterXToSuperview()
    completedTasksLabel.anchor(bottom: wreathImageView.bottomAnchor, bottomConstant: 119 / 2)
    
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
    stackView.anchor(top: wreathImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 19, leftConstant: 32, rightConstant: 32,  heightConstant: 15)
  
    view.addSubview(dayStatusBackgroundView)
    dayStatusBackgroundView.anchorCenterXToSuperview()
    dayStatusBackgroundView.anchor(top: typeLabel1.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 30, leftConstant: 16, rightConstant: 16,  heightConstant: 53)
    
    dayStatusBackgroundView.addSubview(dayStatusLabel)
    dayStatusLabel.anchorCenterXToSuperview()
    dayStatusLabel.anchorCenterYToSuperview()
    
    let calendarView = UIView()
    calendarView.backgroundColor = UIColor(named: "userProfileCalendarBackground")
    calendarView.cornerRadius = 11
    
    view.addSubview(calendarView)
    calendarView.anchor(top: dayStatusBackgroundView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 30, leftConstant: 16, bottomConstant: 32, rightConstant: 16)
    
    monthLabel.textAlignment = .center
    monthLabel.textColor = UIColor(named: "appText")
    monthLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    
    calendarView.addSubview(monthLabel)
    monthLabel.anchorCenterXToSuperview()
    monthLabel.anchor(top: calendarView.topAnchor, topConstant: 20.0)
    
    let dividerView = UIView()
    dividerView.backgroundColor = UIColor(named: "userProfileCalendarDividerBackground")
    
    calendarView.addSubview(dividerView)
    dividerView.anchor(top: monthLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 20, heightConstant: 1.0)
    
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
    collectionView.anchor(top: dividerView.topAnchor, left: calendarView.leftAnchor, bottom: calendarView.bottomAnchor, right: calendarView.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16 )
    
  }
  
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection{
    
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(45), heightDimension: .absolute(45))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(45))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .fixed(5)
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.interGroupSpacing = 5
    
    return section
  }
  
  //MARK: - Bind To
  func bindTo(with viewModel: UserProfileViewModel) {
    self.viewModel = viewModel
    
    settingsButton.rx.tapGesture().when(.recognized).bind{ _ in self.viewModel.settingsButtonClicked() }.disposed(by: disposeBag)
    
    previousMonthButton.rx.tapGesture().when(.recognized).bind{ _ in self.viewModel.previousMonthButtonClicked() }.disposed(by: disposeBag)
    nextMonthButton.rx.tapGesture().when(.recognized).bind{ _ in self.viewModel.nextMonthButtonClicked() }.disposed(by: disposeBag)
    
    viewModel.deltaMonth.bind{ [weak self] deltaMonth in
      guard let self = self else { return }
      let date = Date().adding(.month, value: deltaMonth)
      
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "ru_RU")
      dateFormatter.dateFormat = "LLLL"
      var stringDate = dateFormatter.string(from: date)
      stringDate.firstCharacterUppercased()
      
      self.monthLabel.text = stringDate
    }.disposed(by: disposeBag)
    
    viewModel.completedTasksLabelOutput.bind(to: completedTasksLabel.rx.text).disposed(by: disposeBag)
    viewModel.typeLabel1TextOutput.bind(to: typeLabel1.rx.text).disposed(by: disposeBag)
    viewModel.typeLabel2TextOutput.bind(to: typeLabel2.rx.text).disposed(by: disposeBag)
    viewModel.typeLabel3TextOutput.bind(to: typeLabel3.rx.text).disposed(by: disposeBag)
    viewModel.typeLabel4TextOutput.bind(to: typeLabel4.rx.text).disposed(by: disposeBag)
    viewModel.dayStatusTextOutput.bind(to: dayStatusLabel.rx.text).disposed(by: disposeBag)
  }
  
  //MARK: - Configure Data Source
  func configureDataSource() {
    dataSource = RxCollectionViewSectionedAnimatedDataSource<UserProfileSectionModel>(configureCell: { [weak self] (_, collectionView, indexPath, calendarDay) in
      guard let self = self else { return UICollectionViewCell() }
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileDayCollectionViewCell.reuseID, for: indexPath) as! UserProfileDayCollectionViewCell
      let cellViewModel = UserProfileDayCollectionViewCellModel(services: self.viewModel.services, calendarDay: calendarDay)
      cell.bindToViewModel(viewModel: cellViewModel)
      return cell
    })
    
    viewModel.dataSource.asDriver()
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.bind{ [weak self] indexPath in
      guard let self = self else { return }
      self.viewModel.daySelected(indexPath: indexPath)
    }.disposed(by: disposeBag)
  }
  
}


extension UserProfileViewController: ConfigureColorProtocol {
  
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    
  }
}
