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

class ViewController: UIViewController, AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    let awsAudioBucketName = K.audioBucketName
    
    
    let recorderModel = RecorderModel()
    

    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    var numberOfRecords = 0
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBAction func pausePressed(_ sender: Any) {
        let (status, urlString) = recorderModel.startStopPauseRecorder(RecorderK.pauseButton)
        
        if status == RecorderK.paused {
                        pauseButton.setBackgroundImage(UIImage(systemName: "mic.circle"), for: UIControl.State.normal)
        } else if status == RecorderK.recording {
            
            pauseButton.setBackgroundImage(UIImage(systemName: "pause.circle"), for: UIControl.State.normal)
            
        }

    }
    
    
    
    
    @IBAction func recordPressed(_ sender: Any) {
        
        let (status, urlString) = recorderModel.startStopPauseRecorder(RecorderK.recordButton)
        
        
        tableView.reloadData()
        
        if status == RecorderK.stopped {
                        recordButton.setBackgroundImage(UIImage(systemName: "mic"), for: UIControl.State.normal)
                        pauseButton.setBackgroundImage(UIImage(systemName: "pause.circle"), for: UIControl.State.normal)
        } else if status == RecorderK.recording {
            
            recordButton.setBackgroundImage(UIImage(systemName: "stop"), for: UIControl.State.normal)
            
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            
        }
    }
    
    @objc func updateTimer() {
        if let duration = recorderModel.audioRecorder?.currentTime.stringFromTimeInterval()
        {self.durationLabel.text = duration
            print(duration)}
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 60
        
//        navigationController?.navigationBar.barTintColor = UIColor.init(red: 185.0/255.0, green: 215.0/255.0, blue: 234.0/255.0, alpha: 1)
        
        
 //       navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Buy Credit", style: .plain, target: self, action: #selector(addTapped))
 //       navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(addTapped))
        
        
        
        
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

    
    //Function that gets path to directory
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let DocumentDirectory = paths[0]
        return DocumentDirectory
    }
    
    //Function that displays an alert
    func displayAlert(title:String, message:String)
    {
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss", style:.default, handler:nil))
        present(alert, animated: true,completion:nil)
    }
    //Setting up TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return recorderModel.numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableRecordCell", for: indexPath) as! RecordCell
        cell.titleText.text = String(indexPath.row + 1)

        //cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).mp4")
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
       //     uploadFile(with: ("\(indexPath.row + 1).mp4"))
        }
        catch{
            
        }
    }
}

