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


class RecorderModel:NSObject,AVAudioRecorderDelegate
{
    let realm = try! Realm()
    var recordingSession:AVAudioSession! = AVAudioSession.sharedInstance()
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    let audioBucketName = K.audioBucketName
    var numberOfRecords = UserDefaults.standard.object(forKey: "myNumber") as? Int ?? 0
    
    var recorderState = ""
    
    func startStopPauseRecorder(_ button:String) -> (status: String, fileNane: String?) {
        
        let filename = getDirectory().appendingPathComponent("\(numberOfRecords).mp4")
        
        if audioRecorder == nil // Recorder State is stopped
        {

            numberOfRecords += 1
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue]
            
            
            //start audio recording
            do{
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                try recordingSession.setCategory(.playAndRecord)
                audioRecorder.record()
                recorderState = RecorderK.recording  //"Recording"
                return (RecorderK.recording, filename.absoluteString)
            }
            catch{
                recorderState = RecorderK.error  //"Crashed"
                return (RecorderK.error, filename.absoluteString)
            }
        }
        else {
            if button == RecorderK.pauseButton {
                if audioRecorder.isRecording {
                    audioRecorder.pause()
                    recorderState = RecorderK.paused //"Paused"
                    return (RecorderK.paused, filename.absoluteString)
                } else {
                    audioRecorder.record()
                    recorderState = RecorderK.recording //"Recording"
                    return (RecorderK.recording, filename.absoluteString)
                }
                
            } else {
                audioRecorder.stop()
                audioRecorder = nil
                recorderState = RecorderK.stopped //"Stopped"
                UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
                return (RecorderK.stopped,filename.absoluteString)
            }
        }
    }
    
    
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let DocumentDirectory = paths[0]
        return DocumentDirectory
    }
    
}
