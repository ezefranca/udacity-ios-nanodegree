//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Ezequiel Franças on 4/11/16.
//  Copyright © 2016 Ezequiel França. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingStatusLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        stopRecordingButton.enabled = false
        recordButton.enabled=true
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        print("Stop Recording")
        setRecordButtonStatus("Tap to Record", enableStop: false, enableRecord: true)
        //stop recording
        audioRecorder.stop()
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        
        setRecordButtonStatus("Recording in progress", enableStop: true, enableRecord: false)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegueWithIdentifier("recordingDoneSegue", sender: audioRecorder.url)
        }else{
            print("Problem saving audio file")
        }
        // passes out the URL to the file
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "recordingDoneSegue"){
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            playSoundsVC.recordedAudioURL = sender as! NSURL
        }
    }
    
    func setRecordButtonStatus(text:String, enableStop:Bool, enableRecord:Bool){
        recordingStatusLabel.text = text
        stopRecordingButton.enabled = enableStop
        recordButton.enabled = enableRecord
    }
}
