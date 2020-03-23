//
//  Experience+ MKAnnotation.swift
//  Experiences
//
//  Created by Craig Swanson on 3/22/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
import  MapKit

extension Experience: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        return geotag
    }
    
    var title: String? {
        experienceTitle
    }
}
