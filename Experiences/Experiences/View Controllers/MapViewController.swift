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
import CoreLocation


// The app flow is to first get the user location from the map view;
// Then get the image from the image selection VC;
// Then get the audio from the audio recorder VC;
// Then get the video from the video recorder VC;
// In the video VC, it creates an Experience object with all of the properties;
// The Experience object is then passed back to the map view, which sets the annotation.

// Whenever I try to set any mapView methods, including addAnnotations, the app crashes.
// Printing values right before the crash shows that the experience object is fully loaded.
// It seems to have something to do with mapView -- I verified the delegate is set in storyboard.
// I'm not able to figure out where the problem is.  I even re-watched Dimitri's lesson and Paul Solt's as well.


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

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "ExperienceAnnotationView")
        requestCameraPermission()
        checkLocationServices()
    }

    @IBAction func addNewImage(_ sender: UIBarButtonItem) {
        
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {

        } else {
            print("Location services is turned off")
            // show alert letting the user know that have to turn it on
        }
    }
        
        func currentUserLocation() -> CLLocationCoordinate2D {
            checkLocationServices()
            guard let currentLocation = locationManager.location?.coordinate else { return CLLocationCoordinate2D() }
            return currentLocation
        }
        
        private func centerViewOnUserLocation() {
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
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
        
        let region = MKCoordinateRegion(center: experience.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(experience)
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

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let experience = annotation as? Experience else { return nil }
//
//        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "ExperienceAnnotationView", for: experience) as? MKMarkerAnnotationView else {
//            preconditionFailure("Missing the registered map annotation view")
//        }
//        return annotationView
//    }
}
