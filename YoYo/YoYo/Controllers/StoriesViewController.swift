//
//  StoriesViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/25/21.
//

import UIKit

class StoriesViewController: UIViewController {

    @IBOutlet weak var myStoryStackView: UIStackView!
    @IBOutlet weak var myStoryImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var tableStories: [Story] = []
    private let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        imagePicker.delegate = self
    }
    
    private func setupView() {
        myStoryImageView.layer.borderWidth = 2.0
        myStoryImageView.layer.masksToBounds = false
        myStoryImageView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        myStoryImageView.layer.cornerRadius = myStoryImageView.layer.bounds.height / 2
        myStoryImageView.clipsToBounds = true
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x:0, y: self.myStoryStackView.frame.size.height - 1, width: self.myStoryStackView.frame.size.width, height:1)
        bottomBorder.backgroundColor = UIColor.darkGray.cgColor
        myStoryStackView.layer.addSublayer(bottomBorder)
    }
    
    @IBAction func showMyStoriesTapped(_ sender: Any) {
    }
    
    @IBAction func addStoriesTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true, completion: nil)
    }
    
}

// MARK:- Image Picker Delegate Methods
extension StoriesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // TODO:- Handle media
        
    }
}
