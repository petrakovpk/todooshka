//
//  UIViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.08.2021.
//
import UIKit

extension OnboardingViewController: ConfigureColorProtocol {
    func setViewColor() {
        view.backgroundColor = Style.haiti
        
        //Button
        skipButton.backgroundColor = .clear
        
        //CollectionView
        collectionView.backgroundColor = .clear
        
        //View
        firstDot.backgroundColor = Style.fiord
        secondDot.backgroundColor = Style.fiord
        thirdDot.backgroundColor = Style.fiord
        
    }
    
    func setTextColor() {
        
        skipButton.setTitleColor(Style.santasGray, for: .normal)
    }
}

extension CompletedTasksListViewController: ConfigureColorProtocol {
    func setViewColor() {
        view.backgroundColor = Style.haiti
        
        //CollectionView
        collectionView.backgroundColor = .clear
    }
    
    func setTextColor() {
        
 
    }
}

extension DeletedTasksListViewController: ConfigureColorProtocol {
    func setViewColor() {
        view.backgroundColor = Style.haiti
        
        //CollectionView
        collectionView.backgroundColor = .clear
    }
    
    func setTextColor() {
        
 
    }
}

extension IdeaBoxTaskListViewController: ConfigureColorProtocol {
    func setViewColor() {
        view.backgroundColor = Style.haiti
        
        //CollectionView
        collectionView.backgroundColor = .clear
    }
    
    func setTextColor() {
        
 
    }
}

extension OverdueTasksListViewController: ConfigureColorProtocol {
    func setViewColor() {
        view.backgroundColor = Style.haiti
        
        //CollectionView
        collectionView.backgroundColor = .clear
    }
    
    func setTextColor() {
        
 
    }
}

extension TaskListViewController: ConfigureColorProtocol {
    
    func setViewColor() {
        view.backgroundColor = Style.haiti
        
        //CollectionView
        collectionView.backgroundColor = .clear
    }
    
    func setTextColor() {
        
 
    }
}

extension UserProfileViewController: ConfigureColorProtocol {
    
    func setViewColor() {
        view.backgroundColor = Style.haiti
        
    }
    
    func setTextColor() {
        
 
    }
}

extension TaskTypesListViewController: ConfigureColorProtocol {
    
    func setViewColor() {
        view.backgroundColor = Style.haiti
        
    }
    
    func setTextColor() {
        
 
    }
}

extension TaskViewController: ConfigureColorProtocol {
    
    func setViewColor() {
        view.backgroundColor = Style.haiti
        
    }
    
    func setTextColor() {
        
 
    }
}

extension UserProfileSettingsViewController: ConfigureColorProtocol {
    
    func setViewColor() {
        view.backgroundColor = Style.haiti
        tableView.backgroundColor = UIColor.clear
    }
    
    func setTextColor() {
        
 
    }
}

