//
//  CoreDataMappable.swift
//  EasyCoreData
//
//  Created by Anastasia Petrova on 08/02/2020.
//  Copyright © 2020 Petrova. All rights reserved.
//

import CoreData

public protocol CoreDataMappable {
    associatedtype CoreDataModel: NSFetchRequestResult
    
    init(model: CoreDataModel)
}
