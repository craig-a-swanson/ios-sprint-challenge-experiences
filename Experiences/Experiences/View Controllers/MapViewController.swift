//
//  MapViewController.swift
//  Experiences
//
//  Created by Craig Swanson on 3/22/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

class MapViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    private let regionInMeters: Double = 35000.0
    var experience: Experience? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var addImageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "ExperienceAnnotationView")
        requestCameraPermission()
        checkLocationServices()
    }

    @IBAction func addNewImage(_ sender: UIBarButtonItem) {
        
    }
    
        private func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        func currentUserLocation() -> CLLocationCoordinate2D {
            checkLocationServices()
            guard let currentLocation = locationManager.location?.coordinate else { return CLLocationCoordinate2D() }
            return currentLocation
        }
        private func checkLocationServices() {
            if CLLocationManager.locationServicesEnabled() {
                // setup our location manager
                setupLocationManager()
                checkLocationAuthorization()
            } else {
                print("Location services is turned off")
                // show alert letting the user know that have to turn it on
            }
        }
        
        private func centerViewOnUserLocation() {
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            }
        }
        
        private func checkLocationAuthorization() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                centerViewOnUserLocation()
                locationManager.startUpdatingLocation()
                break
            case .denied:
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                break
            case .authorizedAlways:
                break
            @unknown default:
                preconditionFailure("Future Apple case not covered by app")
            }
        }
    
    private func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:  // User's first use of the app
            requestVideoPermission() // request permission
        case .restricted:  // Parental controls, for instance, are preventing recording
            preconditionFailure("Video is disabled; please review device restrictions")
        case .denied:  // The user denied permission to use video
            preconditionFailure("You are not able to use the app without giving permission via Setting > Privacy > Video")
        case .authorized: break  // The user previously granted permission
            
        @unknown default: // A future new feature from apple that isn't handled now
            preconditionFailure("A new status code was added that we need to handle")
        }
    }
    
    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (isGranted) in
            guard isGranted else {
                preconditionFailure("UI: Tell the user to enable permissions for Video/Camera")
            }
        }
    }
    
    private func updateViews() {
        guard let experience = experience else { return }
        
        mapView.addAnnotation(experience)
    }
    }

    extension MapViewController: CLLocationManagerDelegate {

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkLocationAuthorization()
        }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageSelectionSegue" {
            guard let imageSelectionVC = segue.destination as? ImageSelectionViewController else { return }
            
            userLocation = currentUserLocation()
            imageSelectionVC.userLocation = userLocation
            
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let experience = annotation as? Experience else { return nil }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "ExperienceAnnotationView", for: experience) as? MKMarkerAnnotationView else {
            preconditionFailure("Missing the registered map annotation view")
        }
        return annotationView
    }
}
