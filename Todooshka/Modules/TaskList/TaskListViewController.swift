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
    private lazy var overdueTaskButton = TDTopRoundButton(image: UIImage(named: "timer-pause")?.original)
    
    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "camping")
        return imageView
    }()
    
    private lazy var taskCountLabel: UILabel = {
       let label = UILabel()
        label.text = "6 TASKS TODAY"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private lazy var animationView = AnimationView(name: "task_animation")
    
    private lazy var sortedByButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Sort by", for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 0.106, green: 0.114, blue: 0.208, alpha: 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        return button
    }()
    
    private lazy var expandImageView: UIImageView = {
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
        
        setViewColor()
        setTextColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - ConfigureUI
    func configureUI() {
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
        label.text = "All tasks for today are done!"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        animationView.addSubview(label)
        label.anchor(bottom: animationView.bottomAnchor, bottomConstant: 10)
        label.anchorCenterXToSuperview()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.register(TaskListCollectionViewCell.self, forCellWithReuseIdentifier: TaskListCollectionViewCell.reuseID)
        collectionView.alwaysBounceVertical = true
        
        view.addSubview(headerImageView)
        headerImageView.anchor(top: view.topAnchor, left: view.leftAnchor,  right: view.rightAnchor, heightConstant: 187.0)
        
        view.addSubview(taskCountLabel)
        taskCountLabel.anchor(top: headerImageView.bottomAnchor, left: view.leftAnchor, topConstant: 29, leftConstant: 16)
        
        view.addSubview(sortedByButton)
        sortedByButton.anchor(top: headerImageView.bottomAnchor, right: view.rightAnchor, topConstant: 21, rightConstant: 16, widthConstant: 81, heightConstant: 36)
        sortedByButton.cornerRadius = 36 / 2
        
        view.addSubview(collectionView)
        collectionView.anchor(top: taskCountLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 29, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
        
        view.addSubview(overdueTaskButton)
        overdueTaskButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, topConstant: 8, rightConstant: 16, widthConstant: 50, heightConstant: 50)
        
        
        
    }
    
    func configureDataSource() {
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
        
        overdueTaskButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.navigateToOverdueTaskList()}.disposed(by: disposeBag)
        sortedByButton.rx.tap.bind{ viewModel.sortedByButtonClicked() }.disposed(by: disposeBag)
        
        viewModel.overdueButtonIsHidden.bind(to: overdueTaskButton.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.dataSource.bind{[weak self] models in
            guard let self = self else { return }
            if let model = models.first,
               model.items.count > 0 {
                self.animationView.isHidden = true
            } else {
                self.animationView.isHidden = false
                self.animationView.play()
            }
        }.disposed(by: disposeBag)
    }
}

