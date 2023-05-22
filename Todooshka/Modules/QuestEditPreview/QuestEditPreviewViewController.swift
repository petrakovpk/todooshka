//
//  QuestCreateFirstStepViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 13.05.2023.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class QuestEditPreviewViewController: TDViewController {
  public var viewModel: QuestEditPreviewViewModel!
  
  private let disposeBag = DisposeBag()
 
  private let questTextLabel: UILabel = {
    let label = UILabel(text: "Название задачи:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let questNameTextField: TDTaskTextField = {
    let textField = TDTaskTextField(placeholder: "Шикарные блинчики")
    let spacer = UIView()
    textField.returnKeyType = .done
    textField.rightView = spacer
    textField.rightViewMode = .always
    spacer.anchor(
      widthConstant: Sizes.TextFields.TDTaskTextField.heightConstant,
      heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant)
    return textField
  }()
  
  private let questNameSaveButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.tickSquare.image.template, for: .normal)
    button.tintColor = .black
    return button
  }()
 
  private let coverLabel: UILabel = {
    let label = UILabel(text: "Обложка:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let coverImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleToFill
    imageView.cornerRadius = 8
    imageView.backgroundColor = .lightGray
    return imageView
  }()
  
  private let questCategoryLabel: UILabel = {
    let label = UILabel(text: "В какую категорию добавить:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private var questCategoryCollectionView: UICollectionView!
  private var questCategoryDataSource: RxCollectionViewSectionedAnimatedDataSource<PublicKindSection>!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureQuestCategoryDataSource()
    bindViewModel()
  }
  
  func configureUI() {
    backButton.isHidden = false
    
    titleLabel.text = "Информация для публикации"
    hideKeyboardWhenTappedAround()
    
    questCategoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createQuestCategoryCompositionalLayout())
    questCategoryCollectionView.backgroundColor = UIColor.clear
    questCategoryCollectionView.clipsToBounds = false
    questCategoryCollectionView.isScrollEnabled = false
    questCategoryCollectionView.register(QuestCategoryCell.self, forCellWithReuseIdentifier: QuestCategoryCell.reuseID)
    
    view.addSubviews([
      questTextLabel,
      questNameTextField,
      questNameSaveButton,
      coverLabel,
      coverImageView,
      questCategoryLabel,
      questCategoryCollectionView
    ])
    
    questTextLabel.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    questNameTextField.anchor(
      top: questTextLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant
    )
    
    questNameSaveButton.centerYAnchor.constraint(equalTo: questNameTextField.centerYAnchor).isActive = true
    questNameSaveButton.anchor(
      right: questNameTextField.rightAnchor,
      widthConstant: 24,
      heightConstant: 24
    )
    
    coverLabel.anchor(
      top: questNameTextField.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 8,
      leftConstant: 16
    )
    
    coverImageView.anchorCenterXToSuperview()
    coverImageView.anchor(
      top: coverLabel.bottomAnchor,
      topConstant: 8,
      widthConstant: 60,
      heightConstant: 90
    )

    questCategoryLabel.anchor(
      top: coverImageView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 8,
      leftConstant: 16
    )
    
    questCategoryCollectionView.anchor(
      top: questCategoryLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 100
    )
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
    questNameTextField.insertText(viewModel.quest.name)
    
    let input = QuestEditPreviewViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      // text
      questNameTextField: questNameTextField.rx.text.orEmpty.asDriver(),
      questNameSaveButtonClickTrigger: questNameSaveButton.rx.tap.asDriver(),
      // quest category
      questCategorySelection: questCategoryCollectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      // header
      outputs.navigateBack.drive(),
      // name
      outputs.saveQuestName.drive(),
      outputs.saveQuestNameButtonIsHidden.drive(questNameSaveButton.rx.isHidden),
      // quest category
      outputs.questCategorySections.drive(questCategoryCollectionView.rx.items(dataSource: questCategoryDataSource)),
      outputs.saveQuestCategory.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
    
  }
  
  private func createQuestCategoryCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.questCategorySection()
    }
  }
  
  private func questCategorySection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .absolute(Sizes.Cells.KindCell.width),
      heightDimension: .absolute(Sizes.Cells.KindCell.height))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .estimated(Sizes.Cells.KindCell.width),
      heightDimension: .estimated(Sizes.Cells.KindCell.height))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
  
  func configureQuestCategoryDataSource() {
    questCategoryCollectionView.dataSource = nil
    
    questCategoryDataSource = RxCollectionViewSectionedAnimatedDataSource<PublicKindSection>(
      configureCell: {_, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestCategoryCell.reuseID, for: indexPath) as! QuestCategoryCell
        cell.configure(with: item)
        return cell
      })
  }
  
}

