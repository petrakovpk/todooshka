//
//  QuestViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 15.05.2023.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class QuestViewController: TDViewController {
  public var viewModel: QuestViewModel!
  
  private let disposeBag = DisposeBag()
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.borderWidth = 0
    textView.backgroundColor = Style.TextFields.AuthTextField.Background
    textView.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    textView.cornerRadius = 8
    textView.isEditable = false
    textView.textAlignment = .center
    return textView
  }()
  
  private let questImagesLabel: UILabel = {
    let label = UILabel(text: "Фото от автора:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private var questImagesCollectionView: UICollectionView!
  private var questImagesDataSource: RxCollectionViewSectionedAnimatedDataSource<QuestImageSection>!
 
  private let usersImagesLabel: UILabel = {
    let label = UILabel(text: "Что получилось у пользователей:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private var questPublicationsCollectionView: UICollectionView!
  private var questPublicationsDataSource: RxCollectionViewSectionedAnimatedDataSource<QuestPublicationsSection>!
  
  private let publishButton: UIButton = {
    let button = UIButton(type: .system)
    let spacing = 10.0
    button.setTitle("Сделать публикацию", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.Rose
    button.cornerRadius = 8
    return button
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureQuestImagesDataSource()
    configureUserResultDataSource()
    bindViewModel()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    descriptionTextView.centerVerticalText()
  }
  
  
  func configureUI() {
    backButton.isHidden = false
    
    hideKeyboardWhenTappedAround()

    questImagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: questImagesCompositionalLayout())
    questImagesCollectionView.backgroundColor = .clear
    questImagesCollectionView.register(QuestImageCell.self, forCellWithReuseIdentifier: QuestImageCell.reuseID)
    
    questPublicationsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: usersResultsCompositionalLayout())
    questPublicationsCollectionView.backgroundColor = .clear
    questPublicationsCollectionView.register(QuestPublicationsCell.self, forCellWithReuseIdentifier: QuestPublicationsCell.reuseID)
    
    view.addSubviews([
      descriptionTextView,
      questImagesLabel,
      questImagesCollectionView,
      usersImagesLabel,
      questPublicationsCollectionView,
      publishButton
    ])
    
    descriptionTextView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 100
    )
    
    questImagesLabel.anchor(
      top: descriptionTextView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 8,
      leftConstant: 16
    )
   
    questImagesCollectionView.anchor(
      top: questImagesLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 200
    )

    usersImagesLabel.anchor(
      top: questImagesCollectionView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 8,
      leftConstant: 16
    )
    
    questPublicationsCollectionView.anchor(
      top: usersImagesLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 200
    )

    publishButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.Buttons.AppButton.height
    )
  }

  private func questImagesCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.questImagesSection()
    }
  }

  private func questImagesSection() -> NSCollectionLayoutSection {
    let itemWidth = UIScreen.main.bounds.width / 3
    let itemHeight = itemWidth * 1.5
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(itemHeight))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3) // set item count per row here
    group.interItemSpacing = .fixed(5)  // set inter-item spacing here
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
    section.interGroupSpacing = 5  // set inter-group spacing here
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    return section
  }
  
  private func usersResultsCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.usersResultsSection()
    }
  }

  private func usersResultsSection() -> NSCollectionLayoutSection {
    let itemWidth = UIScreen.main.bounds.width / 3
    let itemHeight = itemWidth * 1.5
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(itemHeight))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3) // set item count per row here
    group.interItemSpacing = .fixed(5)  // set inter-item spacing here
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
    section.interGroupSpacing = 5  // set inter-group spacing here
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    return section
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
    titleLabel.text = viewModel.quest.name
    descriptionTextView.text = viewModel.quest.description
    
    let input = QuestViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )
  
    let outputs = viewModel.transform(input: input)
    
    [
      // header
      outputs.navigateBack.drive(),
      // quest image
      outputs.questImageSections.drive(questImagesCollectionView.rx.items(dataSource: questImagesDataSource)),
      // questPublicationsSections
      outputs.questPublicationsSections.drive(questPublicationsCollectionView.rx.items(dataSource: questPublicationsDataSource)),

    ]
      .forEach { $0.disposed(by: disposeBag) }
    
  }
  
  var publishButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in

    })
  }

  // MARK: - Configure Data Source
  private func configureQuestImagesDataSource() {
    questImagesCollectionView.dataSource = nil

    questImagesDataSource = RxCollectionViewSectionedAnimatedDataSource<QuestImageSection>(
      configureCell: { _, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestImageCell.reuseID, for: indexPath) as! QuestImageCell
        cell.configure(with: item)
        return cell
      })
  }
  
  private func configureUserResultDataSource() {
    questPublicationsCollectionView.dataSource = nil

    questPublicationsDataSource = RxCollectionViewSectionedAnimatedDataSource<QuestPublicationsSection>(
      configureCell: { _, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestPublicationsCell.reuseID, for: indexPath) as! QuestPublicationsCell
        cell.configure(with: item)
        return cell
      })
  }
}

