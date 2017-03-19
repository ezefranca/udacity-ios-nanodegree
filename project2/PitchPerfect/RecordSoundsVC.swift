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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        stopRecordingButton.isEnabled = false
        recordButton.isEnabled=true
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        print("Stop Recording")
        setRecordButtonStatus("Tap to Record", enableStop: false, enableRecord: true)
        //stop recording
        audioRecorder.stop()
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        
        setRecordButtonStatus("Recording in progress", enableStop: true, enableRecord: false)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "recordingDoneSegue", sender: audioRecorder.url)
        }else{
            print("Problem saving audio file")
        }
        // passes out the URL to the file
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "recordingDoneSegue"){
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            playSoundsVC.recordedAudioURL = sender as! URL
        }
    }
    
    func setRecordButtonStatus(_ text:String, enableStop:Bool, enableRecord:Bool){
        recordingStatusLabel.text = text
        stopRecordingButton.isEnabled = enableStop
        recordButton.isEnabled = enableRecord
    }
}
