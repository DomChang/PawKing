//
//  FirebaseError.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/15.
//

import Foundation

enum FirebaseError: Error {
    
    case setupUserError
    
    case fetchUserError
    
    case uploadTrackError
    
    case updateLocationError
    
    case fetchFriendError
    
    case decodeUserError
    
    var errorMessage: String {
        
        switch self {
            
        case .setupUserError:
            
            return "建立個人資料失敗"
            
        case .fetchUserError:
            
            return "獲取個人資料失敗"
            
        case.uploadTrackError:
            
            return "上傳軌跡失敗"
            
        case .updateLocationError:
            
            return "更新位置狀態失敗"
            
        case .fetchFriendError:
            return "無法讀取朋友位置"
            
        case .decodeUserError:
            return "無法解析使用者資料"
        }
    }
}
