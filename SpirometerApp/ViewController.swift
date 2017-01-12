//
//  ViewController.swift
//  SpirometerApp
//
//  Created by Varun Kumar Viswanth on 1/10/17.
//  Copyright © 2017 Varun Kumar Viswanth. All rights reserved.
//

import UIKit
//import Surge
import AVFoundation


class ViewController: UIViewController, AVAudioRecorderDelegate {

    let filenameSuffix = ".wav"
    
    var player = AVAudioPlayer()

    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var currentFileName = ""
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var trialTextField: UITextField!
    
    @IBOutlet weak var distanceTextField: UITextField!
    
    @IBOutlet weak var fev1TextField: UITextField!
    
    
    @IBOutlet weak var playSoundButton: UIButton!
    @IBAction func playSoundButtonPressed(_ sender: Any) {
//        let audioFile = "recording"
//        let audioFileType = "m4a"
//        
//        let audioPath = Bundle.main.path(forResource: audioFile, ofType: audioFileType)
//        //print("audio path: " + audioPath!)
//        do {
//            
//            let url = URL(fileURLWithPath: audioPath!)
//            player = try AVAudioPlayer(contentsOf: url)
//            
//        } catch {
//            print("Setting player with audioPath failed")
//        }
        player.play()
    }
    
    
    @IBAction func playRecordedSoundButtonPressed(_ sender: Any) {
        
//        recordingSession.setCategory(AVAudioSessionCategoryPlayback)
//        recordingSession.setActive(true)
//        
        let previousFilename = UserDefaults.standard.object(forKey: "lastRecording") as! String
        if let url = getDocumentsDirectory().appendingPathComponent(previousFilename) as? URL {
            do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player.play()
                } catch {
                    print("Setting player with audioPath failed 2 ")
                    
                    print(url.absoluteString)
                    
                    
                    
                }
        } else {
            print(UserDefaults.standard.object(forKey: "test")!)
        }
        
        
    }
    
    // This function creates a UIButton that controls starting and stopping recording
    func loadRecordingUI() {
        let x = self.view.center.x
        let y = self.view.center.y
        recordButton = UIButton(frame: CGRect(x: x-150, y: y + 68, width: 300, height: 64))
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.backgroundColor = UIColor.blue
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    func recordTapped() {
        if audioRecorder == nil {
            print("record tapped -> start recording")
            startRecording()
        } else {
            print("record tapped -> finish recording")
            finishRecording(success: true)
        }
    }
    
    // This function starts the Recording with the specified settings for the sample rate, audio format, number of channels, and audio quality, as well as the designated audio file.
    func startRecording() {
        print("start recording")
        //let audioFilename = Bundle.main.bundlePath.appending("/recording1.m4a")
        currentFileName = "\(nameTextField.text!.replacingOccurrences(of: " ", with: ""))-\(trialTextField.text!.replacingOccurrences(of: " ", with: ""))-\(distanceTextField.text!.replacingOccurrences(of: " ", with: ""))-\(fev1TextField.text!.replacingOccurrences(of: " ", with: ""))\(filenameSuffix)"
        print(currentFileName)
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(currentFileName)
        print(audioFileURL.absoluteString)
        //UserDefaults.standard.set(currentFileName, forKey: "lastRecording")
        //print("file name: " + audioFileURL.absoluteString)
        //let audioFileURL = URL(fileURLWithPath: audioFilename)
        
//        let settings: [String : AnyObject] = [
//        
//            AVFormatIDKey:Int(kAudioFormatLinearPCM),
//
//            AVSampleRateKey:44100.0,
//        
//            AVNumberOfChannelsKey:1,
//        
//            AVLinearPCMBitDepthKey:8,
//        
//            AVLinearPCMIsFloatKey:false,
//            AVLinearPCMIsBigEndianKey:false,
//            AVEncoderAudioQualityKey:AVAudioQuality.Max.rawValue
//        
//        ]

        let settings:[String : NSNumber] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM) as NSNumber,
            //AVFormatIDKey: kAudioFormatAppleLossless as NSNumber,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue as NSNumber
        ]
            
        do {
            print("in Do catch, not recording")
            
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            
            audioRecorder.delegate = self
            audioRecorder.record()
            print("in do catch, recording")
            recordButton.setTitle("Tap to Stop", for: .normal)
            recordButton.backgroundColor = UIColor.red
            
        } catch let error as NSError {
            print("caught")
            print(error)
            finishRecording(success: false)
        }
    }

    // This function gets the URL for the documents directory.
    // URL is created in startRecording() for bundlepath
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("paths: " + paths[0].relativeString)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // Stops recording
    func finishRecording(success: Bool) {
        if (audioRecorder == nil) {
            print("finished recording but audioRecorder is nil")
        } else {
        audioRecorder.stop()
        print(audioRecorder.url.absoluteString)
        UserDefaults.standard.set(audioRecorder.url.absoluteString, forKey: "test")
        
       audioRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            recordButton.backgroundColor = UIColor.blue
            
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            recordButton.backgroundColor = UIColor.blue
            // recording failed :(
            print("recording faild")
        }
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // This section is where we play a sound from a specified file
        playSoundButton.alpha = 0
        let audioFile = "breath-gasp-01"
        let audioFileType = "wav"
        
        let audioPath = Bundle.main.path(forResource: audioFile, ofType: audioFileType)
        print("audio path: " + audioPath!)
        do {
            
            let url = URL(fileURLWithPath: audioPath!)
            player = try AVAudioPlayer(contentsOf: url)
            
        } catch {
            print("Setting player with audioPath failed")
        }
        
        
        // This section is where we record sound from the mic
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        print("failed to record")
                    }
                }
            }
        } catch {
            print("failed to record")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

