//
//  FPVViewController.swift
//  iOS-FPVDemo-Swift
//

import UIKit
import DJISDK
import VideoPreviewer
import CoreImage
import MetalKit
import ImageIO
class FPVViewController: UIViewController,  DJIVideoFeedListener, DJISDKManagerDelegate, DJIBaseProductDelegate, DJICameraDelegate {
    
    var isRecording : Bool!
    var camera : DJICamera!
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.fpvView)
        print(point.x, point.y)
    }
    @IBOutlet weak var blurLabel: UILabel!
    @IBOutlet weak var thresholdLabel: UILabel!
    
    @IBOutlet var recordTimeLabel: UILabel!
    
    @IBOutlet var captureButton: UIButton!
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var recordModeSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var snapshotView: UIImageView!
    @IBOutlet var fpvView: UIView!
    let ciConext: CIContext = CIContext()
    
    @IBAction func changeThreshold(_ sender: UISlider) {
        VideoPreviewer.instance().overExposedWarningThreshold = sender.value
        thresholdLabel.text = String(sender.value)
    }
    var ciFilter: CIFilter!
    
    var ciImage: CIImage!
    
    var opts = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
    
    var detctor: CIDetector!
    
    var feature: [CIFaceFeature]!
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        VideoPreviewer.instance().setView(self.fpvView)
        //VideoPreviewer.instance().rotation = VideoStreamRotationType.CW180
        //VideoPreviewer.instance().enableFocusWarning = true
        //VideoPreviewer.instance().overExposedWarningThreshold = 0.5
        //VideoPreviewer.instance().enableFocusWarning = true
        //VideoPreviewer.instance().enableHSB = true
        VideoPreviewer.instance().focusWarningThreshold = 0.9
        DJISDKManager.registerApp(with: self)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        VideoPreviewer.instance().setView(nil)
        DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
    }
    
    //    func takeSnapShot(_ image: UIImage?){
    //        UIImageWriteToSavedPhotosAlbum(OpenCVWrapper.processImage(image!), nil, nil, nil)
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //recordTimeLabel.isHidden = true
        detctor = CIDetector(ofType: CIDetectorTypeFace, context: ciConext, options: opts)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //
    //  Helpers
    //
    
    
    func fetchCamera() -> DJICamera? {
        let product = DJISDKManager.product()
        
        if (product == nil) {
            return nil
        }
        
        if (product!.isKind(of: DJIAircraft.self)) {
            return (product as! DJIAircraft).camera
        } else if (product!.isKind(of: DJIHandheld.self)) {
            return (product as! DJIHandheld).camera
        }
        
        return nil
    }
    
    func formatSeconds(seconds: UInt) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(seconds))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        
        return(dateFormatter.string(from: date))
    }
    
    
    //
    //  DJIBaseProductDelegate
    //
    
    func productConnected(_ product: DJIBaseProduct?) {
        
        NSLog("Product Connected")
        
        
        if (product != nil) {
            product!.delegate = self
            
            camera = self.fetchCamera()
            
            if (camera != nil) {
                camera!.delegate = self
                
                VideoPreviewer.instance().start()
                
            }
        }
    }
    
    func productDisconnected() {
        
        NSLog("Product Disconnected")
        
        camera = nil
        
        VideoPreviewer.instance().clearVideoData()
        VideoPreviewer.instance().close()
        
    }
    
    //
    //  DJISDKManagerDelegate
    //
    
    func appRegisteredWithError(_ error: Error?) {
        
        if (error != nil) {
            NSLog("Register app failed! Please enter your app key and check the network.")
        } else {
            NSLog("Register app succeeded!")
        }
        
        DJISDKManager.startConnectionToProduct()
        //DJISDKManager.enableBridgeMode(withBridgeAppIP: "10.89.165.231")
        DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        
    }
    
    //
    //  DJICameraDelegate
    //
    
    func camera(_ camera: DJICamera, didUpdate cameraState: DJICameraSystemState) {
        self.isRecording = cameraState.isRecording
        self.recordTimeLabel.isHidden = !self.isRecording
        
        self.recordTimeLabel.text = formatSeconds(seconds: cameraState.currentVideoRecordingTimeInSeconds)
        
        if (self.isRecording == true) {
            self.recordButton.setTitle("Stop Record", for: UIControlState.normal)
        } else {
            self.recordButton.setTitle("Start Record", for: UIControlState.normal)
        }
        
        if (cameraState.mode == DJICameraMode.shootPhoto) {
            self.recordModeSegmentControl.selectedSegmentIndex = 0
        } else {
            self.recordModeSegmentControl.selectedSegmentIndex = 1
        }
        
    }
    
    //
    //  DJIVideoFeedListener
    //
    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData rawData: Data) {
        
        let videoData = rawData as NSData
        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
        videoData.getBytes(videoBuffer, length: videoData.length)
        
        
        VideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
    }
    
    //
    //  IBAction Methods
    //
    
    @IBAction func captureAction(_ sender: UIButton) {
        
        if (camera != nil) {
            
            //snapshotView.image = UIImage.init(view: self.fpvView)
            //UIImageWriteToSavedPhotosAlbum(UIImage.init(view: self.fpvView), nil, nil, nil);
            //VideoPreviewer.instance().pause()
            VideoPreviewer.instance().snapshotPreview{ [weak self] in
                //self?.snapshotView.image = OpenCVWrapper.processImage($0)
                //self?.snapshotView.image = $0
//                self?.ciFilter = CIFilter(name: "CIExposureAdjust")
//                self?.ciFilter.setValue( -0.3, forKey: kCIInputEVKey)
//                self?.ciFilter.setValue(CIImage(image: $0!), forKey: kCIInputImageKey)
//                let cgImage = self?.ciConext.createCGImage((self?.ciFilter.outputImage!)!, from: (self?.ciFilter.outputImage!.extent)!)
//                self?.snapshotView.image = UIImage(cgImage: cgImage!)
                //let rect = CGRect(x: (self?.fpvView.bounds.midX)! + 50, y: (self?.fpvView.bounds.midY)! + 50, width: 100, height: 100)
                let point = CGPoint(x: ($0?.cgImage?.width)! / 2 - 50, y: ($0?.cgImage?.height)! / 2 - 50)
                let rect = CGRect(origin: point, size: CGSize(width: 100.0, height: 100.0))
                self?.fpvView.setNeedsDisplay()
                let cgImage = $0?.cgImage?.cropping(to: rect)
                
                self?.snapshotView.image = UIImage(cgImage: cgImage!)
                self?.blurLabel.text = String(OpenCVWrapper.processImage($0))

                //self?.snapshotView.image = $0
//                let ciImage = CIImage(image: (self?.snapshotView.image)!)
//                if let orientation = ciImage!.properties[kCGImagePropertyOrientation as String]{
//                    self?.feature = self?.detctor.features(in: ciImage!, options: [CIDetectorImageOrientation: orientation]) as! [CIFaceFeature]
//                } else {
//                    self?.feature = self?.detctor.features(in: ciImage!) as! [CIFaceFeature]
//                }
//                NSLog("NO")
//
//                if !(self?.feature.isEmpty)!{
//                    NSLog("hello")
//                    for faceFeature in (self?.feature)! {
//                        let faceView = UIView(frame: faceFeature.bounds)
//                        faceView.layer.borderColor = (UIColor.orange as! CGColor)
//                        faceView.layer.borderWidth = 2
//                        
//                        self?.snapshotView.addSubview(faceView)
//                    }
//                }
//                NSLog("exit")
                
                
            }
            //sleep(2)
            //VideoPreviewer.instance().snapshotPreview(nil)
        }
        
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        
        if (camera != nil) {
            if (self.isRecording) {
                camera.stopRecordVideo(completion: { (error) in
                    if (error != nil) {
                        NSLog("Stop Record Video Error: " + String(describing: error))
                    }
                })
            } else {
                camera.setMode(DJICameraMode.recordVideo,  withCompletion: { (error) in
                    
                    self.camera.startRecordVideo(completion: { (error) in
                        if (error != nil) {
                            NSLog("Stop Record Video Error: " + String(describing: error))
                        }
                    })
                })
            }
        }
    }
    
    
    @IBAction func recordModeSegmentChange(_ sender: UISegmentedControl) {
        
        if (camera != nil) {
            if (sender.selectedSegmentIndex == 0) {
                camera.setMode(DJICameraMode.shootPhoto,  withCompletion: { (error) in
                    
                })
                
            } else if (sender.selectedSegmentIndex == 1) {
                camera.setMode(DJICameraMode.recordVideo,  withCompletion: { (error) in
                    
                })
                
                
            }
        }
    }
    
}
extension UIView {
    
    func snapshotView(view: UIView, afterUpdates: Bool) -> UIView {
        let snapshot = view.snapshotView(afterScreenUpdates: afterUpdates)
        //self.addSubview(snapshot!)
        let snapBound = CGRect(x: 0, y: 0, width: view.bounds.width / 2.0, height: view.bounds.height / 2.0)
        snapshot!.frame = convert(snapBound, from: view)
        return snapshot!
    }
    
    func snapshotViews(views: [UIView], afterUpdates: Bool) -> [UIView] {
        return views.map { snapshotView(view: $0, afterUpdates: afterUpdates) }
    }
}
extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}
