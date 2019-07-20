import CoreData

public protocol CoreDataMappable {
    associatedtype CoreDataModel: NSFetchRequestResult
    
    init(model: CoreDataModel)
}
