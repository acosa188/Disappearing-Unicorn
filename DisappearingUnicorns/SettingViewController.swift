//
//  SettingViewController.swift
//  DisappearingUnicorns
//
//  Created by Arjun Cosare on 9/30/19.
//  Copyright © 2019 Arjun cosare. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var playerPhoto: UIImageView!
    @IBOutlet weak var playerAgeLabel: UILabel!
    @IBOutlet weak var playerName: UITextField!
    @IBOutlet weak var playerAge: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var bgSwitchState: UISwitch!
    @IBOutlet weak var colorSegment: UISegmentedControl!
    @IBOutlet weak var gameSpeedLabel: UILabel!
    @IBOutlet weak var gameSpeedSlider: UISlider!
    @IBOutlet weak var backgroundCircle: UIButton!
    
    
    var playerInfo: PlayerData?
    let defaults = UserDefaults.standard
    var gameData : GameData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameData = GameData()
        if let playerInfo = playerInfo{
            playerPhoto.image = playerInfo.photo
            playerName.text = playerInfo.name
            playerAge.text = defaults.string(forKey: "playerAge") ?? ""
            playerAgeLabel.text = "Age: \(defaults.string(forKey: "playerAge") ?? "None")"
        }
        configureTextFields()
        roundedButton()
        configureState()
        // Do any additional setup after loading the view.
    }
    
    func backgroundColorChange(){
        if(bgSwitchState.isOn)
        {
            backgroundCircleChange(defaults.integer(forKey: "colorSegmentIndex"))
            backgroundCircle.layer.borderWidth = 0
        }
        else
        {
            backgroundCircleChange(-1)
            backgroundCircle.layer.borderWidth = 2
            
        }
    }
    
    //Actions
    @IBAction func updateButtonPressed(_ sender: Any) {
        let updateAlert = UIAlertController(title: "Update Age, message", message: "Are you sure you want to update the player age to \(playerAge.text!)", preferredStyle: .alert)
        
        updateAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: {
            action in
            
            self.playerInfo?.name = self.playerName.text!
            
            self.defaults.set(self.playerName.text!, forKey: "playerName")
            self.defaults.set(self.playerAge.text!, forKey: "playerAge")
            
            self.playerAgeLabel.text = "Age: \(self.playerAge.text!)"
            
            
            }))
        
        updateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel){(action) in
            self.view.endEditing(true)
        })
        self.view.endEditing(true)
        
        self.present(updateAlert, animated: true)
    }
    
    @IBAction func bgSwitchPressed(_ sender: Any) {
        if(bgSwitchState.isOn)
        {
            defaults.set(true, forKey: "bgSwitchState")
        }
        else
        {
            defaults.set(false, forKey: "bgSwitchState")
        }
        backgroundColorChange()
        
    }
    
    @IBAction func colorSegmentPressed(_ sender: Any) {
        defaults.set(colorSegment.selectedSegmentIndex, forKey: "colorSegmentIndex")
        backgroundColorChange()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Float(sender.value)
        gameSpeedLabel.text = "\(String(format: "%.2f",currentValue))s / Round"
        defaults.set(gameSpeedSlider.value, forKey: "gameSpeed")
    }
    
    @IBAction func changePhotoPressed(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = true
        
        self.present(image, animated: true)
        {
            
        }
        
        
    }
    
    //configurables
    private func configureTextFields(){
        playerName.delegate = self
        playerAge.delegate = self
    }
    
    private func roundedButton(){
        updateButton.layer.cornerRadius = 5
        backgroundCircle.layer.cornerRadius = backgroundCircle.frame.width * 0.5
        backgroundCircle.layer.borderWidth = 2
        backgroundCircle.layer.borderColor = UIColor.black.cgColor
    }
    
    private func configureState()
    {
        //Set default on background switch
        bgSwitchState.setOn(defaults.bool(forKey: "bgSwitchState"), animated: false)
        
        
        //Set background color circle
        backgroundColorChange()
 
        //Set color last picked color segment
        colorSegment.selectedSegmentIndex = defaults.integer(forKey: "colorSegmentIndex")
        
        //Slider config
        gameSpeedSlider.minimumValue = 0.1
        gameSpeedSlider.maximumValue = 5.0
        gameSpeedSlider.setValue(defaults.float(forKey: "gameSpeed"), animated: false)
        //If user has cached value, do that else set the default speed to 1 second
        gameSpeedSlider.value = defaults.float(forKey: "gameSpeed") > 0.0 ? defaults.float(forKey: "gameSpeed") : 1.0
        
        //Set last set gamespeed
        gameSpeedLabel.text = "\(defaults.float(forKey: "gameSpeed") == 0.0 ? "1.0" : String(format: "%.2f",defaults.float(forKey: "gameSpeed")))s / Round"
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            gameData?.updateProPic(for: self.playerInfo!.name, photo: image)
            self.playerInfo?.photo = image
            playerPhoto.image = image
            
        }
        else
        {
        //error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // Helpers
    private func backgroundCircleChange(_ colorIndex: Int){
        switch colorIndex {
        case 0:
            backgroundCircle.backgroundColor = UIColor.red
        case 1:
            backgroundCircle.backgroundColor = UIColor.blue
        case 2:
            backgroundCircle.backgroundColor = UIColor.green
        case 3:
            backgroundCircle.backgroundColor = UIColor.yellow
        default:
            backgroundCircle.backgroundColor = UIColor.white
        }
    }
    

}

extension SettingViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
