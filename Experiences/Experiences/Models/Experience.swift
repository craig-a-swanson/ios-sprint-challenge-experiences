//
//  Experience.swift
//  Experiences
//
//  Created by Craig Swanson on 3/22/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
import MapKit

class Experience: NSObject {
    
    var experienceTitle: String
    var geotag: CLLocationCoordinate2D
    var picture: Picture
    var video: Video
    var audio: Audio
    
    init(experienceTitle: String, geotag: CLLocationCoordinate2D, picture: Picture, video: Video, audio: Audio) {
        self.experienceTitle = experienceTitle
        self.geotag = geotag
        self.picture = picture
        self.video = video
        self.audio = audio
    }
    
    
    struct Picture {
        var imagePost: UIImage
        
        init(imagePost: UIImage) {
            self.imagePost = imagePost
        }
    }
    
    struct Video {
        
    }
    
    struct Audio {
        var audioPost: URL
        
        init(audioPost: URL) {
            self.audioPost = audioPost
        }
    }
}
