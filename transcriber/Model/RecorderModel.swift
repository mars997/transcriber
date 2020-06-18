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
    var startTime = ""
    var recordedDuration = ""
    var recorderState = ""
    lazy var filename = getDirectory().appendingPathComponent("\(numberOfRecords).mp4")
    
    var records: Results<Record>?
    
    
    func loadRecords()
    {
        records = realm.objects(Record.self).sorted(byKeyPath: "id", ascending: false)
    }
    
    
    func getNow() -> String{

             let date = Date()
             let calender = Calendar.current
             let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)

             let year = components.year
             let month = components.month
             let day = components.day
             let hour = components.hour
             let minute = components.minute
             let second = components.second

             let now_string = String(year!) + "/" + String(month!) + "/" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)

             return now_string

         }

    
    
    
    func startStopPauseRecorder(_ button:String) -> (status: String, fileNane: String?) {
        
        
        
        if audioRecorder == nil // Recorder State is stopped
        {
            
            
            if button == RecorderK.recordButton
            {numberOfRecords += 1
            filename = getDirectory().appendingPathComponent("\(numberOfRecords).mp4")
            startTime = getNow()
                
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
                
            } else {
                return ("","")
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
                recordedDuration = audioRecorder.currentTime.stringFromTimeInterval()
                audioRecorder.stop()
                audioRecorder = nil
                recorderState = RecorderK.stopped //"Stopped"
                
                //here we have to record the info to Record Object Relam
                
                let newRecord = Record()
                newRecord.id = "\(numberOfRecords)"
                newRecord.user = "PlaceHolderUser"
                newRecord.startTime = startTime
                newRecord.url = " \(getDirectory().appendingPathComponent("\(numberOfRecords).mp4"))"
                newRecord.duration = recordedDuration
                
                save(newRecord)
                
                UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
                return (RecorderK.stopped,filename.absoluteString)
            }
        }
    }
    
    func save(_ record: Record)
    {
        do {
        try self.realm.write {
            self.realm.add(record)
            }
        }
        catch
        {  print ("Error Saving Record")
            
                }
            
        }
    
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let DocumentDirectory = paths[0]
        return DocumentDirectory
    }
    
}

extension TimeInterval{

    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)

        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds,ms)

    }
}
