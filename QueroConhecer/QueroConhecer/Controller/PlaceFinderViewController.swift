//
//  PlaceFinderViewController.swift
//  QueroConhecer
//
//  Created by Anderson Alencar on 17/07/19.
//  Copyright © 2019 Anderson Alencar. All rights reserved.
//

import UIKit
import MapKit


protocol PlaceFinderDelegate: class{
    
    func addPlace(_ place: Place)
    
}

class PlaceFinderViewController: UIViewController {

    enum PlaceFinderMessageType {
        case error(String)
        case confirmation(String)
    }
    
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viLoading: UIView!
    
    var place: Place!
    
    weak var delegate: PlaceFinderDelegate? = nil
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viLoading.isHidden = true
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_:)))
        gestureRecognizer.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    

    @IBAction func findCity(_ sender: UIButton) {
        tfCity.resignFirstResponder()
        if let adress = tfCity.text{
            load(show: true)
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(adress) { (placemarks, error) in
                self.load(show: false)
                if error == nil {
                    if !self.savePlace(with: placemarks?.first){
                        self.showMessage(type: .error("Local não encontrado"))
                    }
                } else {
                    self.showMessage(type: .error("Erro Desconhecido"))
                }
            }
        }
    }
    

    @IBAction func close(_ sender: UIButton) {
        
        dismiss(animated: true
            , completion: nil)
    }
    
    @objc func getLocation(_ gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            
            load(show: true)
            
            let point = gesture.location(in: mapView) // captura a posiçao na tela
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView) // converte a posicao na tela pra o mapa
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                // fazer método para não repetir isso
                self.load(show: false)
                if error == nil {
                    if !self.savePlace(with: placemarks?.first){
                        self.showMessage(type: .error("Local não encontrado"))
                    }
                } else {
                    self.showMessage(type: .error("Erro Desconhecido"))
                }
                
            }
        }
        
        
    }
    
    func load(show: Bool)  {
        viLoading.isHidden = !show
        let _ = show ? aiLoading.startAnimating() : aiLoading.stopAnimating()
        
    }
    
    func savePlace(with placemark: CLPlacemark?) -> Bool {
        
        guard let placemark = placemark, let coordinate = placemark.location?.coordinate else {return false}
        
        let name = placemark.name ?? placemark.country ?? "Desconhecido"
        let address = Place.getFormattedAdress(with: placemark)
        place  = Place(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude, address: address)
        
        let region  = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3500, longitudinalMeters: 3500)
        mapView.setRegion(region, animated: true)
        
        
        self.showMessage(type: .confirmation("\(place.name)"))
        return true
        
        
    }
    
    func showMessage(type: PlaceFinderMessageType) {
        let title: String, message: String
        var hasConfirmation = false
        
        switch type {
        case .confirmation(let name):
            title = "Local Encontrado"
            message = "Deseja adiconar \(name)?"
            hasConfirmation = true
        case .error(let ErrorMessage):
            title = "Error"
            message = ErrorMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        if hasConfirmation{
            let confirmAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                self.dismiss(animated: true, completion: nil )
                self.delegate?.addPlace(self.place)
            }
            alert.addAction(confirmAction)
        }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
}
