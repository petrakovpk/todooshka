//
//  TaskTypeViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.09.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import RxDataSources

class TaskTypeViewController: UIViewController {
  
  //MARK: - Properties
  var viewModel: TaskTypeViewModel!
  let disposeBag = DisposeBag()
  
  private var colorDataSource: RxCollectionViewSectionedAnimatedDataSource<TaskTypeColorSectionModel>!
  private var iconDataSource: RxCollectionViewSectionedAnimatedDataSource<TaskTypeIconSectionModel>!
  
  //MARK: - UI Elements
  private let backButton = UIButton(type: .custom)
  private let titleLabel = UILabel()
  private let nameLabel = UILabel()
  private let taskTypeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .clear
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let nameTextField: UITextField = {
    let field = UITextField()
    field.placeholder = "Введите название типа"
    field.returnKeyType = .done
    return field
  }()
  
  private let colorLabel: UILabel = {
    let label = UILabel()
    label.text = "Цвет:"
    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    return label
  }()
  
  private let saveButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "tick-round")?.original, for: .normal)
    button.semanticContentAttribute = .forceRightToLeft
    return button
  }()
  
  private var colorCollectionView: UICollectionView!
  private let colorCollectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 40, height: 40)
    return layout
  }()
  
  private let imageLabel: UILabel = {
    let label = UILabel()
    label.text = "Значок:"
    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    return label
  }()
  
  private var imageCollectionView: UICollectionView!
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    configureColor()
  }
  
 
  //MARK: - Configure UI
  func configureUI() {
    let headerView = UIView()
    headerView.backgroundColor = UIColor(named: "navigationHeaderViewBackgroundColor")
    
    view.addSubview(headerView)
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)
    
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    
    headerView.addSubview(titleLabel)
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)
    
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    backButton.imageView?.tintColor = UIColor(named: "appText")
    
    headerView.addSubview(backButton)
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    headerView.addSubview(saveButton)
    saveButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    let dividerView = UIView()
    dividerView.backgroundColor = UIColor(named: "navigationBarDividerBackground")
    
    headerView.addSubview(dividerView)
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    view.addSubview(taskTypeImageView)
    taskTypeImageView.anchor(top: dividerView.bottomAnchor, topConstant: 16, widthConstant: 75, heightConstant: 75)
    taskTypeImageView.anchorCenterXToSuperview()
    
    nameLabel.text = "Название типа задач"
    nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    nameLabel.textAlignment = .left
    
    view.addSubview(nameLabel)
    nameLabel.anchor(top: taskTypeImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 21, leftConstant: 16, rightConstant: 16)
    
    view.addSubview(nameTextField)
    nameTextField.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16)
    
    view.addSubview(colorLabel)
    colorLabel.anchor(top: nameTextField.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16)
    
    colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorCollectionViewLayout)
    colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellID")
    colorCollectionView.isScrollEnabled = false
    colorCollectionView.backgroundColor = UIColor.clear
    colorCollectionView.clipsToBounds = false
    
    view.addSubview(colorCollectionView)
    colorCollectionView.anchor(top: colorLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16, heightConstant: 80)
   
    view.addSubview(imageLabel)
    imageLabel.anchor(top: colorCollectionView.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16)
    
    imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    imageCollectionView.register(TaskTypeIconCollectionViewCell.self, forCellWithReuseIdentifier: TaskTypeIconCollectionViewCell.reuseID)
    imageCollectionView.backgroundColor = UIColor.clear
    imageCollectionView.clipsToBounds = false
    
    view.addSubview(imageCollectionView)
    imageCollectionView.anchor(top: imageLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 100)
    
    nameTextField.becomeFirstResponder()
  }
  
  //MARK: - Color CollectionView
  func configureDataSource() {
    colorCollectionView.dataSource = nil
    colorDataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeColorSectionModel>(
      configureCell: {(_, collectionView, indexPath, type) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath)
        cell.cornerRadius = cell.bounds.width / 2
        cell.backgroundColor = type.color
        return cell
      })
    
    colorCollectionView.rx.itemSelected.bind{ self.viewModel.colorSelected(indexPath: $0) }.disposed(by: disposeBag)
    
    viewModel.colorDataSource.asDriver()
      .drive(colorCollectionView.rx.items(dataSource: colorDataSource))
      .disposed(by: disposeBag)
    
    imageCollectionView.dataSource = nil
    iconDataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeIconSectionModel>(
      configureCell: {(_, collectionView, indexPath, taskTypeIcon) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeIconCollectionViewCell.reuseID, for: indexPath) as! TaskTypeIconCollectionViewCell
        let cellViewModel = TaskTypeIconCollectionViewCellModel(services: self.viewModel.services, taskTypeIcon: taskTypeIcon)
        cell.bindToViewModel(viewModel: cellViewModel)
        return cell
      })
    
    viewModel.iconDataSource.asDriver()
      .drive(imageCollectionView.rx.items(dataSource: iconDataSource))
      .disposed(by: disposeBag)
    
    imageCollectionView.rx.itemSelected.bind{ self.viewModel.imageSelected(indexPath: $0) }.disposed(by: disposeBag)
  }
  
  //MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(40), heightDimension: .absolute(40))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(40), heightDimension: .estimated(40))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    section.interGroupSpacing = 10.0
    return section
  }
  
  //MARK: - Bind TO
  func bindTo(with viewModel: TaskTypeViewModel) {
    self.viewModel = viewModel
    
    viewModel.titleOutput.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
    viewModel.typeTextOutput.bind(to: nameTextField.rx.text).disposed(by: disposeBag)
    viewModel.typeImageNameOutput.bind{ [weak self] imageName in
      guard let self = self else { return }
      guard let imageName = imageName else { return }
      guard let image = UIImage(named: imageName)?.template else { return }
      self.taskTypeImageView.image = image
    }.disposed(by: disposeBag)
    viewModel.typeImageHexColorOutput.bind{ [weak self] hexColor in
      guard let self = self else { return }
      guard let hexColor = hexColor else { return }
      guard let color = UIColor(hexString: hexColor) else { return }
      self.taskTypeImageView.tintColor = color
    }.disposed(by: disposeBag)
    
    backButton.rx.tap.bind{ viewModel.backButtonClicked() }.disposed(by: disposeBag)
    saveButton.rx.tap.bind{ viewModel.saveButtonClicked() }.disposed(by: disposeBag)
    nameTextField.rx.text.orEmpty.bind(to: viewModel.typeTextInput).disposed(by: disposeBag)
    nameTextField.rx.controlEvent(.editingDidEndOnExit).bind{ _ in viewModel.saveButtonClicked() }.disposed(by: disposeBag)
  }
}



extension TaskTypeViewController: ConfigureColorProtocol {
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
  }
}
