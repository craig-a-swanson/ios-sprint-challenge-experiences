//
//  ExperienceMapViewController.swift
//  Experiences
//
//  Created by Craig Swanson on 3/23/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

class ExperienceMapViewController: UIViewController {

    private let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    var myExperience: Experience? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        centerViewOnUserLocation()
        myExperience = setExperience()
        
    }
    
    func setExperience() -> Experience {
        let currentLocation = (locationManager.location?.coordinate)!
        let experienceTitle = "Dog"
        let picture = Experience.Picture(imagePost: UIImage(named: "recordVideo")!)
        let video = Experience.Video(videoPost: URL(string: "myURL")!)
        let audio = Experience.Audio(audioPost: URL(string: "myotherURL")!)
        
        let newExperience = Experience(experienceTitle: experienceTitle, geotag: currentLocation, picture: picture, video: video, audio: audio)
        
        return newExperience
    }
    
    func updateViews() {
        guard let myExperience = myExperience else { return }
        mapView.addAnnotation(myExperience)
    }
    
    private func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 25000, longitudinalMeters: 25000)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ExperienceMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 25000.0, longitudinalMeters: 25000.0)
        mapView.setRegion(region, animated: true)
    }
}
