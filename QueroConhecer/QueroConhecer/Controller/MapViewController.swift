//
//  MapViewController.swift
//  QueroConhecer
//
//  Created by Anderson Alencar on 17/07/19.
//  Copyright © 2019 Anderson Alencar. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    enum MapMessageType {
        case routeError
        case authorizationWarning
        
    }
    
    
    @IBOutlet weak var viBackground: UIView!
    @IBOutlet weak var btSearch: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAdress: UILabel!
    
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    
    var places: [Place]!
    var pointsInterest: [MKAnnotation] = []
    var btUserLocation: MKUserTrackingButton!
    
    lazy var locationManager = CLLocationManager()
    
    var selectedAnnotation: PlaceAnnotation?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        searchBar.delegate = self
        locationManager.delegate = self
        
        mapView.mapType = .mutedStandard
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.viBackground.backgroundColor = UIColor(red:0.00, green:0.72, blue:0.89, alpha:1.0)
        self.searchBar.tintColor = UIColor(red:0.00, green:0.72, blue:0.89, alpha:1.0)
        self.searchBar.barTintColor = UIColor(red:0.00, green:0.72, blue:0.89, alpha:1.0)
        self.searchBar.isHidden = true
        self.viInfo.isHidden = true
        
        navigationItem.title = places.count == 1 ?  "\(places[0].name)" : "Meus lugares"
        
        configureLocationbutton()
        addToMap()
        requestUserLocationAutorization()
        // Do any additional setup after loading the view.
    }
    
    func addToMap() {
        for place in places {
            // let annotation = MKAnnotation() -> Antes usávamos uma class anotation pronta, porém fizemos nossa própria classe anotation chamada PlaceAnnotation. 
            let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
            annotation.title = place.name
            annotation.adress = place.address
            mapView.addAnnotation(annotation )
        }
        showPlaces()
        
    }
    
    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func configureLocationbutton() {
        btUserLocation = MKUserTrackingButton(mapView: mapView)
        btUserLocation.backgroundColor = .white
        btUserLocation.frame.origin.x = 10
        btUserLocation.frame.origin.y = 10
        btUserLocation.layer.cornerRadius = 5
        btUserLocation.layer.borderWidth = 1
        btUserLocation.layer.borderColor = UIColor(named: "Main")?.cgColor
    }
    
    
    func requestUserLocationAutorization() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    mapView.addSubview(btUserLocation)
                case .denied:
                    showMessage(type: .authorizationWarning)
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization() // Usuário ainda não visualizou a permição do acesso
                case .restricted: // utilizar quando ao app nao aceita o uso: por exemplo bloqueio de GPS via controle parental
                    break // por hora nao implementar
                
                
            @unknown default:
                break
            }
        } else {
            // negar acesso, nao vamos trabalhar nisso agira
        }
    }
    
    func showInfo() {
        lbName.text = selectedAnnotation?.title
        lbAdress.text = selectedAnnotation?.adress
        viInfo.isHidden = false
        
    }
    
    func showMessage(type: MapMessageType) {
        let title = type == .authorizationWarning ? "Aviso" : "Erro"
        let message = type == .authorizationWarning ? "Para usar os recursos de localclização do App, você precisa permitir o uso da tela de ajustes" : "Não foi possível encontrar esta rota"
        

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if type == .authorizationWarning{
            let confirmAction = UIAlertAction(title: "Ir para ajustes", style: .default) { (alertAction) in
                
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil) // levando o usuário para a tela de ajustes
                }
            }
            alert.addAction(confirmAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func showRoute(_ sender: UIButton) {
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            showMessage(type: .authorizationWarning)
            return
        }
        
        let request = MKDirections.Request()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: selectedAnnotation!.coordinate))
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if error == nil {
                if let  response = response {
                    self.mapView.removeOverlays(self.mapView.overlays)
                    
                    let route = response.routes.first!
                    print("Nome: \(route.name), Distancia: \(route.distance), Duração: \(route.expectedTravelTime)")
                    print("============================")
                    for step in route.steps {
                        print("Em \(route.distance) metro(s), \(step.instructions)")
                    }
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    var annotations = self.mapView.annotations.filter({!($0 is PlaceAnnotation)})
                    annotations.append(self.selectedAnnotation!)
                    print("O numro de ann é: \(annotations.count)")
                    self.mapView.showAnnotations(annotations, animated: true)
                    print("Adicinou essa merda")
                }
            } else {
                self.showMessage(type: .routeError)
            }
        }
    }
    

    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is PlaceAnnotation){
            return nil
        }
        
        let type = (annotation as! PlaceAnnotation).type
        let identifier = "\(type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.annotation = annotation
        annotationView?.canShowCallout =  true // mostrar algum balão de mensagem ao clicar em cima
        annotationView?.markerTintColor = type == .place ? UIColor(named: "ColorMain") : UIColor(named: "ColorPointInterest")
        annotationView?.glyphImage = type == .place ? UIImage(named: "placeGlyph") : UIImage(named: "poiGlyph")
        annotationView?.displayPriority = type == .place ? .required : .defaultHigh
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let camera  = MKMapCamera()
        camera.centerCoordinate = view.annotation!.coordinate
        camera.pitch = 80
        camera.altitude = 100
        mapView.setCamera(camera, animated: true)
        
        selectedAnnotation = (view.annotation as! PlaceAnnotation)
        showInfo()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .black //UIColor(named: "main")?.withAlphaComponent(0.8)
            renderer.lineWidth = 5.0
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        aiLoading.startAnimating()
        
        let request  = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request) // executa a requisição
        search.start { (response, error) in
            
            if error == nil{
                guard response != nil else {
                    self.aiLoading.stopAnimating()
                    return}
            }
            self.mapView.removeAnnotations(self.pointsInterest)
            self.pointsInterest.removeAll()
            for item in response!.mapItems {
                let annotation = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .pointInterest)
                annotation.title = item.name
                annotation.subtitle = item.phoneNumber
                annotation.adress = Place.getFormattedAdress(with: item.placemark)
                self.pointsInterest.append(annotation)
                self.mapView.addAnnotations(self.pointsInterest)
                self.mapView.showAnnotations(self.pointsInterest, animated: true)
            }
        }
        aiLoading.stopAnimating()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            mapView.addSubview(btUserLocation)
        locationManager.startUpdatingLocation() // monitora a localizaçao do usuário
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if let location = locations.last { // mostrar que é posssível monitorar vários aspectos do usuário pela localização
            //print("Velocidade: \(location.speed)")
            //let region = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: 500,longitudinalMeters: 500)
            //mapView.setRegion(region, animated: true)
        //}
    }
}
