//
//  ViewController.swift
//  SampleOCR
//
//  Created by NotSmall on 23/3/2564 BE.
//

import UIKit
import MobileCoreServices
import VisionKit

class ViewController: UIViewController{

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var resultTextView: UITextView!
    
    var mainViewModel:MainViewModel! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mainViewModel = MainViewModel()
        mainViewModel.delegate = self
    }

    
    @IBAction func displayActionSheetButton_Clicked(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String]
        let takeAPhoto = UIAlertAction(title: "Take a photo", style: .default) { (action) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        let chooseFromLibrary = UIAlertAction(title: "Choose from library", style: .default) { (action) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let scanDoc = UIAlertAction(title: "Scan Doc", style: .default) { (action) in
            let scanDocViewController = VNDocumentCameraViewController()
            scanDocViewController.delegate = self
            self.present(scanDocViewController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(takeAPhoto)
        alertController.addAction(chooseFromLibrary)
        alertController.addAction(scanDoc)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: MainViewModelDelegate {
    func setImage(image: UIImage) {
        photoImageView.image = image
    }
    
    func setResultText(text: String) {
        resultTextView.text = text
    }
}

extension ViewController:UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 1
        guard let selectedPhoto =
                info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        // 3
        dismiss(animated: true) {
            self.mainViewModel.displayImage = selectedPhoto
        }
    }
}

extension ViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for i in 0..<scan.pageCount {
            let img = scan.imageOfPage(at: i)
            self.mainViewModel.displayImage = img
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
