//
//  PlaceAnnotation.swift
//  QueroConhecer
//
//  Created by Anderson Alencar on 02/08/19.
//  Copyright © 2019 Anderson Alencar. All rights reserved.
//

import Foundation
import MapKit


class PlaceAnnotation: NSObject, MKAnnotation {
   
    enum PlaceType {
        case place
        case pointInterest
    }
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: PlaceType
    var adress: String?
    
    init(coordinate: CLLocationCoordinate2D, type: PlaceType) {
        
        self.coordinate = coordinate
        self.type = type
    }
    
    
    
}
