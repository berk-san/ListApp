//
//  ViewController.swift
//  ListApp
//
//  Created by Berk on 22.09.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var data = [NSManagedObject]()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        // ViewController is tableView's delegate
        tableView.dataSource = self
        // ViewController is tableView's dataSource
        fetch()
    }
    
    @IBAction func didAddButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAddAlert()
    }
    
    @IBAction func didRemoveButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Warning", message: "Do you want to remove all items?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No", style: .cancel))
        ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            for item in self.data {
                managedObjectContext?.delete(item)
            }
            
            try? managedObjectContext?.save()
            
            self.fetch()
            
//            self.data.removeAll()
//            self.tableView.reloadData()
        }))
        
        present(ac, animated: true)
//
//        data.removeAll()
//        tableView.reloadData()
    }
    
    func presentAddAlert() {
        let ac = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            let text = ac.textFields?.first?.text
            if text != "" {
                // self.data.append(text ?? "New Item")
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                
                listItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save()
                
                self.tableView.reloadData()
                
                self.fetch()
            } else {
                self.presentWarningAlert()
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addTextField()
        
        present(ac, animated: true)
    }
    
    func presentWarningAlert() {
        let ac2 = UIAlertController(title: "Warning", message: "You can not add an empty item", preferredStyle: .alert)
        ac2.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac2, animated: true)
    }
    
    func fetch() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        // In order to connect ReusableCell on UI to our ViewController, we use the code above."
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            // self.data.remove(at: indexPath.row)
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
             
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            
            self.fetch()
            
            // tableView.reloadData()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in

            let ac = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
                let text = ac.textFields?.first?.text
                if text != "" {
                    // self.data[indexPath.row] = text!
                    // self.tableView.reloadData()
                    
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges {
                        try? managedObjectContext?.save()
                    }
                    
                    self.fetch()
                } else {
                    self.presentWarningAlert()
                }
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addTextField()
            
            self.present(ac, animated: true)
            
            tableView.reloadData()
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
        
    }
}

