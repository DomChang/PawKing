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

// swiftlint:disable file_length

class HomeViewController: UIViewController {
    
    private let mapVC = MapViewController()
    
    private var locationManager: CLLocationManager?
    
    private var locationAlertController: UIAlertController?
    
    private let userLocationButton = UIButton()
    
    private let startTrackButton = UIImageView()
    
    private let stopTrackButton = UIImageView()
    
    private var stopWidthAnchor: NSLayoutConstraint!
    
    private var stopHeightAnchor: NSLayoutConstraint!
    
    private let timeIcon = UIImageView()
    
    private let timeLabel = UILabel()
    
    private let distanceIcon = UIImageView()
    
    private let distanceLabel = UILabel()
    
    private let infoBackView = UIView()
    
    private var infoBottomAnchor: NSLayoutConstraint!
    
    private var trackTimer: Timer?
    
    private var stopTimer: Timer?
    
    private var timerDuration: Int = 0
    
    private var distance: Double = 0
    
    private var isTracking = false
    
    private let strangerButton = UIButton()
    
    private let notificationButton = UIButton()
    
    private let choosePetImageView = UIImageView()
    
    private let strangerVC = StrangerViewController()
    
    private var userStoredLocations: [CLLocation] = []
    
    private let mapManager = MapManager.shared
    
    private let userManager = UserManager.shared
    
    private let lottie = LottieWrapper.shared
    
    private var trackStartTime = Timestamp()
    
    private var user: User
    
    private var userPets: [Pet] = []
    
    private var userCurrentPet: Pet? {
        didSet {
            setCurrentPetButton()
        }
    }
    
    private var friendAnnotationsInfo: [String: UserAnnotation] = [:]
    
    private var friendLocations: [String: UserLocation] = [:] {
        didSet {
            updateAnnotation()
        }
    }
    
    private var listeners: [ListenerRegistration] = []
    
    private let noPetAlertController = UIAlertController(
        title: "No Pet",
        message: "",
        preferredStyle: .alert
    )
    
    private let noSelectPetAlertController = UIAlertController(
        title: "Select Pet",
        message: "Cannot track without pet, please select pet.",
        preferredStyle: .alert
    )
    
    private let locationHelper = LocationHelper()
    
    init() {
        
        self.user = userManager.currentUser ?? userManager.guestUser
        
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
        setLocationAlert()
        setNoPetAlert()
        setNoSelectPetAlert()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true

        checkAuth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard locationManager?.authorizationStatus != .denied &&
                locationManager?.authorizationStatus != .restricted &&
                locationManager?.authorizationStatus != .notDetermined else {
            
            return
        }        
        mapVC.mapView.userTrackingMode = .follow
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
        
        listeners.forEach { $0.remove() }
        
        mapVC.mapView.removeAnnotations(mapVC.mapView.annotations)
        
        locationAlertController = nil
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
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.distanceFilter = 20
        locationManager?.checkLocationPermission()
        
        choosePetImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapChoosePet)))
        
        choosePetImageView.isUserInteractionEnabled = true
        
        userLocationButton.addTarget(self, action: #selector(didSelectUserLocation), for: .touchUpInside)

        strangerButton.addTarget(self, action: #selector(didTapStrangerButton), for: .touchUpInside)
        
        notificationButton.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)
        
        setupTrackButton()
    }
    
    private func style() {
        
        userLocationButton.setImage(UIImage.asset(.Icons_60px_UserLocate), for: .normal)
        
        startTrackButton.image = UIImage.asset(.Icons_90px_Start)
        stopTrackButton.image = UIImage.asset(.Icons_90px_Stop)
        
        strangerButton.setImage(UIImage.asset(.Icons_60px_Stranger), for: .normal)
        
        timeIcon.image = UIImage.asset(.Icons_24px_Clock)
        
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        timeLabel.textAlignment = .center
        timeLabel.text = "00:00:00"

        distanceIcon.image = UIImage.asset(.Icons_24px_Distance)
        
        distanceLabel.textColor = .white
        distanceLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        distanceLabel.textAlignment = .center
        distanceLabel.text = "0.00 km"
        
        infoBackView.backgroundColor = .BattleGrey
    }
    
    private func layout() {
        
        add(mapVC)
        view.addSubview(userLocationButton)
        view.addSubview(stopTrackButton)
        view.addSubview(startTrackButton)
        view.addSubview(infoBackView)
        view.addSubview(strangerButton)
        view.addSubview(notificationButton)
        view.addSubview(choosePetImageView)
        
        mapVC.view.anchor(top: view.topAnchor,
                       leading: view.leadingAnchor,
                       bottom: view.safeAreaLayoutGuide.bottomAnchor,
                       trailing: view.trailingAnchor)
        
        userLocationButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                  trailing: view.trailingAnchor,
                                  width: 36,
                                  height: 36,
                                  padding: UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 35))
        
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
        
        infoBackView.anchor(leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            height: view.safeAreaInsets.top + 90,
                            padding: UIEdgeInsets(top: 0, left: 116, bottom: 0, right: 116))
        
        infoBottomAnchor = infoBackView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        infoBottomAnchor.isActive = true
        
        let timeHStack = UIStackView(arrangedSubviews: [timeIcon, timeLabel])
        timeHStack.axis = .horizontal
        timeHStack.distribution = .fillProportionally
        timeHStack.spacing = 5
        
        timeIcon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let distanceHStack = UIStackView(arrangedSubviews: [distanceIcon, distanceLabel])
        distanceHStack.axis = .horizontal
        distanceHStack.distribution = .fillProportionally
        distanceHStack.spacing = 5
        
        timeIcon.constrainWidth(constant: 20)
        timeIcon.constrainHeight(constant: 20)
        
        distanceIcon.constrainWidth(constant: 20)
        distanceIcon.constrainHeight(constant: 20)
        
        distanceIcon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        infoBackView.addSubview(timeHStack)
        infoBackView.addSubview(distanceHStack)
        
        timeHStack.anchor(leading: infoBackView.leadingAnchor,
                          bottom: infoBackView.centerYAnchor,
                          trailing: infoBackView.trailingAnchor,
                            padding: UIEdgeInsets(top: 0, left: 16, bottom: 5, right: 16))
        
        distanceHStack.anchor(top: infoBackView.centerYAnchor,
                              leading: timeHStack.leadingAnchor,
                              trailing: timeHStack.trailingAnchor,
                            padding: UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0))
        
        strangerButton.setRadiusWithShadow()
        
        notificationButton.setRadiusWithShadow()
        
        userLocationButton.setRadiusWithShadow()
        
        startTrackButton.setRadiusWithShadow()
        
        stopTrackButton.setRadiusWithShadow()
        
        infoBackView.setRadiusWithShadow(20)
        
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
            
            print(user)
            
            getUserPets(user: user)
            
            listenFriendsLocation()
            
            notificationButton.isHidden = false
            
            checkFriendRequest()

        } else {
            userCurrentPet = nil
            
            userPets = []
            
            listeners.forEach { $0.remove() }
            
            friendAnnotationsInfo = [:]
            
            friendLocations = [:]
            
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
            mapManager.changeUserStatus(userId: user.id,
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
        
        userManager.fetchPets(userId: user.id) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.userPets = pets
                self?.getCurrentPet(user: user)
                
                print(pets)
                
            case .failure:
                
                self?.lottie.showError(errorMessage: "Network Unstable")
            }
        }
    }
    
    private func getCurrentPet(user: User) {
        
        userManager.fetchUserLocation(userId: user.id) { [weak self] result in
            switch result {
                
            case .success(let userLocation):
                
                guard let self = self else { return }
                
                if self.userPets.contains(where: {$0.id == userLocation.currentPetId}) {
                    
                    self.userPets.forEach({ pet in
                        
                        if pet.id == userLocation.currentPetId {
                            
                            self.userCurrentPet = pet
                        }
                    })
                } else {
                    
                    self.userCurrentPet = nil
                }
            case .failure:
                
                self?.userCurrentPet = nil
            }
        }
    }
    
    private func setCurrentPetButton() {
        
        if let userCurrentPet = userCurrentPet {
            
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
    
    @objc private func didSelectUserLocation() {
        
        guard locationManager?.authorizationStatus != .denied &&
                locationManager?.authorizationStatus != .restricted &&
                locationManager?.authorizationStatus != .notDetermined else {
            
            if let locationAlertController = locationAlertController,
                    !locationAlertController.isBeingPresented {
                present(locationAlertController, animated: true)
            }
            return
        }
        
        userLocationButton.isSelected = true
        
        mapVC.focusUserLocation()
        
        mapVC.mapView.userTrackingMode = .follow
    }
    
    @objc private func didTapStartTrack() {
        
        guard Auth.auth().currentUser != nil else {
            
            NotificationCenter.default.post(name: .showSignInView, object: .none)
            return
        }
        
        guard !user.petsId.isEmpty else {
            
            guard !noPetAlertController.isBeingPresented else { return }
            
            noPetAlertController.message = "Cannot track without Pet. Going to add Pet."
            present(noPetAlertController, animated: true)
            return
        }
        
        guard userCurrentPet != nil else {
            
            present(noSelectPetAlertController, animated: true)
            return
        }
        
        guard locationManager?.authorizationStatus != .denied &&
                locationManager?.authorizationStatus != .restricted &&
                locationManager?.authorizationStatus != .notDetermined else {
            
            if let locationAlertController = locationAlertController,
                    !locationAlertController.isBeingPresented {
                present(locationAlertController, animated: true)
            }
            return
        }
        
        isTracking = true
        
        trackTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            
            guard let self = self else { return }
            
            self.timerDuration += 1
            
            self.timeLabel.text = TimeInterval(self.timerDuration).timeString()
        })
        
        beTracking()
        
        locationManager?.startUpdatingLocation()
        locationManager?.startUpdatingHeading()
        trackStartTime = Timestamp(date: Date())
        
        self.infoBottomAnchor.constant = self.view.safeAreaInsets.top +
                                              self.infoBackView.frame.height
        
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

        let coordinate = userStoredLocations.map { $0.coordinate }
        let track = coordinate.map { $0.transferToGeopoint() }

        guard let userCurrentPet = userCurrentPet,
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
    
    private func stopUpdateLocation() {
        
        locationManager?.stopUpdatingLocation()
        locationManager?.stopUpdatingHeading()
        
        userStoredLocations = []
        
        mapManager.changeUserStatus(userId: user.id, status: .unTrack)
    }
    
    private func resetTrack() {
        
        timerDuration = 0
        timeLabel.text = "00:00:00"
        trackTimer?.invalidate()
        trackTimer = nil
        distance = 0
        distanceLabel.text = "0.00 km"
        isTracking = false
        
        notTracking()

        stopUpdateLocation()
        mapVC.mapView.removeOverlays(self.mapVC.mapView.overlays)
        
        infoBottomAnchor.constant = 0
    }
    
    @objc private func updateCurrentPet() {

        resetTrack()
        getCurrentPet(user: user)
    }
    
    @objc private func didTapChoosePet() {
        
        guard !user.petsId.isEmpty else {
            
            noPetAlertController.message = "No pet to select.??????"
            present(noPetAlertController, animated: true)
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
        
        mapManager.fetchStrangerLocations(friend: user.friends, blockIds: user.blockUsersId) { [weak self] result in
            
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
            
            self.userManager.fetchPets(userId: userId) { result in
                
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
    
    private func listenFriendsLocation() {
        
        if listeners.count != 0 {
            
            listeners.forEach { $0.remove() }
        }

        let friends = user.friends
        
        for friend in friends {
            
           let listener = mapManager.listenFriendsLocation(friend: friend) { [weak self] result in
                
                switch result {
                    
                case .success(let friendlocation):
                    
                    self?.friendLocations[friendlocation.userId] = friendlocation
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
            listeners.append(listener)
        }
    }
    
    private func updateAnnotation() {
        
        mapVC.mapView.removeAnnotations(mapVC.mapView.annotations)
        
        for friend in friendLocations.values {
            
            if friend.status == Status.tracking.rawValue {
            
                let annotation = UserAnnotation(coordinate: friend.location.transferToCoordinate2D(),
                                                title: friend.petName,
                                                subtitle: friend.userName,
                                                userId: friend.userId,
                                                petPhoto: friend.petPhoto)
                
                friendAnnotationsInfo[friend.userId] = annotation
            } else {
                
                friendAnnotationsInfo.removeValue(forKey: friend.userId)
            }
        }
        for friendAnnotationInfo in friendAnnotationsInfo {
                
            mapVC.mapView.addAnnotation(friendAnnotationInfo.value)
        }
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {

           UIApplication.shared.open(settingsUrl)
         }
    }
    
    private func setLocationAlert() {
        
        locationAlertController = UIAlertController(
            title: "Allow \"PawKing\" To Access Your Location While You Use The App.",
            message: "PawKing requires your precise location to track your pet walks which you could check out later " +
                      "and provide you feature of showing the pets near by you. " +
                      "We will not disclose any location of you to others.",
            preferredStyle: .alert)
        locationAlertController?.view.tintColor = .BattleGrey
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        locationAlertController?.addAction(cancelAction)
        
        let settingAction = UIAlertAction(title: "Settings", style: .default) { _ in
            self.openAppSettings()
        }
        locationAlertController?.addAction(settingAction)
    }
    
    private func setNoPetAlert() {
        
        let noPetCancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            
            guard Auth.auth().currentUser != nil else {
                
                NotificationCenter.default.post(name: .showSignInView, object: .none)
                return
            }
            self.tabBarController?.selectedIndex = 4
        })
        noPetAlertController.view.tintColor = .BattleGrey
        
        noPetAlertController.addAction(noPetCancelAction)
    }
    
    private func setNoSelectPetAlert() {
        
        let noSelectPetCancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            
            self.didTapChoosePet()
        })
        noSelectPetAlertController.view.tintColor = .BattleGrey
        
        noSelectPetAlertController.addAction(noSelectPetCancelAction)
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

extension HomeViewController: ChoosePetViewDelegate {
    
    func didChoosePet(with selectedPet: Pet) {
        
        self.userCurrentPet = selectedPet
        
        userManager.updateCurrentPet(userId: user.id, pet: selectedPet) { result in
            
            switch result {
                
            case .success:
                
                print("=== Change current Pet complete")
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let locationStatus = manager.authorizationStatus

        switch locationStatus {

        case .restricted, .denied:

            locationManager?.requestWhenInUseAuthorization()

        default:

            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let currentLocation = locations.first(where: { $0.horizontalAccuracy >= 0 }) else {
                return
            }
        
        let previousCoordinate = userStoredLocations.last?.coordinate
        
        userStoredLocations.append(currentLocation)
        
        if previousCoordinate == nil { return }

        var coordinates = [previousCoordinate!, currentLocation.coordinate]
        
        distance += locationHelper.computeDistance(from: coordinates) / 1000
        
        distanceLabel.text = "\(String(format: "%.2f", distance)) km"
    
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)

        mapVC.mapView.addOverlay(polyline, level: .aboveLabels)
        
        guard let location = locations.last?.coordinate,
              let currentPet = userCurrentPet
        else {
            return
        }
        
        let userLocation = UserLocation(userId: user.id,
                                        userName: user.name,
                                        userPhoto: user.userImage,
                                        currentPetId: currentPet.id,
                                        petName: currentPet.name,
                                        petPhoto: currentPet.petImage,
                                        location: location.transferToGeopoint(),
                                        status: Status.tracking.rawValue)
        
        userManager.updateUserLocation(location: userLocation) { result in
            
            switch result {
                
            case .success:
                
                print("===renew success")
                
            case.failure(let error):
                
                print(error)
            }
        }
    }
}
// swiftlint:enable file_length
