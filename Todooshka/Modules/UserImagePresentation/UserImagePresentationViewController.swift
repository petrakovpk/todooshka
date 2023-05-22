//
//  AddAvatarViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift
import AnyImageKit

class UserImagePresentationViewController: UIViewController {
  public var viewModel: UserImagePresentationViewModel!
  
  private let disposeBag = DisposeBag()
  
//  private let divider: UIView = {
//    let view = UIView()
//    view.backgroundColor = Style.Views.CalendarDivider.Background
//    return view
//  }()
  
  private let avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .lightGray
    imageView.cornerRadius = 8
    return imageView
  }()
  
  private var tableView: UITableView!
  private var dataSource: RxTableViewSectionedReloadDataSource<SettingSection>!

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  func configureUI() {
    tableView = UITableView(frame: .zero, style: .grouped)
    
    view.backgroundColor = Style.App.background
    
    view.addSubviews([
  //    divider,
      avatarImageView,
      tableView
    ])
    
//    divider.anchorCenterXToSuperview()
//    divider.anchor(top: view.topAnchor, topConstant: 16, widthConstant: 60, heightConstant: 2)
    
    avatarImageView.anchorCenterXToSuperview()
    avatarImageView.anchor(
      top: view.topAnchor,
      topConstant: 16,
      widthConstant: 80,
      heightConstant: 80
    )

    tableView.backgroundColor = .clear
    tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseID)
    tableView.anchor(
      top: avatarImageView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
  }
  
  func bindViewModel() {
    let input = UserImagePresentationViewModel.Input(
      avatarClickTrigger: avatarImageView.rx.tapGesture().when(.recognized).mapToVoid().asDriver(onErrorJustReturn: ()),
      selection: tableView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.userExtDataImage.drive(avatarImageView.rx.image),
      outputs.sections.drive(tableView.rx.items(dataSource: dataSource)),
      outputs.selectionHandler.drive()
      
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  func configureDataSource() {
    tableView.dataSource = nil
    dataSource = RxTableViewSectionedReloadDataSource<SettingSection>(configureCell: { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseID, for: indexPath) as! SettingsCell
      cell.configure(item: item)
      return cell
    }, titleForHeaderInSection: { dataSource, index in
      return dataSource.sectionModels[index].header
    })
  }
  
}
