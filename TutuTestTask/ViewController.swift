//
//  ViewController.swift
//  TutuTestTask
//
//  Created by Phlegma on 17.12.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: UserData.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    let tableView: UITableView = {
        let table = UITableView (frame: .zero, style: .plain)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? self.fetchedhResultController.performFetch()
        
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        APIService().getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.clearData()
                self.saveInCoreDataWith(array: data)
            case .Error(let message):
                print ("Error")
                print (message)
            }
        }
        
    }
    
    func clearEntity() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("Unable to delete stored data")
            print (error)
        }
    }
    
    func clearData() {
            do {
                let context = CoreDataManager.shared.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
                do {
                    let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                    _ = objects.map{$0.map{context.delete($0)}}
                    CoreDataManager.shared.saveContext()
                } catch let error {
                    print("ERROR DELETING : \(error)")
                }
            }
        }

    func createUserEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        if let userEntity = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: context) as? UserData {
            userEntity.id = dictionary["id"] as? NSNumber
            userEntity.username = dictionary["username"] as? String
            userEntity.email = dictionary["email"] as? String
            userEntity.website = dictionary["website"] as? String
            userEntity.phone = dictionary["phone"] as? String
            return userEntity
        }
        return nil
    }
    
    func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map { self.createUserEntityFrom(dictionary: $0) }
        do {
            try CoreDataManager.shared.persistentContainer.viewContext.save()
        } catch let error {
            print (error)
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = fetchedhResultController.fetchedObjects?[indexPath.row] as! UserData
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let detailsViewController = storyboard.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
    
        detailsViewController.user = user
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedhResultController.sections?.first?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let userData = fetchedhResultController.object(at: indexPath) as? UserData,
              let username = userData.username else {
            return cell
        }
        cell.textLabel?.text = username
        return cell
    }

}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
        
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
}
