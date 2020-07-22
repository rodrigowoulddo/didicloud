//
//  MasterViewController.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 28/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import UIKit
import didicloud
import CloudKit

class MasterViewController: UITableViewController {
    
    // MARK: - Outlets
    
    var todos: [Todo] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupRefresh()
        fetchTodos()
    }
    
    // MARK: - Refresh
    func setupRefresh() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshList), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    @objc func refreshList() {
        fetchTodos()
    }
    
    // MARK: - Storage
    
    private func fetchTodos() {
        
        Storage.getAll() {
            (result: Result<[Todo], Error>) in
            
            switch result {
                
            case.failure(let error):
                self.showErrorAlert(error.localizedDescription)
                
            case .success(let todos):
                self.todos = todos
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing() /// In case it has ben updated by a pull-refresh
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func completeTodo(withId id: String) {
        
        Storage.remove(id) {
            result in
            
            switch result {
                
            case.failure(let error):
                self.showErrorAlert(error.localizedDescription)
                self.fetchTodos()
                
            case .success(_):
                break
            }
        }
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let createVC = segue.destination as? CreateViewController else { return }
        
        if segue.identifier == "editTodo" {
            
            guard let todo = sender as? Todo else { return }
            createVC.todo = todo
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let todo = todos[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = todo.name
        cell.detailTextLabel?.text = todo.simpleDescription
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->   UISwipeActionsConfiguration? {
        
        
        let complete = UIContextualAction(style: .normal, title: "Complete", handler: {
            (action, view, completionHandler) in
            
            guard let id = self.todos[indexPath.row].recordName else { return }
            self.todos = self.todos.filter({ $0.recordName != id })
            
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.completeTodo(withId: id)
            
            completionHandler(true)
        })
        complete.backgroundColor = UIColor.systemGreen
        
        let edit = UIContextualAction(style: .normal, title: "Edit", handler: {
            (action, view, completionHandler) in
            
            self.performSegue(withIdentifier: "editTodo", sender: self.todos[indexPath.row])
            
            completionHandler(true)
        })
        edit.backgroundColor = UIColor.systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [complete, edit])
        return configuration
    }
    
}
