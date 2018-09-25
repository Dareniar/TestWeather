//
//  CitiesTableViewController.swift
//  TestWeather
//
//  Created by Данил on 9/20/18.
//  Copyright © 2018 Dareniar. All rights reserved.
//

import UIKit
import CoreData

class CitiesTableViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var citiesTableView: UITableView!
    
    var selectedItem: IndexPath?
    
    var isSearching = false
    
    var results: [City]?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addView" {
            
            let destinationVC = segue.destination as! DetailWeatherViewController
            
            if !isSearching {
                
                let key = Helper.keys![selectedItem!.section]
                destinationVC.longitude = Helper.cityDictionary[key]![selectedItem!.row].longitude
                destinationVC.latitude = Helper.cityDictionary[key]![selectedItem!.row].latitude
                destinationVC.navigationItem.title = Helper.cityDictionary[key]![selectedItem!.row].name
                
            } else {
                print(results![selectedItem!.row])
                print(results![selectedItem!.row].longitude)
                destinationVC.longitude = results![selectedItem!.row].longitude
                destinationVC.latitude = results![selectedItem!.row].latitude
                destinationVC.navigationItem.title = results![selectedItem!.row].name
            }
            destinationVC.buttonSystemItem = UIBarButtonItem.SystemItem.add
        }
    }
}

//MARK: - Table View Conformation

extension CitiesTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !isSearching {
            return Helper.keys!.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !isSearching {
            return Helper.keys![section]
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isSearching {
            return Helper.cityDictionary[Helper.keys![section]]!.count
        } else {
            return results!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        
        if !isSearching {
                        
            cell.textLabel?.text = Helper.cityDictionary[Helper.keys![indexPath.section]]![indexPath.row].name
            
        } else {
            
            cell.textLabel?.text = results![indexPath.row].name
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedItem = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "addView", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 30)!
        header.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}

//MARK: - SearchBar Functionality

extension CitiesTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.isSearching = true
        
        let request: NSFetchRequest<City> = City.fetchRequest()
        
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if searchText == "" {
            self.isSearching = false
            DispatchQueue.main.async {
                self.searchBar.resignFirstResponder()
            }
        }
        
        do {
            results = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        self.citiesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
