//
//  AnalysisViewController.swift
//  SpirometerApp
//
//  Created by Varun Kumar Viswanth on 1/12/17.
//  Copyright © 2017 Varun Kumar Viswanth. All rights reserved.
//

import Foundation

import AVFoundation

import UIKit

import AudioKit


class AnalysisViewController: UIViewController {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showDataLabel: UILabel!
    
    var player:AKAudioPlayer?
    var plotView:AKView?
    var aFile = "dean-2-30-421.wav"
    var counter = 0
    
    override func didMove(toParentViewController parent: UIViewController?) {
        print("hello")
        if player == nil {
            //setupNodePlayer()
            //getfft()
//            setupAudioPlayer()
//            plotAudio()
            
            do {
                print(aFile)
                let file = try AKAudioFile(readFileName: aFile, baseDir: .documents)
                let rect = CGRect(x:0, y:0, width:500, height:200)
                player = try AKAudioPlayer(file: file)
                
                player?.looping = true
                var variSpeed = AKVariSpeed(player!)
                variSpeed.rate = 1
                AudioKit.output = variSpeed
                AudioKit.start()
                player?.play()
                //let plot = AKNodeFFTPlot.init(player!, frame: rect)
//                plot.fft(EZAudioFFT(), updatedWithFFTData: UnsafeMutablePointer<Float>(), bufferSize: vDSP_Length())
                plotAudio()
                //self.view.addSubview(plot)
            } catch {
                print("Failed to load  wav file to AKAudioFile")
            }

            //plotAudio()
            
        } else {
            if (player?.isPlaying)! {
                player?.stop()
                player = nil
                plotView?.removeFromSuperview()
                AudioKit.stop()
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.alpha = 0;
        
    }
    
    func plotAudio() {
        let frame = CGRect(x:0, y:100, width:440, height:200)
        let plot = AKRollingOutputPlot(frame: frame)
        
        plot.plotType = .rolling
        plot.backgroundColor = AKColor.white
        plot.color = AKColor.green
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.shouldCenterYAxis = true
        
        plotView = AKView(frame:frame)
        plotView?.addSubview(plot)
        self.view.addSubview(plotView!)
    }
    
    func getFft() {
        
    }
    
    @IBAction func analyzeButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        activityIndicator.alpha = 1;
        
        let urlsInDocumentsDirectory = getDocumentsDirectory()
        let filesInDocsDir = urlsInDocumentsDirectory.map{ $0.deletingPathExtension().lastPathComponent }
        
        var results = ""
        for file in filesInDocsDir {
            results = results + ", " + file
        }
        
        let url = urlsInDocumentsDirectory[0]
        let file = try! AVAudioFile(forReading: url)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: 1, interleaved: false)
        
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024)
        try! file.read(into: buf)
        
        // this makes a copy, you might not want that
        let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        
        print("floatArray \(floatArray)\n")
        showDataLabel.text = results
    }
    
    
    // This function gets the URL for the documents directory.
    func getDocumentsDirectory() -> [URL] {
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var results:[URL] = [documentsUrl]
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            //print(directoryContents)
            let wavFiles = directoryContents.filter{ $0.pathExtension == "wav" }
            results = wavFiles
            return results
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return results
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
