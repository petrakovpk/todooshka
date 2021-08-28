//
//  AuthSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 25.08.2021.
//

import RxDataSources

struct AuthSectionItem: IdentifiableType, Equatable {
    
    //MARK: - Properties
    var placeholder: String
    var imageName: String
    
    //MARK: - Identity
    var identity: String { return UUID().uuidString }
}

struct AuthSectionModel: AnimatableSectionModelType {
    
    //MARK: - Identity
    var identity: String { return UUID().uuidString }
    
    //MARK: - Properties
    var items: [AuthSectionItem]
    
    //MARK: - Init
    init(items: [AuthSectionItem]) {
        self.items = items
    }
    
    init(original: AuthSectionModel, items: [AuthSectionItem]) {
        self = original
        self.items = items
    }
}
