//
//  PetConfigCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import UIKit

protocol PetConfigCellDelegate {
    
//    func textFieldDidChange(From textField: UITextField)
    
    func didTapPhoto()
    
    func didTapFinish(From cell: PetConfigCell)
}

class PetConfigCell: UITableViewCell {
    
    static let identifier = "\(PetConfigCell.self)"
    
    var delegate: PetConfigCellDelegate?
    
    let photoButton = UIButton()
    
    let nameTitleLabel = UILabel()
    
    let petNameTextfield = UITextField()
    
    let genderTitleLabel = UILabel()
    
    private let genderPicker = UIPickerView()
    
    let genderTextfield = UITextField()
    
    let birthdayTitleLabel = UILabel()
    
    let birthdayPicker = UIDatePicker()
    
//    let birthdayTextfield = UITextField()
    
    let descriptionTitleLabel = UILabel()
    
    let descriptionTextView = UITextView()
    
    private let finishButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        styleObject()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        photoButton.isUserInteractionEnabled = true
        
        photoButton.addTarget(self, action: #selector(didTapPhotoButton),
                                  for: .touchUpInside)
        
//        petNameTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)),
//                                  for: .editingChanged)
//
        finishButton.addTarget(self, action: #selector(didTapFinish), for: .touchUpInside)
    }
    
    func styleObject() {
        
        photoButton.setImage(UIImage.asset(.Image_Placeholder), for: .normal)
        photoButton.imageView?.contentMode = .scaleAspectFill
        
        nameTitleLabel.text = "Name"
        nameTitleLabel.font = UIFont.systemFont(ofSize: 16)
        nameTitleLabel.textColor = .black
        
        genderTitleLabel.text = "Gender"
        genderTitleLabel.font = UIFont.systemFont(ofSize: 16)
        genderTitleLabel.textColor = .black
        
        birthdayTitleLabel.text = "Birthday"
        birthdayTitleLabel.font = UIFont.systemFont(ofSize: 16)
        birthdayTitleLabel.textColor = .black
        
        descriptionTitleLabel.text = "Description"
        descriptionTitleLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionTitleLabel.textColor = .black
        
        petNameTextfield.layer.borderColor = UIColor.Gray?.cgColor
        petNameTextfield.layer.borderWidth = 1
        
        genderTextfield.layer.borderColor = UIColor.Gray?.cgColor
        genderTextfield.layer.borderWidth = 1
        genderTextfield.inputView = genderPicker
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        birthdayPicker.locale = .current
        birthdayPicker.datePickerMode = .date
        birthdayPicker.preferredDatePickerStyle = .compact
        birthdayPicker.tintColor = .O1
        birthdayPicker.layer.borderColor = UIColor.Gray?.cgColor
        birthdayPicker.layer.borderWidth = 1
        
        descriptionTextView.layer.borderColor = UIColor.Gray?.cgColor
        descriptionTextView.layer.borderWidth = 1
        
        finishButton.setTitle("Finish", for: .normal)
        finishButton.backgroundColor = .O1
    }
    
    func layout() {
        
        contentView.addSubview(photoButton)
        contentView.addSubview(nameTitleLabel)
        contentView.addSubview(genderTitleLabel)
        contentView.addSubview(birthdayTitleLabel)
        contentView.addSubview(descriptionTitleLabel)
        
        contentView.addSubview(petNameTextfield)
        contentView.addSubview(genderTextfield)
        contentView.addSubview(birthdayPicker)
        contentView.addSubview(descriptionTextView)
        
        contentView.addSubview(finishButton)
        
        photoButton.anchor(top: contentView.topAnchor,
                           centerX: contentView.centerXAnchor,
                           width: 150,
                           height: 150,
                           padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        nameTitleLabel.anchor(top: photoButton.bottomAnchor,
                              leading: contentView.leadingAnchor,
                              trailing: contentView.trailingAnchor,
                              height: 20,
                              padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 0))
        
        petNameTextfield.anchor(top: nameTitleLabel.bottomAnchor,
                                 leading: nameTitleLabel.leadingAnchor,
                                 trailing: contentView.trailingAnchor,
                                 height: 30,
                                 padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 20))
        
        genderTitleLabel.anchor(top: petNameTextfield.bottomAnchor,
                                leading: nameTitleLabel.leadingAnchor,
                                trailing: nameTitleLabel.trailingAnchor,
                                height: 20,
                              padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        genderTextfield.anchor(top: genderTitleLabel.bottomAnchor,
                               leading: nameTitleLabel.leadingAnchor,
                               trailing: contentView.trailingAnchor,
                               height: 30,
                               padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 20))
        
        birthdayTitleLabel.anchor(top: genderTextfield.bottomAnchor,
                                  leading: nameTitleLabel.leadingAnchor,
                                  trailing: nameTitleLabel.trailingAnchor,
                                  height: 20,
                                padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        birthdayPicker.anchor(top: birthdayTitleLabel.bottomAnchor,
                              leading: nameTitleLabel.leadingAnchor,
                              trailing: contentView.trailingAnchor,
                              height: 30,
                              padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 20))
        
        descriptionTitleLabel.anchor(top: birthdayPicker.bottomAnchor,
                                     leading: nameTitleLabel.leadingAnchor,
                                     trailing: nameTitleLabel.trailingAnchor,
                                     height: 20,
                                   padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        descriptionTextView.anchor(top: descriptionTitleLabel.bottomAnchor,
                                   leading: nameTitleLabel.leadingAnchor,
                                   trailing: contentView.trailingAnchor,
                                   height: 200,
                                   padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 20))
        
        finishButton.anchor(top: descriptionTextView.bottomAnchor,
                            leading: contentView.leadingAnchor,
                            trailing: contentView.trailingAnchor,
                            height: 50,
                            padding:UIEdgeInsets(top: 20, left: 30, bottom: 0, right: 30))
    }
    
    @objc func didTapPhotoButton() {
        
        self.delegate?.didTapPhoto()
    }
    
    @objc func didTapFinish() {
        
        self.delegate?.didTapFinish(From: self)
    }
    
//    @objc func textFieldDidChange(_ textField: UITextField) {
//
//        guard textField == petNameTextfield else { return }
//
//        self.delegate?.textFieldDidChange(From: textField)
//    }
}

extension PetConfigCell: UITextViewDelegate {
    
}

extension PetConfigCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == genderPicker {
            
            return PetGender.allCases.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == genderPicker {
            return PetGender.allCases[row].rawValue
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == genderPicker {
            genderTextfield.text = PetGender.allCases[row].rawValue
        }
    }
}
