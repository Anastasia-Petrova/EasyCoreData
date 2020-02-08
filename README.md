# EasyCoreData

[![CircleCI](https://circleci.com/gh/Anastasia-Petrova/EasyCoreData/tree/master.svg?style=svg)](https://circleci.com/gh/Anastasia-Petrova/EasyCoreData/tree/master)

- Helps you quickly assemble `CoreData` stack

- Provides a generic wrapper around `NSFetchedResultsController`

### Example of Usage:

1. Initialize `CoreDataController` specialized with `PersonManagedObject` and decoded into `PersonViewModel`:

	```swift
	let coreDataController = CoreDataController<PersonManagedObject, PersonViewModel>(
		entityName: PersonManagedObject.firstName, 
		keyForSort: PersonManagedObject.firstName, 
		sectionKey: PersonManagedObject.lastName
	)
	```

1. Set update callbacks:
	
	```swift
	coreDataController.beginUpdate = {
	    tableView.beginUpdates()
	}
	coreDataController.endUpdate = {
	    tableView.endUpdates()
	}
	```

1. Set change callback:

	```swift
	coreDataController.changeCallback = { change in
	    switch change.type {
	    case let .row(rowChangeType):
	        switch rowChangeType {
	        case let .delete(indexPath):
	            tableView.deleteRows(at: [indexPath], with: .automatic)
	        case let .insert(indexPath):
	            tableView.insertRows(at: [indexPath], with: .automatic)
	        case let .move(fromIndexPath, toIndexPath):
	            tableView.deleteRows(at: [fromIndexPath], with: .automatic)
	            tableView.insertRows(at: [toIndexPath], with: .automatic)
	        case let .update(indexPath):
	            tableView.reloadRows(at: [indexPath], with: .automatic)
	        case let .error(error):
	            print(error)
	        }
	    case let .section(sectionChangeType):
	        switch sectionChangeType {
	        case let .delete(index):
	            tableView.deleteSections(IndexSet(integer: index), with: .automatic)
	        case let .insert(index):
	            tableView.insertSections(IndexSet(integer: index), with: .automatic)
	        case let .error(error):
	            print(error)
	        }
	    }
	}
	```
	
	### To Do:

- [x] Implement generic `CoreDataController` that wraps `NSFetchedResultsController`
- [x] Implement `CoreDataStack` that assembles stack
- [ ] Unit Test `CoreDataController`
- [ ] Unit Test `CoreDataStack `