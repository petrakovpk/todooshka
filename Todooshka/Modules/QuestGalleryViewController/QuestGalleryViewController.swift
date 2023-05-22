//
//  QuestImagePreviewViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.05.2023.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class QuestGalleryViewController: TDViewController {
  public var viewModel: QuestGalleryViewModel!
  
  private let disposeBag = DisposeBag()

  private var questImagesCollectionView: UICollectionView!
  private var questImagesDataSource: RxCollectionViewSectionedAnimatedDataSource<QuestImageSection>!
  
  private let remvoveButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Удалить", for: .normal)
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
    bindViewModel()
  }
  
  private var indexPath: IndexPath?

  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let indexPath = indexPath {
      questImagesCollectionView.scrollToItem(at: indexPath, at: .right, animated: false)
      self.indexPath = nil
    }
  }
  
  func configureUI() {
    backButton.isHidden = false
    
    titleLabel.text = "Галерея"
    hideKeyboardWhenTappedAround()

    questImagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: authorExamplesCompositionalLayout())
    questImagesCollectionView.backgroundColor = .clear
    questImagesCollectionView.register(QuestImageCell.self, forCellWithReuseIdentifier: QuestImageCell.reuseID)
    
    view.addSubviews([
      questImagesCollectionView,
      remvoveButton
    ])
    
    questImagesCollectionView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
    
    remvoveButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.Buttons.AppButton.height
    )

  }

  private func authorExamplesCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }

  private func section() -> NSCollectionLayoutSection {
    let itemWidth = UIScreen.main.bounds.width - 16 * 2
    let itemHeight = itemWidth * 1.5
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(itemHeight))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemHeight))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .paging
    return section
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
  
    let input = QuestGalleryViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      willDisplayCell: questImagesCollectionView.rx.willDisplayCell.asDriver(),
      removeButtonClickTrigger: remvoveButton.rx.tap.asDriver()
    )
  
    let outputs = viewModel.transform(input: input)
    
    [
      // header
      outputs.navigateBack.drive(),
      // questImageSections
      outputs.questImageSections.drive(questImagesCollectionView.rx.items(dataSource: questImagesDataSource)),
      outputs.scrollToImage.drive(scrollToIndexPathBinder),
      //
      outputs.removeImage.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
    
  }
  
  var scrollToIndexPathBinder: Binder<IndexPath> {
    return Binder(self, binding: { vc, indexPath in
      vc.indexPath = indexPath
      //vc.questImagesCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
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
}

