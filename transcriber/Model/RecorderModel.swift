//
//  RecorderModel.swift
//  transcriber
//
//  Created by Hamed Ansari on 5/30/20.
//  Copyright © 2020 exoptima. All rights reserved.
//

import AVKit
import AVFoundation
import RealmSwift


class RecorderModel:UIViewController,AVAudioRecorderDelegate
{
    let realm = try! Realm()
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    let audioBucketName = Constants.audioBucketName
    var numberOfRecords = 0
    
    
    
    func startStopRecorder() -> Bool {
        
        if audioRecorder == nil
        {
            numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).mp4")
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue]
            
            
            //start audio recording
            do{
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                return true
            }
            catch{
                return false
            }
        }
        else {
            //Stopping audio recording
            audioRecorder.stop()
            audioRecorder = nil
            
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            return true
        }
    }
    
    
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let DocumentDirectory = paths[0]
        return DocumentDirectory
    }
    
}


