//
//  MapViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

class HomeViewController: UIViewController {
    
    private let mapVC = MapViewController()

    private let startTrackButton = UIImageView()

    private let stopTrackButton = UIImageView()

    private var stopWidthAnchor: NSLayoutConstraint!

    private var stopHeightAnchor: NSLayoutConstraint!
    
    private var trackTimer: Timer?

    private var stopTimer: Timer?
    
    private var timerDuration: Int = 0
    
    private var isTracking = false
    
    private let strangerButton = UIButton()
    
    private let notificationButton = UIButton()
    
    private let choosePetImageView = UIImageView()
    
    private let strangerVC = StrangerViewController()

    private let alerHelper = AlertHelper()
    
    private var trackStartTime = Timestamp()
    
    private var user: User
    
    private var userPets: [Pet] = []
    
    private let locationHelper = LocationHelper()
    
    init() {
        
        self.user = UserManager.shared.currentUser ?? UserManager.shared.guestUser
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setup()
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true

        checkAuth()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setup() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateData),
                                               name: .updateUser,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCurrentPet),
                                               name: .updateCurrentPet,
                                               object: nil)
        
        mapVC.delegate = self
        
        choosePetImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapChoosePet)))
        
        choosePetImageView.isUserInteractionEnabled = true

        strangerButton.addTarget(self, action: #selector(didTapStrangerButton), for: .touchUpInside)
        
        notificationButton.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)
        
        setupTrackButton()
    }
    
    private func style() {
        
        startTrackButton.image = UIImage.asset(.Icons_90px_Start)
        stopTrackButton.image = UIImage.asset(.Icons_90px_Stop)
        
        strangerButton.setImage(UIImage.asset(.Icons_60px_Stranger), for: .normal)
    }
    
    private func layout() {
        
        add(mapVC)
        view.addSubview(stopTrackButton)
        view.addSubview(startTrackButton)
        view.addSubview(strangerButton)
        view.addSubview(notificationButton)
        view.addSubview(choosePetImageView)
        
        mapVC.view.anchor(top: view.topAnchor,
                       leading: view.leadingAnchor,
                       bottom: view.safeAreaLayoutGuide.bottomAnchor,
                       trailing: view.trailingAnchor)
        
        choosePetImageView.anchor(leading: view.leadingAnchor,
                           bottom: view.safeAreaLayoutGuide.bottomAnchor,
                           width: 65,
                           height: 65,
                           padding: UIEdgeInsets(top: 0, left: 35, bottom: 35, right: 0))
        
        strangerButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              leading: view.leadingAnchor,
                              width: 60,
                              height: 60,
                              padding: UIEdgeInsets(top: 60, left: 35, bottom: 0, right: 0))
        
        notificationButton.anchor(trailing: view.trailingAnchor,
                              centerY: strangerButton.centerYAnchor,
                              width: 45,
                              height: 45,
                              padding: UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 35))
        
        startTrackButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                               centerX: view.centerXAnchor,
                               width: 80,
                               height: 80,
                               padding: UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 0))
        
        stopTrackButton.anchor(centerY: startTrackButton.centerYAnchor,
                               centerX: startTrackButton.centerXAnchor)
        
        stopWidthAnchor = stopTrackButton.widthAnchor.constraint(equalToConstant: 80)
        stopHeightAnchor = stopTrackButton.heightAnchor.constraint(equalToConstant: 80)
        stopWidthAnchor?.isActive = true
        stopHeightAnchor?.isActive = true

        setButtonStyle()
    }
    
    private func setButtonStyle() {
        
        strangerButton.setRadiusWithShadow()
        
        notificationButton.setRadiusWithShadow()
        
        startTrackButton.setRadiusWithShadow()
        
        stopTrackButton.setRadiusWithShadow()
        
        choosePetImageView.layoutIfNeeded()
        setCurrentPetButton()
    }
    
    @objc private func updateData() {
        
        if let user = UserManager.shared.currentUser {
            
            self.user = user
            checkAuth()
        }
        if Auth.auth().currentUser != nil {
            
            checkTrackStatus()
            
            getStrangerLocations()
        } else {
            
            notTracking()
        }
    }
    
    private func checkAuth() {
        
        if Auth.auth().currentUser != nil {

            getUserPets(user: user)
            
            mapVC.listenFriendsLocation(user: user)
            
            notificationButton.isHidden = false
            
            checkFriendRequest()

        } else {
            mapVC.userCurrentPet = nil
            
            userPets = []
            
            mapVC.removeFriendLocation()
            
            notificationButton.isHidden = true
        }
    }
    
    private func checkFriendRequest() {
        
        if user.recieveRequestsId.isEmpty {
            
            notificationButton.setImage(UIImage.asset(.Icons_45px_Bell),
                                        for: .normal)
        } else {
            
            notificationButton.setImage(UIImage.asset(.Icons_45px_Bell_Notified),
                                        for: .normal)
        }
    }
    
    private func checkTrackStatus() {
        
        if isTracking {
            
            beTracking()
        } else {
            MapManager.shared.changeUserStatus(userId: user.id,
                                        status: .unTrack)
            notTracking()
        }
    }
    
    private func setupTrackButton() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapStartTrack))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongTapEndTrack))
        
        tapGesture.numberOfTapsRequired = 1
        longGesture.minimumPressDuration = 0

        startTrackButton.addGestureRecognizer(tapGesture)
        stopTrackButton.addGestureRecognizer(longGesture)
        
        notTracking()
    }
    
    private func getUserPets(user: User) {
        
        guard user.id != UserStatus.guest.rawValue else {
            return
        }
        
        UserManager.shared.fetchPets(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.userPets = pets
                self?.mapVC.getCurrentPet(user: user, userPets: pets)
                
            case .failure:
                
                LottieWrapper.shared.showError(errorMessage: "Network Unstable")
            }
        }
    }
    
    @objc private func didTapStartTrack() {
        
        guard Auth.auth().currentUser != nil else {
            
            NotificationCenter.default.post(name: .showSignInView, object: .none)
            return
        }
        
        guard !user.petsId.isEmpty else {

            showNoPetAlert(message: "Cannot track without Pet. Going to add Pet.")
            return
        }
        
        guard mapVC.userCurrentPet != nil else {
            
            showNoSelectPetAlert()
            return
        }
        
        guard mapVC.isLocationAuth() else {
            
            showLocationAlert()
            return
        }
        
        isTracking = true
        
        trackTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            
            guard let self = self else { return }
            
            self.timerDuration += 1
            
            self.mapVC.trackDashboardView.timeLabel.text = TimeInterval(self.timerDuration).timeString()
        })
        
        beTracking()
        
        mapVC.startUpdateLocation()

        trackStartTime = Timestamp(date: Date())
        
        self.mapVC.infoBottomAnchor.constant = self.view.safeAreaInsets.top +
        self.mapVC.trackDashboardView.frame.height
        
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func didLongTapEndTrack(_ sender: UIGestureRecognizer) {

        var count: Double = 0

        if sender.state == .began {

            stopTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true, block: { [weak self] _ in

                guard let self = self else {
                    return
                }
                count += 0.03
                self.stopWidthAnchor?.constant += 2
                self.stopHeightAnchor?.constant += 2
                
                UIView.animate(withDuration: 0.02) {
                    self.view.layoutIfNeeded()
                }

                if count >= 1 {
                    
                    self.didFinishTrack()
                    count = 0
                }
            })
        } else if sender.state == .ended {
            
            count = 0
            stopTimer?.invalidate()
            stopTimer = nil
            stopWidthAnchor.constant = 80
            stopHeightAnchor.constant = 80
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func didFinishTrack() {
        
        mapVC.focusUserLocation()

        let coordinate = mapVC.userStoredLocations.map { $0.coordinate }
        let track = coordinate.map { $0.transferToGeopoint() }

        guard let userCurrentPet = mapVC.userCurrentPet,
              !coordinate.isEmpty else {

            return
        }

        let distance = locationHelper.computeDistance(from: track.map {
            $0.transferToCoordinate2D()
        })

        let trackInfo = TrackInfo(id: "",
                                  petId: userCurrentPet.id,
                                  distanceMeter: distance,
                                  startTime: trackStartTime,
                                  endTime: Timestamp(),
                                  track: track,
                                  note: "")

        let trackHistoryVC = TrackHistoryViewController(pet: userCurrentPet,
                                                        trackInfo: trackInfo,
                                                        isNew: true)
        resetTrack()
        
        stopTimer?.invalidate()
        stopTimer = nil
        stopWidthAnchor.constant = 80
        stopHeightAnchor.constant = 80
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        navigationController?.pushViewController(trackHistoryVC, animated: true)
        
    }
    
    private func resetTrack() {
        
        timerDuration = 0
        mapVC.trackDashboardView.timeLabel.text = "00:00:00"
        trackTimer?.invalidate()
        trackTimer = nil
        mapVC.distance = 0
        mapVC.trackDashboardView.distanceLabel.text = "0.00 km"
        isTracking = false
        
        notTracking()

        mapVC.stopUpdateLocation(user: user)
        mapVC.mapView.removeOverlays(self.mapVC.mapView.overlays)
        
        mapVC.infoBottomAnchor.constant = 0
    }
    
    @objc private func updateCurrentPet() {

        resetTrack()
        mapVC.getCurrentPet(user: user, userPets: userPets)
    }
    
    @objc private func didTapChoosePet() {
        
        guard Auth.auth().currentUser != nil else {
            
            showNoPetAlert(message: "Please Login.")
            return
        }
        
        guard !user.petsId.isEmpty else {
            
            showNoPetAlert(message: "Please Add Pet.")
            return
        }
        
        guard !isTracking else { return }
        
        let choosePetVC = ChoosePetViewController(pets: userPets, isPost: false)
        
        choosePetVC.delegate = self
        
        let navChoosePetVC = UINavigationController(rootViewController: choosePetVC)

        if let sheet = navChoosePetVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 20
        }
        present(navChoosePetVC, animated: true, completion: nil)
    }
    
    @objc private func didTapStrangerButton() {
        
        strangerButton.isSelected = !strangerButton.isSelected
        
        if strangerButton.isSelected {
            
            showStrangerCollectionView()
        } else {
            
            strangerVC.remove()
        }

        getStrangerLocations()
    }
    
    private func showStrangerCollectionView() {
     
        add(strangerVC)
        
        strangerVC.view.anchor(top: strangerButton.bottomAnchor,
                              leading: view.leadingAnchor,
                              trailing: view.trailingAnchor,
                              height: 150,
                              padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        strangerVC.view.layoutIfNeeded()
    }
    
    private func getStrangerLocations() {
        
        MapManager.shared.fetchStrangerLocations(friend: user.friends,
                                                 blockIds: user.blockUsersId) { [weak self] result in
            
            switch result {
                
            case .success(let strangerLocations):
                
                guard let myLocation = self?.mapVC.mapView.userLocation.location else { return }
                
                guard var nearStrangersId = self?.locationHelper.getNearUsersId(myLocation: myLocation,
                                                                                userLocations: strangerLocations,
                                                                                distanceKM: 5.0)
                else {
                    print(FirebaseError.fetchStangerError.errorMessage)
                    return
                }
                nearStrangersId.removeAll(where: { $0 == self?.user.id })
                
                self?.fetchPets(from: nearStrangersId) { pets in
                    
                    self?.strangerVC.strangerPets = pets
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    @objc private func didTapNotificationButton() {
        
        let friendRequestVC = FriendRequestViewController()
        
        navigationController?.pushViewController(friendRequestVC, animated: true)
    }
    
    private func fetchPets(from usersId: [String], completion: @escaping ([Pet]) -> Void) {
        
        let group = DispatchGroup()
        
        var fetchedPets: [Pet] = []
        
        for userId in usersId {
            
            group.enter()
            
            UserManager.shared.fetchPets(userId: userId) { result in
                
                switch result {
                    
                case.success(let pets):
                    
                    fetchedPets.append(contentsOf: pets)
                    
                    group.leave()
                    
                case .failure(let error):
                    
                    print(error)
                    
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            
            completion(fetchedPets)
        }
    }

    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {

           UIApplication.shared.open(settingsUrl)
         }
    }
    
    private func showNoPetAlert(message: String) {
        
        alerHelper.showAlertWithOK(title: "No Pet ☹️",
                                   message: message,
                                   action: { self.setNoPetAction() },
                                   by: self)
    }
    
    private func setNoPetAction() {
        guard Auth.auth().currentUser != nil else {
            
            NotificationCenter.default.post(name: .showSignInView, object: .none)
            return
        }
        self.tabBarController?.selectedIndex = 4
    }
    
    private func showNoSelectPetAlert() {
        
        alerHelper.showAlertWithOK(title: "Select Pet",
                                   message: "Cannot track without pet.",
                                   action: { self.didTapChoosePet() },
                                   by: self)
    }
    
    private func beTracking() {
        
        startTrackButton.isHidden = true
        stopTrackButton.isHidden = false
        
        startTrackButton.isUserInteractionEnabled = false
        stopTrackButton.isUserInteractionEnabled = true
    }
    
    private func notTracking() {
        
        startTrackButton.isHidden = false
        stopTrackButton.isHidden = true
        
        startTrackButton.isUserInteractionEnabled = true
        stopTrackButton.isUserInteractionEnabled = false
    }
}

extension HomeViewController: MapViewDelegate {
    
    func setCurrentPetButton() {
        
        if let userCurrentPet = mapVC.userCurrentPet {
            
            let imageUrlSting = userCurrentPet.petImage
            
            choosePetImageView.kf.setImage(with: URL(string: imageUrlSting))
        } else {
            
            choosePetImageView.image = UIImage.asset(.Image_Placeholder_Paw)
        }
        
        choosePetImageView.makeRoundDoubleBorder(borderWidth: 2,
                                                 outterColor: .BattleGrey,
                                                 innerColor: .white)
        
        choosePetImageView.contentMode = .scaleAspectFill
        choosePetImageView.clipsToBounds = true
        choosePetImageView.layer.masksToBounds = true
    }
    
    func showLocationAlert() {
        
        alerHelper.showAlert(
            title: "Allow \"PawKing\" To Access Your Location While You Use The App.",
            message: "PawKing requires your precise location to track your pet walks which you could check out later " +
            "and provide you feature of showing the pets near by you. " +
            "We will not disclose any location of you to others.",
            actionName: "Setting",
            actionStyle: .default,
            action: { self.openAppSettings() },
            by: self
        )
    }
}

extension HomeViewController: ChoosePetViewDelegate {
    
    func didChoosePet(with selectedPet: Pet) {
        
        self.mapVC.userCurrentPet = selectedPet
        
        UserManager.shared.updateCurrentPet(userId: user.id, pet: selectedPet)
    }
}
