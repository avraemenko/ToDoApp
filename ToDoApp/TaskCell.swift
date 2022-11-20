//
//  TaskCell.swift
//  ToDoApp
//
//  Created by Kateryna Avramenko on 18.11.22.
//

import Foundation
import UIKit

protocol TaskCellDelegate: AnyObject {
    func didTapCheckButton(task : Task)
}

class TaskCell: UITableViewCell {
    
    weak var delegate: TaskCellDelegate?
    @IBOutlet  weak var didTaskButton: UIButton!
    @IBOutlet  weak var taskTitle: UILabel!
    var isCompleted = false
    public var task: Task?
   
    @IBAction func checkTheBox(_ sender: Any) {
        guard let task = self.task else { return }
        isCompleted.toggle()
        setCompletionImage(state: isCompleted)
        self.delegate?.didTapCheckButton(task: task)
    }
    
    public func configureTaskCell() {
        guard let task = self.task else { return }
        isCompleted = task.done
        taskTitle.text = task.title
        setCompletionImage(state: isCompleted)
    }
    
    public func setCompletionImage(state: Bool) {
        let completionImage = isCompleted ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.circle")
        didTaskButton.setImage(completionImage, for: .normal)
    }
    
    override func prepareForReuse() {
        self.backgroundColor = .clear
        self.accessoryType = .none
        didTaskButton.setImage(nil, for: .normal)
    }
    
}



