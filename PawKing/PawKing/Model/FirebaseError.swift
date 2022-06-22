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
    
    case fetchUserError
    
    case fetchUserLocationError
    
    case fetchPetError
    
    case fetchPostError
    
    case fetchCommentError
    
    case fetchTrackError
    
    case fetchFriendError
    
    case fetchStangerError
    
    case uploadUserPhotoError
    
    case uploadTrackError
    
    case updateLocationError
    
    case updateUserInfoError
    
    case decodeUserError
    
    case decodePetError
    
    case decodePostError
    
    case decodeCommentError
    
    case decodeTrackError
    
    var errorMessage: String {
        
        switch self {
            
        case .setupUserError:
            
            return "建立使用者資料失敗"
            
        case .setupPetError:
            
            return "建立寵物資料失敗"
            
        case .setupPostError:
            
            return "建立貼文失敗"
            
        case .setupCommentError:
            
            return "建立評論失敗"
            
        case .fetchUserError:
            
            return "讀取使用者資料失敗"
            
        case .fetchPetError:
            
            return "讀取寵物資料失敗"
            
        case .fetchPostError:
            
            return "讀取貼文失敗"
            
        case .fetchCommentError:
            
            return "讀取留言失敗"
            
        case .fetchUserLocationError:
            
            return "讀取使用者已儲存位置失敗"
            
        case .fetchTrackError:
            
            return "讀取軌跡失敗"
            
        case .fetchFriendError:
            
            return "無法讀取朋友位置"
            
        case .fetchStangerError:
            
            return "無法讀取陌生人位置"
            
        case .uploadUserPhotoError:
            
            return "上傳使用者照片失敗"
            
        case.uploadTrackError:
            
            return "上傳軌跡失敗"
            
        case .updateLocationError:
            
            return "更新位置狀態失敗"
            
        case .updateUserInfoError:
            
            return "更新使用者資料失敗"
            
        case .decodeUserError:
            
            return "無法解析使用者資料"
            
        case .decodePetError:
            
            return "無法解析寵物資料"
            
        case .decodePostError:
            
            return "無法解析貼文資料"
            
        case .decodeTrackError:
            
            return "無法解析軌跡"
            
        case .decodeCommentError:
            
            return "無法解析留言"
        }
    }
}
