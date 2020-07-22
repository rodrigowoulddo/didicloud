//
//  CreateViewController.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import UIKit
import CloudKit
import didicloud

class CreateViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var saveActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    var todo: Todo?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fillFieldIfNeeded()
    }
    
    // MARK: - Configuration
    private func fillFieldIfNeeded() {
        
        guard let todo = self.todo else { return }
        
        nameTextField.text = todo.name
        descriptionTextField.text = todo.simpleDescription
        
    }
    
    // MARK: - Storage
    private func createTodo(name: String, description: String?) {
        
        let newTodo = Todo(name: name, simpleDescription: description)

        saveActivityIndicator.isHidden = false
        Storage.create(newTodo) {
            result in
            
            DispatchQueue.main.async {
                self.saveActivityIndicator.isHidden = true
            }
            
            switch result {
                
            case .failure(let error): self.showErrorAlert(error.localizedDescription)
            case .success(_):
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func updateTodo(_ todo: Todo, name: String, description: String?) {
        
        var todoToUpdate = todo
        todoToUpdate.name = name
        todoToUpdate.simpleDescription = description
        
        saveActivityIndicator.isHidden = false
        Storage.update(todoToUpdate) {
            result in
            
            DispatchQueue.main.async {
                self.saveActivityIndicator.isHidden = true
            }
            
            switch result {
                
            case .failure(let error): self.showErrorAlert(error.localizedDescription)
            case .success(_):
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func saveTodo() {
        
        guard let name = nameTextField.text,
            name.count > 0
            else {
                showErrorAlert("The todo must have a name")
                return
        }
        
        let description = descriptionTextField.text
                
        if let todo = todo {
            updateTodo(todo, name: name, description: description)
        }
        else {
            createTodo(name: name, description: description)
        }
    }
    
    
    
    // MARK: - Outlet Actons
    @IBAction func saveButtonAction(_ sender: Any) {
        saveTodo()
    }
}
