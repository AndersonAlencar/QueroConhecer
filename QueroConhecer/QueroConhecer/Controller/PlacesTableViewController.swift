//
//  PlacesTableViewController.swift
//  QueroConhecer
//
//  Created by Anderson Alencar on 17/07/19.
//  Copyright © 2019 Anderson Alencar. All rights reserved.
//

import UIKit

class PlacesTableViewController: UITableViewController {

    
    var places: [Place] = []
    let userDefaults = UserDefaults.standard
    var lbNoPlaces: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        lbNoPlaces = UILabel()
        lbNoPlaces.text = "Adicione novos locais para conhecer\npressionando o botão + acima"
        lbNoPlaces.textAlignment = .center
        lbNoPlaces.numberOfLines = 0
        
        loadPlaces()
    }
    
    func loadPlaces() {
        
        if let placesData = userDefaults.data(forKey: "places"){
            
            do{
                places = try JSONDecoder().decode([Place].self, from: placesData)
                tableView.reloadData()
            } catch{
                print(error.localizedDescription)
            }
            
        }
    }
    
    func savePlaces() {
        
        let jsonPlaces = try? JSONEncoder().encode(places)
        userDefaults.set(jsonPlaces, forKey: "places")
        
    }
    
    @objc func showAll() {
        performSegue(withIdentifier: "mapSegue", sender: nil)
    }
    
    
    @IBAction func showScreen(_ sender: Any) {
        performSegue(withIdentifier: "modalMap", sender: nil)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier != "mapSegue"{
            let viewControllerPlace  = segue.destination as! PlaceFinderViewController
            viewControllerPlace.delegate = self
        } else {
            let viewControllerMap = segue.destination as! MapViewController
            
            switch sender {
                case let place as Place:
                    viewControllerMap.places = [place]
                default:
                    viewControllerMap.places = places
            }
        }
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if places.count > 0 {
            let btShowAll = UIBarButtonItem(title: "Mostrar todos no mapa", style: .plain, target: self, action: #selector(showAll))
            navigationItem.leftBarButtonItem = btShowAll
            tableView.backgroundView = nil
        } else {
            navigationItem.leftBarButtonItem = nil
            tableView.backgroundView = lbNoPlaces
        }
        
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let place = places[indexPath.row]
        cell.textLabel?.text = place.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        performSegue(withIdentifier: "mapSegue", sender: place)
    }
    
    //Deleta as celulas celecionadas
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            savePlaces()
        }
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PlacesTableViewController: PlaceFinderDelegate {
   
    func addPlace(_ place: Place) {
        
        if !places.contains(place){
            places.append(place)
            savePlaces()
            tableView.reloadData()
        } else {
            
            let alert = UIAlertController(title: "", message: "Local já pertence a suas preferências", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
         
    }
    
    
}
