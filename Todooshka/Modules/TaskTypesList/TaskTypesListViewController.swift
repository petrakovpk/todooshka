//
//  TaskTypesListViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import RxDataSources

class TaskTypesListViewController: UIViewController {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    
    var tableView = UITableView(frame: .zero, style: .grouped)
    var dataSource: RxTableViewSectionedReloadDataSource<TaskTypesListSectionModel>!
    var viewModel: TaskTypesListViewModel!
    
    //MARK: - UI Elements
    private let titleLabel = UILabel(text: "Select the type of tasks")
    private let backButton = UIButton(type: .custom)
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setViewColor()
        setTextColor()
    }
    
    //MARK: -
    func configureUI() {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(hexString: "#07091d")
        
        view.addSubview(headerView)
        headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)
                
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
       
        headerView.addSubview(titleLabel)
        titleLabel.anchorCenterXToSuperview()
        titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)
       
        backButton.setImage(UIImage(named: "arrow-left")?.original, for: .normal)
        
        headerView.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)

        let dividerView = UIView()
        dividerView.backgroundColor = UIColor(hexString: "#111433")

        headerView.addSubview(dividerView)
        dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
        
        tableView.register(TaskTypesTableViewCell.self, forCellReuseIdentifier: TaskTypesTableViewCell.reuseID)
        tableView.isEditing = true
        
        titleLabel.text = "Order task types:"
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .white
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, topConstant: 25, leftConstant: 16)
        
        view.addSubview(tableView)
        tableView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
    }
    
    //MARK: - Bind To
    func bindTo(with viewModel: TaskTypesListViewModel) {
        self.viewModel = viewModel
        
        dataSource = RxTableViewSectionedReloadDataSource<TaskTypesListSectionModel> { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskTypesTableViewCell.reuseID, for: indexPath) as! TaskTypesTableViewCell
            cell.configure(with: item)
            return cell as UITableViewCell
        }
                
        viewModel.dataSource.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.isLoadingOutput.bind{[weak self] isLoading in
            guard let self = self else { return }
            
        }.disposed(by: disposeBag)
                
        tableView.rx.itemMoved.bind{ [weak self] indexPaths in
            guard let self = self else { return }
            self.viewModel.tableRowMoved(sourceIndex: indexPaths.sourceIndex, destinationIndex: indexPaths.destinationIndex )
        }.disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        backButton.rx.tap.bind{ self.viewModel.leftBarButtonBackItemClick() }.disposed(by: disposeBag)
    }
}

extension TaskTypesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
}
