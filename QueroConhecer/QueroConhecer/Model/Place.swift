//
//  Place.swift
//  QueroConhecer
//
//  Created by Anderson Alencar on 21/07/19.
//  Copyright © 2019 Anderson Alencar. All rights reserved.
//

import Foundation
import MapKit
// import CoreLocation MapKkit j;a importa essa biblioteca


struct Place: Codable {
    
    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let address: String
    
    var  coordinate: CLLocationCoordinate2D   {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func getFormattedAdress(with placemark: CLPlacemark) -> String {
        
        var address = ""
        if let street = placemark.thoroughfare { // nome da rua
            address += street
        }
        if let  number = placemark.subThoroughfare {
            address += " \(number)"
        }
        if let subLocality = placemark.subLocality { // bairro
            address += ", \(subLocality)"
        }
        if let city = placemark.locality {
            address += "\n\(city)"
        }
        if let state = placemark.administrativeArea {
            address += " - \(state)"
        }
        if let postalCode = placemark.postalCode { // cep
            address += "\n CEP: \(postalCode)"
        }
        if let country = placemark.country {
            address += "\n\(country)"
        }
        
        return address
    }
    
    
}

extension Place: Equatable {

    static func ==(lhs: Place, rhs: Place) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
