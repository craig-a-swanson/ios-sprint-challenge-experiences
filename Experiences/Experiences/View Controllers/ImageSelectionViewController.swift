//
//  ImageSelectionViewController.swift
//  Experiences
//
//  Created by Craig Swanson on 3/22/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins
import MapKit

class ImageSelectionViewController: ShiftableViewController {
    
    var userLocation: CLLocationCoordinate2D?
    private let context = CIContext()
    private let exposureAdjustFilter = CIFilter.exposureAdjust()
    private var selectedImage: UIImage? {
        didSet {
            guard let selectedImage = selectedImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            let scaledUIImage = selectedImage.imageByScaling(toSize: scaledSize)
            guard let scaledCGImage = scaledUIImage?.cgImage else { return }
            
            scaledImage = CIImage(cgImage: scaledCGImage)
        }
    }
    
    private var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordAudioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordAudioButton.isEnabled = false
        titleTextField.delegate = self
    }
    
    @IBAction func selectImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
        @unknown default:
            preconditionFailure("The app does not handle this new case provided by Apple")
        }
        presentImagePickerController()
        
    }
    
    @IBAction func recordAudioTapped(_ sender: UIButton) {
        
        guard titleTextField.text != "" else { return }
        performSegue(withIdentifier: "RecordAudioSegue", sender: self)
    }
    
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(for: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func filterImage(for inputImage: CIImage) -> UIImage {
        
        exposureAdjustFilter.inputImage = inputImage
        exposureAdjustFilter.ev = Float(1.0)
        
        guard let outputImage = exposureAdjustFilter.outputImage else { return UIImage(ciImage: inputImage)}
        guard let renderedImage = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: UIImage(ciImage: inputImage).size)) else { return UIImage(ciImage: inputImage)}
        
        return UIImage(cgImage: renderedImage)
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
            func setImageViewHeight(with aspectRatio: CGFloat) {
                if 375 < imageView.frame.size.width {
                    imageHeightConstraint.constant = 375
                } else {
                imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
                }
                view.layoutSubviews()
            }
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordAudioSegue" {
            guard let audioRecordingVC = segue.destination as? AudioRecorderViewController else { return }
            
            guard let image = imageView.image else { return }
            let picture = Experience.Picture(imagePost: image)
            audioRecordingVC.experienceTitle = titleTextField.text
            audioRecordingVC.picture = picture
            audioRecordingVC.userLocation = userLocation
        }
     }
    
}

extension ImageSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        picker.dismiss(animated: true, completion: nil)
    
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        selectedImage = image
        recordAudioButton.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
