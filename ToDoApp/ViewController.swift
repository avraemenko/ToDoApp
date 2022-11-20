//
//  ViewController.swift
//  ToDoApp
//
//  Created by Kateryna Avramenko on 18.11.22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoApp")
        container.loadPersistentStores { _, _ in
            
        }
        return container
    }()
    
    var context: NSManagedObjectContext { container.viewContext }

    private var tasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ToDo List"
        getAllTasks()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New task", message: "Enter a new task", preferredStyle: .alert)
      
       
        alert.addTextField { (textField) in
           
            textField.placeholder = "New task"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Note"
        }
        
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            guard let note = alert.textFields?.last, let note = note.text else {
                return
            }
            
            self?.createTask(title: text, note: note)
        }))
        present(alert, animated: true)
    }

}

// MARK: - TaskCellDelegate
extension ViewController: TaskCellDelegate {
    func didTapCheckButton(task : Task) {
        completeTheTask(task: task)
    }
}

// MARK: - Table View
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskCell
        if indexPath.row == 0 {
            cell.task = task
            if task.supertask == nil {
                cell.accessoryType = .detailDisclosureButton
            }
        } else {
            cell.task = task.subs[indexPath.row - 1]
            cell.backgroundColor = .systemMint
        }
        
        cell.configureTaskCell()
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let task = tasks[section]
        if task.isOpened {
            return task.subs.count + 1
        } else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.filter { $0.supertask == nil }.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasks[indexPath.section].isOpened.toggle()
        tableView.reloadSections([indexPath.section], with: .fade)
    }
 
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        let task = tasks[indexPath.section]
       
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Show notes", style: .default, handler: { _ in
            let alert = UIAlertController(title: task.title, message: task.note, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newNote = field.text else { return }
                self?.updateTask(task: task, newNote: newNote)
            }))
            self.present(alert, animated: true)
        }))
        
        sheet.addAction(UIAlertAction(title: "Edit note", style: .default, handler: { _ in
            let alert = UIAlertController(title: task.title, message: "Edit task note", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = task.note
                    }
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newNote = field.text else { return }
                self?.updateTask(task: task, newNote: newNote)
            }))
            self.present(alert, animated: true)
        }))
        
        sheet.addAction(UIAlertAction(title: "Add subtask", style: .default, handler: { _ in
            let alert = UIAlertController(title: task.title, message: "Add subtask", preferredStyle: .alert)
            alert.addTextField()
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let sself = self else { return }
                guard let field = alert.textFields?.first, let subtaskTitle = field.text else { return }
                let subtask = Task(context: sself.context)
                subtask.title = subtaskTitle
                subtask.supertask = sself.tasks[indexPath.section]
                sself.tasks[indexPath.section].addToSubtasks(subtask)
                
                try? sself.context.save()
                sself.getAllTasks()
            }))
            self.present(alert, animated: true)
        }))
        
        
        present(sheet, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        self.deleteTask(task: task)
    }
}

// MARK: - Core Data Service
extension ViewController {
    
    func completeTheTask(task : Task){
        task.done.toggle()
        do {
           try context.save()
            getAllTasks()
        }
        catch {}
    }

    func getAllTasks() {
        do {
            tasks = try context.fetch(Task.fetchRequest())
                .filter { $0.supertask == nil }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            //error
        }
    }
    
    func createTask(title: String, note : String?) {
        let newTask = Task(context: context)
        newTask.dateOfCreation = Date()
        newTask.title = title
        newTask.note = note
        do {
            try context.save()
            getAllTasks()
        }
        catch {
            //error
        }
    }
    
    func deleteTask(task: Task) {
        context.delete(task)
        task.subs.forEach { sub in
            context.delete(sub)
        }
        
        do {
           try context.save()
            getAllTasks()
        }
        catch {}
    }
    
    func updateTask(task: Task, newNote : String) {
        task.note = newNote
        
        do {
           try context.save()
            getAllTasks()
        }
        catch {}
    }
}

