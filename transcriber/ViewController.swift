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
import AWSAuthUI
import AWSAuthCore

class ViewController: UIViewController, AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource {
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    let bucketName = "raw-audio-to-transcribe"
    @IBOutlet weak var buttonLabel: UIButton!
    
    @IBOutlet weak var myTableView: UITableView!
    var numberOfRecords = 0
    @IBAction func record(_ sender: Any) {
        //Check if we have an active recorder
        if audioRecorder == nil
        {
            numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).mp4")
        
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 16000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue]
            
            
            //start audio recording
            do{
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                buttonLabel.setTitle("Stop Recording", for: .normal)
                }
            catch{
                displayAlert(title: "Oops!", message: "Recording failed!")
            }
        }
        else {
            //Stopping audio recording
            audioRecorder.stop()
            audioRecorder = nil
            
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            myTableView.reloadData()
            
            buttonLabel.setTitle("Start Recording", for: .normal)
        }
        
    }
    
    
    func showSignIn() {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            AWSAuthUIViewController
                .presentViewController(with: self.navigationController!,
                           configuration: nil,
                           completionHandler: {(provider: AWSSignInProvider, error: Error?) in
                    if error != nil {
                        print("Error occured: \(String(describing: error))")
                    } else {
                        print("Logged in with provider: \(provider.identityProviderName) with Token: \(provider.token())")
                    }
                })
        }
    }
      
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        showSignIn() 
        
        //Setting up session
        
        recordingSession = AVAudioSession.sharedInstance()
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int
        {
            numberOfRecords = number
        }
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission
            {print ("Accepted")}
        }
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast2,
            identityPoolId:"us-east-2:ec9eff09-1d4e-47b8-80ef-bdc6146b8a18")

         let configuration = AWSServiceConfiguration(region:.USEast2, credentialsProvider:credentialsProvider)
        
         AWSServiceManager.default().defaultServiceConfiguration = configuration
         
         
        
    }
    
    
    func uploadFile(with key: String) {
        let localFileUrl = getDirectory().appendingPathComponent(key)
        let request = AWSS3TransferManagerUploadRequest()!
        request.bucket = bucketName
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
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).mp4")
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
            uploadFile(with: ("\(indexPath.row + 1).mp4"))
        }
        catch{
            
        }
    }
}

