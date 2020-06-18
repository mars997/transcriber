//
//  ViewController.swift
//  transcriber
//
//  Created by Hamed Ansari on 5/12/20.
//  Copyright © 2020 exoptima. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AWSCognito
import AWSS3
import RealmSwift

class ViewController: UIViewController,RecordCellDelegate, AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource {
    
    
    
    var recordingSession:AVAudioSession!
    //    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    let awsAudioBucketName = K.audioBucketName
    let recorderModel = RecorderModel()
    var numberOfRecords = 0
    var currentlyLitPlayButton:UIButton?
    var playTimer:Timer?
    var recordTimer:Timer?
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    
    
    func titleFieldChanged(id: Int, sender: Any) {
        let recorderModel = RecorderModel()
        recorderModel.loadRecords(id: String(id))
        let titleField = (sender as! UITextField)
        recorderModel.updateTitle(titleField.text!)
        
    }
    
    
    
    
    
    
    
    
    func playButtonPressed(id: Int,sender: Any) {
        do
        {
            if let prevPlayButton = currentlyLitPlayButton
            {
                prevPlayButton.setImage(UIImage(systemName:"play"), for: .normal)
                if prevPlayButton == (sender as! UIButton) && audioPlayer.isPlaying
                {
                    audioPlayer.stop()
                    return
                }
            }
            
            let path =  getDirectory().appendingPathComponent("\(id).mp4" )
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
            (sender as! UIButton).setImage(UIImage(systemName:"play.fill"), for: .normal)
            currentlyLitPlayButton = (sender as! UIButton)
            playTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkIfPlaying), userInfo: nil, repeats: true)
            
        }
        catch{
            
        }
    }
    
    
    
    func transcribeButtonPressed(id: Int,sender: Any) {
        uploadFile(with: ("\(id).mp4"))
        
    }
    
    
    @IBAction func pausePressed(_ sender: Any) {
        let (status, _) = recorderModel.startStopPauseRecorder(RecorderK.pauseButton)
        
        if status == RecorderK.paused {
            tableView.isUserInteractionEnabled = true //When recording is not in progress users can interact with the table of records
            pauseButton.setBackgroundImage(UIImage(systemName: "mic.circle"), for: UIControl.State.normal)
        } else if status == RecorderK.recording {
            tableView.isUserInteractionEnabled = false //when recording users cannot play recorded audio
            pauseButton.setBackgroundImage(UIImage(systemName: "pause.circle"), for: UIControl.State.normal)
            
        }
        
    }
    
    @IBAction func recordPressed(_ sender: Any) {
        
        let (status, _) = recorderModel.startStopPauseRecorder(RecorderK.recordButton)
        tableView.reloadData()
        if status == RecorderK.stopped {
            tableView.isUserInteractionEnabled = true //When recording is not in progress users can interact with the table of records
            recordButton.setBackgroundImage(UIImage(systemName: "mic"), for: UIControl.State.normal)
            pauseButton.setBackgroundImage(UIImage(systemName: "pause.circle"), for: UIControl.State.normal)
            recordTimer?.invalidate()
            durationLabel.text = "00:00:00"
        } else if status == RecorderK.recording {
            tableView.isUserInteractionEnabled = false  //when recording users cannot play recorded audio
            recordButton.setBackgroundImage(UIImage(systemName: "stop"), for: UIControl.State.normal)
            
            recordTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.rowHeight = 60
        
        recorderModel.loadRecords()
        
        tableView.register(UINib(nibName:"RecordCell", bundle: nil), forCellReuseIdentifier: "ReusableRecordCell")
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission
            {print ("Accepted")}
        }
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast2,
                                                                identityPoolId:K.identityPoolId)
        
        let configuration = AWSServiceConfiguration(region:.USEast2, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    
    
    
    
    
    //Function that displays an alert
    //    func displayAlert(title:String, message:String)
    //    {
    //        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
    //        alert.addAction(UIAlertAction(title:"Dismiss", style:.default, handler:nil))
    //        present(alert, animated: true,completion:nil)
    //    }
    
    
    // MARK: Table View Settings
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        
        
        return recorderModel.records?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableRecordCell", for: indexPath) as! RecordCell
        cell.titleText.text =
            String(recorderModel.records?[indexPath.row].title ?? "No Title")
        
        cell.dateLabel.text = String(recorderModel.records?[indexPath.row].startTime ?? "No Date")
        
        cell.durationLabel.text = String(recorderModel.records?[indexPath.row].duration ?? "No Duration")
        
        cell.playButton.tag = Int((recorderModel.records?[indexPath.row].id)!) ?? 0
        cell.transcribeButton.tag = Int((recorderModel.records?[indexPath.row].id)!) ?? 0
        
        cell.titleText.tag = Int((recorderModel.records?[indexPath.row].id)!) ?? 0
        
        cell.cellDelegate = self
        //      cell.id = Int((recorderModel.records?[indexPath.row].id)!)
        
        return cell
    }
    
    
    
    // MARK: Helper Functions
    //Function that gets path to directory
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let DocumentDirectory = paths[0]
        return DocumentDirectory
    }
    
    @objc func updateTimer() {
        if let duration = recorderModel.audioRecorder?.currentTime.stringFromTimeInterval()
        {self.durationLabel.text = duration
            print(duration)}
    }
    
    //MARK: Upload Audio File to AWS
    func uploadFile(with key: String) {
        let localFileUrl = getDirectory().appendingPathComponent(key)
        let request = AWSS3TransferManagerUploadRequest()!
        request.bucket = awsAudioBucketName
        request.key = key
        request.body = localFileUrl
        request.acl = .publicReadWrite
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let error = task.error {
                print(error)
            }
            if task.result != nil {
                print("uploaded \(key)")
            }
            return nil
        }
    }
    
    
    @objc func checkIfPlaying() {
        if !audioPlayer.isPlaying {
            currentlyLitPlayButton!.setImage(UIImage(systemName:"play"), for: .normal)
            playTimer?.invalidate()
        }
    }
    
    
}

