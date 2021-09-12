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
  private let overdueTaskButton = TDTopRoundButton(image: UIImage(named: "timer-pause")?.template, blurEffect: true)
  
  private let ideaTasksButton = TDTopRoundButton(image: UIImage(named: "lamp-charge")?.template, blurEffect: true )
  
  fileprivate let headerImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  fileprivate let taskCountLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    return label
  }()
  
  fileprivate let animationView = AnimationView(name: "task_animation")
  
  fileprivate let sortedByButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "sort")?.template, for: .normal)
    button.imageView?.tintColor = .white
    return button
  }()
  
  fileprivate let expandImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    imageView.image = UIImage(named: "arrow-top")
    return imageView
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
  
  //MARK: - ConfigureUI
  private func configureUI() {
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .repeat(3.0)
    animationView.animationSpeed = 1.0
    
    view.addSubview(animationView)
    animationView.anchorCenterXToSuperview()
    animationView.anchorCenterYToSuperview()
    animationView.anchor(heightConstant: 222.0)
    
    animationView.play(toProgress: 1.0)
    
    let label = UILabel()
    label.textColor = UIColor(red: 0.424, green: 0.429, blue: 0.496, alpha: 1)
    label.text = "Все задачи на сегодня сделаны!"
    label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    
    animationView.addSubview(label)
    label.anchor(bottom: animationView.bottomAnchor, bottomConstant: 10)
    label.anchorCenterXToSuperview()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    collectionView.register(TaskListCollectionViewCell.self, forCellWithReuseIdentifier: TaskListCollectionViewCell.reuseID)
    collectionView.alwaysBounceVertical = true
    
    view.addSubview(headerImageView)
    headerImageView.anchor(top: view.topAnchor, left: view.leftAnchor,  right: view.rightAnchor, heightConstant: 207)
    
    view.addSubview(taskCountLabel)
    taskCountLabel.anchor(top: headerImageView.bottomAnchor, left: view.leftAnchor, topConstant: 29, leftConstant: 16)
    
    view.addSubview(sortedByButton)
    sortedByButton.anchor(top: headerImageView.bottomAnchor, right: view.rightAnchor, topConstant: 21, rightConstant: 16, widthConstant: 35, heightConstant: 35)
    sortedByButton.cornerRadius = 36 / 2
    
    view.addSubview(collectionView)
    collectionView.anchor(top: taskCountLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 29, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
    
    view.addSubview(ideaTasksButton)
    ideaTasksButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, topConstant: 8, rightConstant: 16, widthConstant: 50, heightConstant: 50)
    
    view.addSubview(overdueTaskButton)
    overdueTaskButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: ideaTasksButton.leftAnchor, topConstant: 8, rightConstant: 8, widthConstant: 50, heightConstant: 50)
  }
  
  func configureUI(tasksCount: Int, tasksTypeCount: Int) {
    
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
    
    sortedByButton.isHidden = (tasksTypeCount < 2)
    
  }
  
  //MARK: - Configure Data Source
  private func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>(
      configureCell: { (_, collectionView, indexPath, task) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskListCollectionViewCell.reuseID, for: indexPath) as! TaskListCollectionViewCell
        let cellViewModel = TaskListCollectionViewCellModel(services: self.viewModel.services, task: task)
        cell.bindToViewModel(viewModel: cellViewModel)
        return cell
      })
    
    viewModel.dataSource.asDriver()
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.bind { self.viewModel.openTask(indexPath: $0) }.disposed(by: disposeBag)
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
  func bindTo(with viewModel: TaskListViewModel) {
    self.viewModel = viewModel
    
    ideaTasksButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.ideaBoxButtonClicked() }.disposed(by: disposeBag)
    overdueTaskButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.navigateToOverdueTaskList()}.disposed(by: disposeBag)
    sortedByButton.rx.tap.bind{ viewModel.sortedByButtonClicked() }.disposed(by: disposeBag)
    
    viewModel.overdueButtonIsHidden.bind(to: overdueTaskButton.rx.isHidden).disposed(by: disposeBag)
    
    viewModel.dataSource.bind{[weak self] models in
      guard let self = self else { return }
      guard let model = models.first else {
        self.configureUI(tasksCount: 0, tasksTypeCount: 0)
        return
      }
      
      let tasksTypeCount = Dictionary(grouping: model.items, by: { $0.type }).count
      self.configureUI(tasksCount: model.items.count, tasksTypeCount: tasksTypeCount)
      
    }.disposed(by: disposeBag)
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
