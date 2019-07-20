import CoreData

public final class CoreDataController<DBModel, ViewModel>: NSObject, NSFetchedResultsControllerDelegate
    where ViewModel: CoreDataMappable, ViewModel.CoreDataModel == DBModel  {
    public typealias UpdateCallback = () -> Void
    public typealias ChangeCallback = (Change) -> Void
    
    let fetchResultController: NSFetchedResultsController<DBModel>
    public var beginUpdate: UpdateCallback?
    public var endUpdate: UpdateCallback?
    public var changeCallback: ChangeCallback?
    
    public init(entityName: String,
                keyForSort: String,
                predicate: NSPredicate? = nil,
                sectionKey: String) {
        let fetchRequest = NSFetchRequest<DBModel>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: true)
        let sectionSortDescriptor = NSSortDescriptor(key: sectionKey, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, sectionSortDescriptor]
        fetchRequest.predicate = predicate
        
        fetchResultController = NSFetchedResultsController<DBModel>(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStack.instance.context,
            sectionNameKeyPath: sectionKey,
            cacheName: nil)
        super.init()
        fetchResultController.delegate = self
    }
    
    public func fetch() {
        do {
            try fetchResultController.performFetch()
        } catch {
            print(error)
        }
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        beginUpdate?()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        endUpdate?()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        var changeType: Change.ChangeType = .error("CoreData has fucked up!")
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                changeType = .insert(newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                changeType = .delete(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                changeType = .update(indexPath)
            }
        case .move:
            if let fromIndexPath = indexPath, let toIndexPath = newIndexPath {
                changeType = .move(fromIndexPath, toIndexPath)
            }
        default: break
        }
        let change = Change(type: changeType)
        changeCallback?(change)
    }
    
    func getItem(at indexPath: IndexPath) -> ViewModel {
        let item = fetchResultController.object(at: indexPath)
        return ViewModel(model: item)
    }
    
    func numberOfItems(in section: Int) -> Int {
        if let sections = fetchResultController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func numberOfSections() -> Int {
        if let sections = fetchResultController.sections?.count {
            return sections
        } else {
            return 1
        }
    }
    
    func priorityForSectionIndex(for section: Int) -> String? {
        return fetchResultController.sections?[section].name
    }
}

extension CoreDataController where DBModel: NSManagedObject {
    func add(model: DBModel) {
        CoreDataStack.instance.context.insert(model)
        CoreDataStack.instance.saveContext()
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        indexPaths
            .map(fetchResultController.object)
            .forEach(CoreDataStack.instance.context.delete)
        CoreDataStack.instance.saveContext()
    }
    
    func updateModel(indexPath: IndexPath, update: (DBModel) -> Void) {
        let item = fetchResultController.object(at: indexPath)
        update(item)
        CoreDataStack.instance.saveContext()
    }
}

extension CoreDataController {
    public struct Change {
        let type: ChangeType
    }
}

extension CoreDataController.Change {
    public enum ChangeType {
        case insert(IndexPath)
        case delete(IndexPath)
        case move(IndexPath, IndexPath)
        case update(IndexPath)
        case error(String)
    }
}

