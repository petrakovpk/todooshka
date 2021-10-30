//
//  TaskListViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwipeCellKit
import RxGesture
import Lottie

class TaskListViewController: UIViewController {
  
  //MARK: - Properties
  let disposeBag = DisposeBag()
  
  var collectionView: UICollectionView!
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>!
  var viewModel: TaskListViewModel!
  
  //MARK: - UI Elements
  let overdueTaskButton = TDTopRoundButton(type: .system) //TDTopRoundButton(image: UIImage(named: "timer-pause")?.template, blurEffect: true)
  let ideaTasksButton = TDTopRoundButton(type: .system) //TDTopRoundButton(image: UIImage(named: "lamp-charge")?.template, blurEffect: true )
  
  private let headerImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let taskCountLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18.adjusted, weight: .semibold)
    return label
  }()
  
  private let animationView = AnimationView(name: "task_animation")
  
  private let sortedByButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "sort")?.template, for: .normal)
    button.imageView?.tintColor = .white
    button.isHidden = true
    return button
  }()
  
  private let expandImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    imageView.image = UIImage(named: "arrow-top")
    return imageView
  }()
  
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let deleteAlertButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(hexString: "#FF005C")
    let attrString = NSAttributedString(string: "Удалить", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.adjusted, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let cancelAlertButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.adjusted, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(UIColor(named: "appText")!.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
    configureColor()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.tabBarController?.tabBar.isHidden = false
  }
  
  //MARK: - ConfigureUI
  private func configureUI() {
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .repeat(3.0)
    animationView.animationSpeed = 1.0
    
    view.addSubview(animationView)
    animationView.anchorCenterXToSuperview()
    animationView.anchorCenterYToSuperview()
    animationView.anchor(heightConstant: 222.0.adjusted)
    
    animationView.play(toProgress: 1.0)
    
    let label = UILabel()
    label.textColor = UIColor(red: 0.424, green: 0.429, blue: 0.496, alpha: 1)
    label.font = UIFont.systemFont(ofSize: 15.adjusted, weight: .regular)
    
    animationView.addSubview(label)
    label.anchor(bottom: animationView.bottomAnchor, bottomConstant: 10.adjusted)
    label.anchorCenterXToSuperview()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    collectionView.register(TaskListCollectionViewCell.self, forCellWithReuseIdentifier: TaskListCollectionViewCell.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.layer.masksToBounds = false
    
    view.addSubview(headerImageView)
    headerImageView.anchor(top: view.topAnchor, left: view.leftAnchor,  right: view.rightAnchor, heightConstant: 207)
    
    view.addSubview(taskCountLabel)
    taskCountLabel.anchor(top: headerImageView.bottomAnchor, left: view.leftAnchor, topConstant: 29.adjusted, leftConstant: 16)
    
    view.addSubview(sortedByButton)
    sortedByButton.anchor(top: headerImageView.bottomAnchor, right: view.rightAnchor, topConstant: 21.adjusted, rightConstant: 16, widthConstant: 35.adjusted, heightConstant: 35.adjusted)
    sortedByButton.cornerRadius = 36.adjusted / 2
    
    view.addSubview(collectionView)
    collectionView.anchor(top: taskCountLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 29.adjusted, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
        
    view.addSubview(ideaTasksButton)
    ideaTasksButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, topConstant: 8, rightConstant: 16, widthConstant: 50.adjusted, heightConstant: 50.adjusted)

    view.addSubview(overdueTaskButton)
    overdueTaskButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: ideaTasksButton.leftAnchor, topConstant: 8, rightConstant: 8, widthConstant: 50.adjusted, heightConstant: 50.adjusted)
    
    ideaTasksButton.configure(image: UIImage(named: "lamp-charge")?.template, blurEffect: true)
    overdueTaskButton.configure(image: UIImage(named: "timer-pause")?.template, blurEffect: true)
    
  }
  
  func configureUI(tasksCount: Int) {
    
    var image: UIImage?
    
    switch tasksCount {
    case 0:
      taskCountLabel.text = "Ура, задач нет!"
      image = UIImage(named: "header1")
      animationView.isHidden = false
      animationView.play()
    case 1 ... 2:
      taskCountLabel.text = "Надо немного поработать."
      image = UIImage(named: "header2")
      animationView.isHidden = true
    case 3 ... 4:
      taskCountLabel.text = "Надо серьезно поработать!"
      image = UIImage(named: "header3")
      animationView.isHidden = true
    case 5 ... .max:
      taskCountLabel.text = "На грани невозможного!"
      image = UIImage(named: "header4")
      animationView.isHidden = true
    default:
      return
    }
    
    UIView.transition(with:  headerImageView,
                      duration: 1.0,
                      options: .transitionCrossDissolve,
                      animations: {
      self.headerImageView.image = image
    }, completion: nil)
    
  }
  
  private func configureAlert() {
    view.addSubview(alertBackgroundView)
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    let alertWindowView = UIView()
    alertWindowView.cornerRadius = 27
    alertWindowView.backgroundColor = UIColor(named: "appBackground")
    
    alertBackgroundView.addSubview(alertWindowView)
    alertWindowView.anchor(widthConstant: 287.adjusted, heightConstant: 171.adjusted)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()
    
    let alertLabel = UILabel(text: "Удалить задачу?")
    alertLabel.textColor = UIColor(named: "appText")
    alertLabel.textAlignment = .center
    alertLabel.font = UIFont.systemFont(ofSize: 17.adjusted, weight: .medium)
    
    alertWindowView.addSubview(alertLabel)
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * 171.adjusted / 4)
    
    alertWindowView.addSubview(deleteAlertButton)
    deleteAlertButton.anchor(widthConstant: 94.adjusted, heightConstant: 30.adjusted)
    deleteAlertButton.cornerRadius = 15.adjusted
    deleteAlertButton.anchorCenterXToSuperview()
    deleteAlertButton.anchorCenterYToSuperview(constant: 15.adjusted)
    
    alertWindowView.addSubview(cancelAlertButton)
    cancelAlertButton.anchor(top: deleteAlertButton.bottomAnchor, topConstant: 10.adjusted)
    cancelAlertButton.anchorCenterXToSuperview()
  }
  
  //MARK: - Configure Data Source
  private func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>(
      configureCell: { (_, collectionView, indexPath, task) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskListCollectionViewCell.reuseID, for: indexPath) as! TaskListCollectionViewCell
        let cellViewModel = TaskListCollectionViewCellModel(services: self.viewModel.services, task: task)
        cell.viewModel = cellViewModel
        return cell
      })
  }
  
  //MARK: - Setup CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(62))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 5, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 0, trailing: 0)
    return section
  }
  
  //MARK: - Bind To
  func bindViewModel() {

    let input = TaskListViewModel.Input(
      ideaButtonClickTrigger: ideaTasksButton.rx.tapGesture().when(.recognized).map{ _ in return }.asDriver(onErrorJustReturn: ()),
      overdueButtonClickTrigger: overdueTaskButton.rx.tapGesture().when(.recognized).map{ _ in return }.asDriver(onErrorJustReturn: ()),
      sortedByButtoncLickTrigger: sortedByButton.rx.tap.asDriver(),
      deleteAlertButtonClickTrigger: deleteAlertButton.rx.tap.asDriver(),
      cancelAlerrtButtonClickTrigger: cancelAlertButton.rx.tap.asDriver(),
      selection: collectionView.rx.itemSelected.asDriver()
    )
    
    let output = viewModel.transform(input: input)
    output.ideaButtonClick.drive().disposed(by: disposeBag)
    output.overdueButtonClick.drive().disposed(by: disposeBag)
    output.sortedByButtoncLick.drive().disposed(by: disposeBag)
    output.deleteAlertButtonClick.drive().disposed(by: disposeBag)
    output.cancelAlerrtButtonClick.drive().disposed(by: disposeBag)
    output.openTask.drive().disposed(by: disposeBag)
    output.dataSource.drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    output.overdueButtonIsHidden.drive(overdueTaskButton.rx.isHidden).disposed(by: disposeBag)
    output.tasksCount.drive{self.configureUI(tasksCount: $0)}.disposed(by: disposeBag)
    output.alertIsHidden.drive(alertBackgroundView.rx.isHidden).disposed(by: disposeBag)
  }
}


extension TaskListViewController: ConfigureColorProtocol {
  
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    collectionView.backgroundColor = .clear
    
    sortedByButton.backgroundColor = UIColor(named: "taskListSortedByButtonBackground")
    sortedByButton.setTitleColor(.white, for: .normal)
  }
}
