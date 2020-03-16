//
//  HomeViewController.swift
//  cast
//
//  Created by DENNOUN Mohamed on 10/03/2020.
//  Copyright © 2020 DENNOUN Mohamed. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import ReplayKit
import WebKit
import AVKit
import Photos


class HomeViewController: UIViewController, RPPreviewViewControllerDelegate, WKNavigationDelegate {

    
    @IBOutlet weak var CameraImage: UIImageView!
    @IBOutlet weak var RecordAllScnBTN: UIButton!
    @IBOutlet weak var RecordingBTN: UIButton!
    @IBOutlet weak var CameraBTN: UIButton!
    
    let controller = RPBroadcastController()
    var cameraView1 = UIView(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
    var cameraView : UIView?
    var cameraFrame: CGRect!
    var cameraOrigImage = UIImage(named: "camera")
    var previewView : UIView!
    var boxView:UIView!
    var cameraIsUsed = false
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var movieOutput = AVCaptureMovieFileOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var isRecording = false


    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var captureDevice : AVCaptureDevice!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Home"
        let tintedImage = cameraOrigImage?.withRenderingMode(.alwaysTemplate)
        //cameraFrame = CGRect(x: 0, y: 0, width: 100, height: 200)
        
         previewView = UIView(frame: CGRect(x: 0,
                                           y: 50,
                                           width: 100,
                                           height: 200))
        previewView.contentMode = UIView.ContentMode.scaleAspectFit
        boxView = UIView(frame:  CGRect(x: 0,
        y: 50,
        width: 100,
        height: 200))
        boxView.tag = 1415
        previewView.tag = 1416
        
        view.addSubview(previewView)
        view.addSubview(boxView)
       
        UIScreen.main.addObserver(self, forKeyPath: "captured", options: .new, context: nil)
        var isCaptured = UIScreen.main.isCaptured
        if isCaptured {
            print("yes")
        } else {
            print("no")
        }
        

        

        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "captured") {
            let isCaptured = UIScreen.main.isCaptured
            print("rze")
            print(isCaptured)
            if (isCaptured) {
                processStartFrontVideo()
            } else {
                processStopFrontVideo()
            }
        }
        
    }
 
    
    
    @IBAction func startRecording(_ sender: UIButton) {
       /* if(RecordingBTN.backgroundColor != UIColor.red) {
            navigationController?.pushViewController(AppNagatorViewController(), animated: true)
        }
       processTouchRecord()*/
        processRecord()
     }
    
    @IBAction func startRecordingAllScn(_ sender: Any) {
        
        isRecording = true
        navigationController?.pushViewController(IntermediateViewController(), animated: true)
        
    }
    @IBAction func hundleYoutubeBroadcast(_ sender: Any) {
        if controller.isBroadcasting {
                      //stopBroadcast()
                  }
                  else {
                      startBroadcast()
                  }
    }
    
    @IBAction func handleCamera(_ sender: UIButton) {
        
       
        /*
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String = "\(documentsDirectory)/Replays/output.mp4"
        let urls = getpathScreenRec()
        var avArray = [AVAsset]()
        avArray.append(AVAsset(url: urls[0]))
        avArray.append(AVAsset(url: urls[1]))
        mergev(arrayVideos: avArray) { (url, error) in
            print(url?.absoluteString)
            print(error.debugDescription)
        }
            print("jifnriz")
 */
        
        
    }
    
    
    fileprivate func processTouchRecord() {
        let recorder = RPScreenRecorder.shared()
        if !recorder.isRecording {
            recorder.isCameraEnabled = true
            recorder.startRecording { (error) in
                guard error == nil else {
                    print("Failed to start recording")
                    return
                }
               
            }
            
            //self.processStartFrontVideo()
            self.RecordingBTN.setTitle("Stop Recording", for: .normal)
            self.RecordingBTN.backgroundColor = .red
            
        } else {
            recorder.stopRecording { (previewController, error) in
                guard error == nil else {
                    print("Failed to stop recording")
                    return
                }
                
                previewController?.previewControllerDelegate = self
                self.RecordingBTN.setTitle("Start Recording", for: .normal)
                //self.processStopFrontVideo()
                self.RecordingBTN.backgroundColor = .systemBlue
                self.present(previewController!, animated: true)
     
            }
        }
    }
    
    fileprivate func processRecord() {
        
        let screenRecord = ScreenRecordCoordinator()
        screenRecord.viewOverlay.stopButtonColor = UIColor.red
        let randomNumber = arc4random_uniform(9999);
        screenRecord.startRecording(withFileName: "screenRecord1", recordingHandler: { (error) in
            //self.processStartFrontVideo()
            print("Recording in progress")
        }) { (error) in
            //self.processStopFrontVideo()
            
            print("Recording Complete")
            print(error)
        }
    }
    
    
  func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
      self.dismiss(animated: true)
  }



}

extension HomeViewController:AVCaptureFileOutputRecordingDelegate {
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {


        }
    }
    





    func processStartFrontVideo(){
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String = "\(documentsDirectory)/Replays/output.mp4"
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: URL(fileURLWithPath: filePath))
          } catch {
              print("file not exist")
          }
        
        

        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: .front)
        
           for device in devices.devices {
               if (device as AnyObject).position == AVCaptureDevice.Position.front{


                   do{

                    let input = try AVCaptureDeviceInput(device: device )

                       if captureSession.canAddInput(input){

                           captureSession.addInput(input)
                           sessionOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecType.jpeg]

                           if captureSession.canAddOutput(sessionOutput){

                               captureSession.addOutput(sessionOutput)

                               previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                               previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                               previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                               //cameraView!.layer.addSublayer(previewLayer)

                               //previewLayer.bounds = cameraView!.frame


                           }

                           captureSession.addOutput(movieOutput)

                           captureSession.startRunning()
                        let fileUrl = URL(fileURLWithPath: ReplayFileUtil.filePath("output"))
                       
                        
                        movieOutput.startRecording(to: fileUrl, recordingDelegate: self)

                        print(fileUrl)

                       }

                   }
                   catch{

                       print("Error")
                   }

               }
           }

        
    }
    func processStopFrontVideo() {

        
        self.movieOutput.stopRecording()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String = "\(documentsDirectory)/Replays/output.mp4"
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
                UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, nil, nil)
                
                    }
        }
    
    func getpathScreenRec() -> Array<URL> {
        
        var pathURLs : Array<URL> = []
        let filePath = Bundle.main.path(forResource: "1", ofType: "mp4")
        let videoURL = NSURL(fileURLWithPath: filePath!)
        let avAsset = AVAsset(url: videoURL as URL)
        print(avAsset.allMediaSelections)
        
        return pathURLs
    }
    /*
    func getpathScreenRec () -> String {
        
               var path = ""
               let imgManager = PHImageManager.default()

                     let requestOptions = PHImageRequestOptions()
                     requestOptions.isSynchronous = true
                     requestOptions.deliveryMode = .highQualityFormat

                     let fetchOptions = PHFetchOptions()
                     fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                     if let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions) {
                         if fetchResult.count > 0 {
                                 for i in 0..<1{

                            
                   //Used for fetch Video//
                  imgManager.requestAVAsset(forVideo: fetchResult.object(at: i) as PHAsset, options: PHVideoRequestOptions(), resultHandler: {(avAsset, audioMix, info) -> Void in
                                     if let asset = avAsset as? AVURLAsset {
                                         //let videoData = NSData(contentsOf: asset.url)
                                         let duration : CMTime = asset.duration
                                        let durationInSecond = CMTimeGetSeconds(duration)
                                         print(durationInSecond)
                                        print(asset.url.relativePath)
                                        path = asset.url.relativePath
                                        
                                     }
                 })
                         }
                     }
                     else{
                         //showAllertToImportImage()//A function to show alert
                     }
                        
                 }

        return path
        
    }
 */
 
 
    func merge(arrayVideos:[AVAsset], completion:@escaping (_ exporter: AVAssetExportSession) -> ()) -> Void {

      let mainComposition = AVMutableComposition()
      let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
      compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)

      let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        var insertTime = CMTime.zero

      for videoAsset in arrayVideos {
        try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
        //try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)

        insertTime = CMTimeAdd(insertTime, videoAsset.duration)
      }

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String

      let outputFileURL = URL(fileURLWithPath: documentsDirectory + "/Replays/merge.mp4")

      let fileManager = FileManager()
       // try? fileManager.removeItem(at: outputFileURL)

      let exporter = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality)

      exporter?.outputURL = outputFileURL
        print(outputFileURL)
      exporter?.outputFileType = AVFileType.mp4
      exporter?.shouldOptimizeForNetworkUse = true

      exporter?.exportAsynchronously {
        DispatchQueue.main.async {
          completion(exporter!)
        }
      }
    }
    func mergev(arrayVideos:[AVAsset], completion:@escaping (URL?, Error?) -> ()) {

      let mainComposition = AVMutableComposition()
      let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
      compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)

      let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        var insertTime = CMTime.zero

      for videoAsset in arrayVideos {
        try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
        //try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)

        insertTime = CMTimeAdd(insertTime, videoAsset.duration)
      }

      let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String

      let outputFileURL = URL(fileURLWithPath: documentsDirectory + "merge.mp4")
        print("file")
        print(outputFileURL)
      let fileManager = FileManager()
      try? fileManager.removeItem(at: outputFileURL)

      let exporter = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality)

      exporter?.outputURL = outputFileURL
      exporter?.outputFileType = AVFileType.mp4
      exporter?.shouldOptimizeForNetworkUse = true

      exporter?.exportAsynchronously {
        if let url = exporter?.outputURL{
            print(url)

            UISaveVideoAtPathToSavedPhotosAlbum(url.absoluteString, self, nil, nil)
            completion(url, nil)
            
        }
        if let error = exporter?.error {
            completion(nil, error)
        }
      }
    }
  func mergeVideo() {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0] as String
    
            let fileURLs = getpathScreenRec()
        
      /*  DPVideoMerger().mergeVideos(withFileURLs: fileURLs , completion: {(_ mergedVideoFile: URL?, _ error: Error?) -> Void in
            print(mergedVideoFile)
                if error != nil {
                    let errorMessage = "Could not merge videos: \(error?.localizedDescription ?? "error")"
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    self.present(alert, animated: true) {() -> Void in }
                    return
                }
                let objAVPlayerVC = AVPlayerViewController()
                objAVPlayerVC.player = AVPlayer(url: mergedVideoFile!)
                self.present(objAVPlayerVC, animated: true, completion: {() -> Void in
                    objAVPlayerVC.player?.play()
                })
            })*/
        
        
    }
       
    
}
// AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods
extension HomeViewController:  AVCaptureVideoDataOutputSampleBufferDelegate{

    /*func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection!) {

        if CMSampleBufferDataIsReady(sampleBuffer) == false
        {
          // Handle error
          return;
        }
        var startTime : CMSampleBufferGetPresentationTimeStamp?
        var videoWriter : AVAssetWriter
        startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        if videoWriter.status == AVAssetWriterStatus.Unknown {
                    videoWriter.startWriting()
                    videoWriter.startSessionAtSourceTime(startTime)
                    return
            }

        if videoWriter.status == AVAssetWriterStatus.Failed {
          // Handle error here
          return;
        }

        // Here you collect each frame and process it

        if(recordingInProgress){

        if let _ = captureOutput as? AVCaptureVideoDataOutput {

            if videoWriterInput.isReadyForMoreMediaData{
                videoWriterInput.append(sampleBuffer)
                video_frames_written = true
            }
        }
        if let _ = captureOutput as? AVCaptureAudioDataOutput {
                if audioWriterInput.isReadyForMoreMediaData && video_frames_written{
                    audioWriterInput.append(sampleBuffer)
                }

            }

        }

    }
    */
    func startBroadcast() {
        //1
        RPBroadcastActivityViewController.load { broadcastAVC, error in
            
            //2
            guard error == nil else {
                print("Cannot load Broadcast Activity View Controller.")
                return
            }
            
            //3
            if let broadcastAVC = broadcastAVC {
                broadcastAVC.delegate = self as? RPBroadcastActivityViewControllerDelegate
                self.present(broadcastAVC, animated: true, completion: nil)
            }
        }
    }
    /*
    func recordCamera(videoOutput: AVCaptureVideoDataOutput) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let outputURL = URL(fileURLWithPath: documentsPath!).appendingPathComponent("test.m4v")
        assetWriter = try! AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mp4))
        assetWriterInput.expectsMediaDataInRealTime = true

        if assetWriter!.canAdd(assetWriterInput) {
            assetWriter!.add(assetWriterInput)
            } else {
                print("no input added")
            }
        assetWriter!.startWriting()
        
 
    }*/

    

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // do stuff here
    }

    // clean up AVCapture
    /*func stopCamera(){

        
        assetWriter!.finishWriting {
            print("i'm finish")
        }
        session.stopRunning()
        cameraIsUsed = false
    }*/

}
