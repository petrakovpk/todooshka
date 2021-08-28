//
//  OnboardingViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.08.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class OnboardingViewController: UIViewController {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: OnboardingViewModel!
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<OnboardingSectionModel>!
    
    //MARK: - Constants
    static let collectionViewHeight = CGFloat(575.0)
    
    //MARK: - UI Elements
    lazy var firstDot = UIView()
    lazy var secondDot = UIView()
    lazy var thirdDot = UIView()
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "TODOOSHKA"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    lazy var skipButton: UIButton = {
        let button = UIButton(type: .custom)
        let attrString = NSAttributedString(string: "SKIP", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        button.setAttributedTitle(attrString, for: .normal)
        return button
    }()
    
    lazy var authButton = UIButton(type: .custom)
    
    var collectionView: UICollectionView!
    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width , height: OnboardingViewController.collectionViewHeight)
        return layout
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureDataSource()
        setViewColor()
        setTextColor()
    }
    
    //MARK: - Configure UI
    func configureUI() {
        
        view.addSubview(headerLabel)
        headerLabel.anchor(top: view.topAnchor, topConstant: 84)
        headerLabel.anchorCenterXToSuperview()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: OnboardingCollectionViewCell.reuseID)
        
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        view.addSubview(collectionView)
        collectionView.anchor(top: headerLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 76, heightConstant: OnboardingViewController.collectionViewHeight)
        
        firstDot.cornerRadius = 3
        secondDot.cornerRadius = 3
        thirdDot.cornerRadius = 3
        
        view.addSubview(firstDot)
        view.addSubview(secondDot)
        view.addSubview(thirdDot)

        view.addSubview(skipButton)
        skipButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, bottomConstant: 16)
        skipButton.anchorCenterXToSuperview()
        
       // authButton.configure(text: "Create an account or sign in")
        authButton.setTitle("Create an account or sign in", for: .normal)
        
        view.addSubview(authButton)
        authButton.anchor(left: view.leftAnchor, bottom: skipButton.topAnchor, right: view.rightAnchor, leftConstant: 16, bottomConstant: 26, rightConstant: 16, heightConstant: 50)
        
        secondDot.anchor(bottom: authButton.topAnchor, bottomConstant: 74, widthConstant: 6, heightConstant: 6)
        secondDot.anchorCenterXToSuperview()

        firstDot.removeAllConstraints()
        firstDot.anchor(top: secondDot.topAnchor, right: secondDot.leftAnchor, rightConstant: 10.0, widthConstant: 25, heightConstant: 6)

        thirdDot.removeAllConstraints()
        thirdDot.anchor(top: secondDot.topAnchor, left: secondDot.rightAnchor, leftConstant: 10.0, widthConstant: 6, heightConstant: 6)

    }
    
    func setDotWidth(firstDotPercent: Int, secondDotPercent: Int, thirdDotPercent: Int) {
        
        secondDot.removeAllConstraints()
        secondDot.anchor(bottom: authButton.topAnchor, bottomConstant: 74, widthConstant: CGFloat(6 + 19 * secondDotPercent / 100), heightConstant: 6)
        secondDot.anchorCenterXToSuperview()

        firstDot.removeAllConstraints()
        firstDot.anchor(top: secondDot.topAnchor, right: secondDot.leftAnchor, rightConstant: 10.0, widthConstant: CGFloat(6 + 19 * firstDotPercent / 100), heightConstant: 6)

        thirdDot.removeAllConstraints()
        thirdDot.anchor(top: secondDot.topAnchor, left: secondDot.rightAnchor, leftConstant: 10.0, widthConstant: CGFloat(6 + 19 * thirdDotPercent / 100), heightConstant: 6)
        
        guard let title = skipButton.titleLabel?.text else { return }
        
        if thirdDotPercent == 100 {
            if title == "SKIP" {
                let attrString = NSAttributedString(string: "START", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
                skipButton.setAttributedTitle(attrString, for: .normal)
                skipButton.setTitleColor(Style.burntSienna, for: .normal)
            }
        } else {
            if title == "START" {
                let attrString = NSAttributedString(string: "SKIP", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
                skipButton.setAttributedTitle(attrString, for: .normal)
                skipButton.setTitleColor(Style.santasGray, for: .normal)
            }
        }

        self.view.layoutIfNeeded()
    }
    
    //MARK: - Setup CollectionView
    func configureDataSource() {
        collectionView.dataSource = nil
        dataSource = RxCollectionViewSectionedAnimatedDataSource<OnboardingSectionModel>(
            configureCell: { (_, collectionView, indexPath, onboardingSectionItem) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.reuseID, for: indexPath) as! OnboardingCollectionViewCell
                let cellViewModel = OnboardingCollectionViewCellModel(services: self.viewModel.services, onboardingSectionItem: onboardingSectionItem)
                cell.bindToViewModel(viewModel: cellViewModel)
                return cell
            })
        
        viewModel.dataSource.asDriver()
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
                
        collectionView.rx.didScroll.bind{ [weak self]  _ in
            guard let self = self else { return }
            let cells = self.collectionView.visibleCells
            
            var firstDotPercent = 0
            var secondDotPercent = 0
            var thirdDotPercent = 0
            
            for cell in cells {
                let f = cell.frame
                let w = self.view.window!
                let rect = w.convert(f, from: cell.superview!)
                let inter = rect.intersection(w.bounds)
                let ratio = (inter.width * inter.height) / (f.width * f.height)
                
                if let indexPath = self.collectionView.indexPath(for: cell) {
                    switch indexPath.section {
                    case 0:
                        firstDotPercent = Int(ratio * 100)
                    case 1:
                        secondDotPercent = Int(ratio * 100)
                    case 2:
                        thirdDotPercent = Int(ratio * 100)
                    default:
                        return
                    }
                }
            }
            
            self.setDotWidth(firstDotPercent: firstDotPercent, secondDotPercent: secondDotPercent, thirdDotPercent: thirdDotPercent)
            
        }.disposed(by: disposeBag)
       
    }
    
    //MARK: - Bind To
    func bindTo(with viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        
        skipButton.rx.tap.bind{ [weak self] _ in
            guard let self = self else { return }
            guard let title = self.skipButton.titleLabel?.text else { return }
            
            if title == "SKIP" {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 2), at: .right, animated: true)
            }
            
            if title == "START" {
                self.viewModel.skipButtonClick()
            }
        }.disposed(by: disposeBag)
        
        authButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.authButtonClick() }.disposed(by: disposeBag)
        
        viewModel.authButtonIsHidden.bind(to: authButton.rx.isHidden).disposed(by: disposeBag)
        
    }
}
