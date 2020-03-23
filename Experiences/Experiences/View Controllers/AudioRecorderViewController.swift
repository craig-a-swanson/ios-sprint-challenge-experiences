//
//  AudioRecorderViewController.swift
//  Experiences
//
//  Created by Craig Swanson on 3/22/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderViewController: UIViewController {
    
    var picture: Experience.Picture?
    var experienceTitle: String?
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var recordVideoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordAudioButton.layer.cornerRadius = 20
        recordVideoButton.isEnabled = false
    }
    
    @IBAction func startStopRecording(_ sender: UIButton) {
        
        if recordAudioButton.isSelected {
            recordAudioButton.isSelected = false
            stopRecording()
        } else {
            recordAudioButton.isSelected = true
            requestPermissionOrStartRecording()
        }
    }
    
    @IBAction func recordVideoButtonTapped(_ sender: UIButton) {
        guard recordingURL != nil else { return }
        performSegue(withIdentifier: "RecordVideoSegue", sender: self)
    }
    
    // MARK: - Methods for Recording
    func createAudioCommentURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        print("recording URL: \(file)")
        
        return file
    }
    
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("We need microphone access")
                    return
                }
                
                print("Recording permission has been granted!")
                self.startRecording()
            }
        case .denied:
            print("Microphone access has been blocked.")
            
            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }
    
    func startRecording() {
        do {
            try prepareAudioSession()
        } catch {
            print("Cannot record audio: \(error)")
            return
        }
        recordingURL = createAudioCommentURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, format: format)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            preconditionFailure("The audio recorder could not be created with \(recordingURL!) and \(format)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordVideoButton.isEnabled = true
    }
    
    // To use on a device. Boilerplate code
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordVideoSegue" {
            guard let videoVC = segue.destination as? VideoRecorderViewController else { return }
            
            guard let recordingURL = recordingURL else { return }
            let audioRecording = Experience.Audio(audioPost: recordingURL)
            videoVC.picture = picture
            videoVC.experienceTitle = experienceTitle
            videoVC.recordingURL = audioRecording
        }
     }
}

extension AudioRecorderViewController: AVAudioRecorderDelegate {
    
}
