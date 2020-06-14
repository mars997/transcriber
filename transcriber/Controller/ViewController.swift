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
    
    @IBOutlet weak var buttonLabel: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    var numberOfRecords = 0
    
    
    @IBAction func pausePressed(_ sender: Any) {
        recorderModel.startStopPauseRecorder(RecorderK.pauseButton)
        pauseButton.title(for: UIControl.State.normal) == "Pause" ? pauseButton.setTitle("Resume", for: UIControl.State.normal) : pauseButton.setTitle("Pause", for: UIControl.State.normal)
    }
    
    
    
    
    @IBAction func recordPressed(_ sender: Any) {
        
        let (status, urlString) = recorderModel.startStopPauseRecorder(RecorderK.recordButton)
        tableView.reloadData()
        
        if status == RecorderK.stopped {
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 60
        
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

