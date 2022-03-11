//
//  DetailsVC.swift
//  ArtStoryBook
//
//  Created by zafer on 9.03.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var nameTextFeild: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedUUID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        
        if selectedUUID != nil {
            saveButton.isHidden = true
            loadSelectedArt()
        }

        // Do any additional setup after loading the view.
        
        let viewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(viewGestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage))
        imageView.addGestureRecognizer(imageTapGestureRecognizer)
    }
    
    func loadSelectedArt(){
        let idString = selectedUUID!.uuidString
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                
                let result = results.first as! NSManagedObject

                if let name = result.value(forKey: "name") as? String {
                    nameTextFeild.text = name
                }
                if let year = result.value(forKey: "year") as? Int {
                    yearTextField.text = String(year)
                }
                if let artist = result.value(forKey: "artist") as? String {
                    artistTextField.text = artist
                }
                if let image = result.value(forKey: "image") as? Data {
                    imageView.image = UIImage(data: image)
                }
               
            }
        } catch {
            print("Error")
        }
    }
    
    @objc func onTapImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    func showAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { UIAlertAction in
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
        }
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onPressedSaveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameTextFeild.text, forKey: "name")
        newPainting.setValue(artistTextField.text, forKey: "artist")
        if let newYear = Int(yearTextField.text!) {
            newPainting.setValue(newYear, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            
            showAlert(title: "Success", message: "Painting saved succesfully")
            
        } catch {
            showAlert(title: "Error", message: "Painting cant saved")
        }
        
        
    }
    
}
