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
  
  private var addPhotoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = Icon.camera.image
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let coverImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.cornerRadius = 12
    imageView.backgroundColor = Palette.SingleColors.Portage.withAlphaComponent(0.3)
    return imageView
  }()
  
  private let coverTextLabelContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = Palette.SingleColors.Portage
    return view
  }()
  
  private let coverTextLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 10, weight: .light)
    label.textAlignment = .center
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    return label
  }()
  
  private let questTextLabel: UILabel = {
    let label = UILabel(text: "Название задачи:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .left
    return label
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
      coverImageView,
      questCategoryLabel,
      questCategoryCollectionView
    ])
    
    coverImageView.addSubviews([
      addPhotoImageView,
      coverTextLabelContainerView,
      coverTextLabel
    ])
    
    coverImageView.anchorCenterXToSuperview()
    coverImageView.anchor(
      top: headerView.bottomAnchor,
      topConstant: 12,
      widthConstant: (UIScreen.main.bounds.width - 32) / 4,
      heightConstant: (UIScreen.main.bounds.width - 32) / 3.5
    )
    
    addPhotoImageView.anchorCenterXToSuperview()
    addPhotoImageView.anchorCenterYToSuperview(constant: -15)
    addPhotoImageView.anchor(
      widthConstant: 30,
      heightConstant: 30
    )
    
    coverTextLabelContainerView.anchor(
      left: coverImageView.leftAnchor,
      bottom: coverImageView.bottomAnchor,
      right: coverImageView.rightAnchor,
      heightConstant: 30
    )
    
    coverTextLabel.anchor(
      top: coverTextLabelContainerView.topAnchor,
      left: coverTextLabelContainerView.leftAnchor,
      bottom: coverTextLabelContainerView.bottomAnchor,
      right: coverTextLabelContainerView.rightAnchor,
      topConstant: 4,
      leftConstant: 4,
      bottomConstant: 4,
      rightConstant: 4
    )
    
    questCategoryLabel.anchor(
      top: coverTextLabel.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 12,
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
    
    let input = QuestEditPreviewViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      // text
      questImageClickTrigger: coverImageView.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      // quest category
      questCategorySelection: questCategoryCollectionView.rx.itemSelected.asDriver()
    )
    //
    let outputs = viewModel.transform(input: input)
    //
    [
      // header
      outputs.navigateBack.drive(),
      // image
      outputs.previewText.drive(coverTextLabel.rx.text),
      outputs.previewImage.drive(previewImageBinder),
      outputs.openImagePickerIsRequired.drive(),
      //  quest category
      outputs.questCategorySections.drive(questCategoryCollectionView.rx.items(dataSource: questCategoryDataSource)),
      outputs.saveQuestCategory.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
    //
  }
  
  var previewImageBinder: Binder<UIImage?> {
    return Binder(self, binding: { vc, image in
      if let image = image {
        vc.addPhotoImageView.isHidden = true
        vc.coverImageView.image = image
      } else {
        vc.addPhotoImageView.isHidden = false
        vc.coverImageView.image = nil
      }
    })
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

