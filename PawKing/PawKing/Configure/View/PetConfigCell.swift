//
//  PetConfigCell.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import UIKit
import FirebaseFirestore

protocol PetConfigCellDelegate {
    
//    func textFieldDidChange(From textField: UITextField)
    
    func didTapPhoto()
    
    func didTapFinish(From cell: PetConfigCell)
}

class PetConfigCell: UITableViewCell {
    
    static let identifier = "\(PetConfigCell.self)"
    
    var delegate: PetConfigCellDelegate?
    
    let petImageView = UIImageView()
    
    let nameTitleLabel = UILabel()
    
    let petNameTextfield = InputTextField()
    
    let genderTitleLabel = UILabel()
    
    private let genderPicker = UIPickerView()
    
    let genderTextfield = InputTextField()
    
    let birthdayTitleLabel = UILabel()
    
    let birthdayPicker = UIDatePicker()
    
    let birthdayTextfield = InputTextField()
    
//    let descriptionTitleLabel = UILabel()
    
//    let descriptionTextView = UITextView()
    
    private let finishButton = UIButton()
    
    var birthday: Timestamp?
    
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
        
        selectionStyle = .none
        
        petImageView.isUserInteractionEnabled = true
        
        petImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapPetImage)))
        
        petImageView.isUserInteractionEnabled = true
        
//        photoButton.addTarget(self, action: #selector(didTapPhotoButton),
//                                  for: .touchUpInside)
        
        birthdayPicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        finishButton.addTarget(self, action: #selector(didTapFinish), for: .touchUpInside)
    }
    
    func styleObject() {
        
        petImageView.image = UIImage.asset(.Image_Placeholder)
        petImageView.contentMode = .scaleAspectFill
        
        nameTitleLabel.text = "Name"
        nameTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameTitleLabel.textColor = .DarkBlue
        
        genderTitleLabel.text = "Gender"
        genderTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        genderTitleLabel.textColor = .DarkBlue
        
        birthdayTitleLabel.text = "Birthday"
        birthdayTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        birthdayTitleLabel.textColor = .DarkBlue
        
        genderTextfield.inputView = genderPicker
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        birthdayPicker.locale = .current
        birthdayPicker.datePickerMode = .date
        birthdayPicker.preferredDatePickerStyle = .inline

        birthdayTextfield.inputView = birthdayPicker

        finishButton.setTitle("Confirm", for: .normal)
        finishButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        finishButton.backgroundColor = .Orange1
        finishButton.layer.cornerRadius = 4
    }
    
    func layout() {
        
        contentView.addSubview(petImageView)
        contentView.addSubview(nameTitleLabel)
        contentView.addSubview(genderTitleLabel)
        contentView.addSubview(birthdayTitleLabel)
//        contentView.addSubview(descriptionTitleLabel)
        
        contentView.addSubview(petNameTextfield)
        contentView.addSubview(genderTextfield)
        contentView.addSubview(birthdayTextfield)
//        contentView.addSubview(descriptionTextView)
        
        contentView.addSubview(finishButton)
        
        petImageView.anchor(top: contentView.topAnchor,
                           centerX: contentView.centerXAnchor,
                           width: 150,
                           height: 150,
                           padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        nameTitleLabel.anchor(top: petImageView.bottomAnchor,
                              leading: contentView.leadingAnchor,
                              trailing: contentView.trailingAnchor,
                              height: 20,
                              padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 0))
        
        petNameTextfield.anchor(top: nameTitleLabel.bottomAnchor,
                                 leading: nameTitleLabel.leadingAnchor,
                                 trailing: contentView.trailingAnchor,
                                 height: 40,
                                 padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 20))
        
        genderTitleLabel.anchor(top: petNameTextfield.bottomAnchor,
                                leading: nameTitleLabel.leadingAnchor,
                                trailing: nameTitleLabel.trailingAnchor,
                                height: 20,
                              padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        genderTextfield.anchor(top: genderTitleLabel.bottomAnchor,
                               leading: nameTitleLabel.leadingAnchor,
                               trailing: contentView.trailingAnchor,
                               height: 40,
                               padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 20))
        
        birthdayTitleLabel.anchor(top: genderTextfield.bottomAnchor,
                                  leading: nameTitleLabel.leadingAnchor,
                                  trailing: nameTitleLabel.trailingAnchor,
                                  height: 20,
                                padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        birthdayTextfield.anchor(top: birthdayTitleLabel.bottomAnchor,
                              leading: nameTitleLabel.leadingAnchor,
                              trailing: contentView.trailingAnchor,
                              height: 40,
                              padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 20))
        
        finishButton.anchor(top: birthdayTextfield.bottomAnchor,
                            leading: birthdayTextfield.leadingAnchor,
                            trailing: birthdayTextfield.trailingAnchor,
                            height: 40,
                            padding: UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0))
        
        contentView.layoutIfNeeded()
        petImageView.makeRound()
        petImageView.clipsToBounds = true
    }
    
    func configureCell(pet: Pet) {
        
        let imageUrl = URL(string: pet.petImage)
        
        petImageView.kf.setImage(with: imageUrl)
        
        petNameTextfield.text = pet.name
        
        genderTextfield.text = pet.gender
        
        birthdayTextfield.text = pet.birthday.dateValue().displayTimeInBirthdayStyle()
        
        birthday = pet.birthday
    }
    
    @objc func didTapPetImage() {
        
        self.delegate?.didTapPhoto()
    }
    
    @objc func didTapFinish() {
        
        finishButtonDisable()
        
        self.delegate?.didTapFinish(From: self)
    }
    
//    @objc func textFieldDidChange(_ textField: UITextField) {
//
//        guard textField == petNameTextfield else { return }
//
//        self.delegate?.textFieldDidChange(From: textField)
//    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {

        birthdayTextfield.text = sender.date.displayTimeInBirthdayStyle()
        
        birthday = Timestamp(date: sender.date)
    }
    
    func finishButtonEnable() {
        
        finishButton.backgroundColor = .Orange1
        finishButton.isEnabled = true
    }
    
    func finishButtonDisable() {
        
        finishButton.backgroundColor = .Gray1
        finishButton.isEnabled = false
    }
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
