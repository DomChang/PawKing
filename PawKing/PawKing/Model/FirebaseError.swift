//
//  FirebaseError.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/15.
//

import Foundation

enum FirebaseError: Error {
    
    case setupUserError
    
    case setupPetError
    
    case setupPostError
    
    case setupCommentError
    
    case sendMessageError
    
    case fetchUserError
    
    case fetchUserLocationError
    
    case fetchPetError
    
    case fetchPostError
    
    case fetchCommentError
    
    case fetchTrackError
    
    case fetchFriendError
    
    case fetchStangerError
    
    case fetchMessageError
    
    case uploadUserPhotoError
    
    case uploadTrackError
    
    case updateLocationError
    
    case updateUserInfoError
    
    case decodeUserError
    
    case decodePetError
    
    case decodePostError
    
    case decodeCommentError
    
    case decodeTrackError
    
    case decodeMessageError
    
    case deleteUserError
    
    var errorMessage: String {
        
        switch self {
            
        case .setupUserError:
            
            return "Failed to create user profile"
            
        case .setupPetError:
            
            return "Failed to create pet profile"
            
        case .setupPostError:
            
            return "Failed to create post"
            
        case .setupCommentError:
            
            return "Failed to comment"
            
        case .sendMessageError:
            
            return "Failed to send message"
            
        case .fetchUserError:
            
            return "Failed to read user data"
            
        case .fetchPetError:
            
            return "Failed to read pet data"
            
        case .fetchPostError:
            
            return "Failed to read data"
            
        case .fetchCommentError:
            
            return "Failed to read data"
            
        case .fetchUserLocationError:
            
            return "Failed to get user location"
            
        case .fetchTrackError:
            
            return "Failed to get track data"
            
        case .fetchFriendError:
            
            return "Failed to get friend data"
            
        case .fetchStangerError:
            
            return "Failed to get stranger data"
            
        case .fetchMessageError:
            
            return "Unable to get message"
            
        case .uploadUserPhotoError:
            
            return "Failed to upload user photo"
            
        case.uploadTrackError:
            
            return "Failed to upload track"
            
        case .updateLocationError:
            
            return "Failed to update location"
            
        case .updateUserInfoError:
            
            return "Failed to update user data"
            
        case .decodeUserError:
            
            return "Failed to decode user data"
            
        case .decodePetError:
            
            return "Failed to decode pet data"
            
        case .decodePostError:
            
            return "Failed to decode post data"
            
        case .decodeTrackError:
            
            return "Failed to decode track data"
            
        case .decodeCommentError:
            
            return "Failed to decode comment data"
            
        case .decodeMessageError:
            
            return "Failed to decode message"
            
        case .deleteUserError:
            
            return "Delete user error"
        }
    }
}
