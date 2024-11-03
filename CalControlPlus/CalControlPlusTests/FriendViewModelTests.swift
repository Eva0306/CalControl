//
//  FriendViewModelTests.swift
//  CalControlPlusTests
//
//  Created by 楊芮瑊 on 2024/10/7.
//

import XCTest
import FirebaseCore
@testable import CalControlPlus

class MockFirebaseManager: FirebaseManagerProtocol {
    var mockUsers: [User] = []
    
    func getDocuments<T: Decodable>(
        from collection: FirestoreEndpoint,
        where conditions: [FirestoreCondition],
        completion: @escaping ([T]) -> Void
    ) {
        if let users = mockUsers as? [T] {
            completion(users)
        } else {
            completion([])
        }
    }
}

final class FriendViewModelTests: XCTestCase {
    
    var viewModel: FriendViewModel!
    var mockFirebaseManager: MockFirebaseManager!
    let mockUserId = "user123"
    
    override func setUpWithError() throws {
        mockFirebaseManager = MockFirebaseManager()
        viewModel = FriendViewModel(firebaseManager: mockFirebaseManager)
    }
    
    override func tearDownWithError() throws {
        mockFirebaseManager = nil
        viewModel = nil
    }
    
    func testFetchFriendData_withFriends() {
        let mockFriendAccepted = Friend(
            userID: "1",
            addedAt: Timestamp(date: Date()),
            status: "accepted",
            isFavorite: false
        )
        let mockFriendBlocked = Friend(
            userID: "2",
            addedAt: Timestamp(date: Date()),
            status: "blocked",
            isFavorite: false
        )
        let mockFriendPending = Friend(
            userID: "3",
            addedAt: Timestamp(date: Date()),
            status: "pending",
            isFavorite: false
        )
        
        let mockUser = User(
            id: "user123",
            status: .active,
            createdTime: Timestamp(date: Date()),
            email: "test@example.com",
            name: "Test User",
            avatarUrl: nil,
            gender: .male,
            birthday: "1990-01-01",
            height: 175.0,
            weightRecord: [],
            activity: .sedentary,
            target: .maintainWeight,
            totalNutrition: [],
            friends: [mockFriendAccepted, mockFriendBlocked, mockFriendPending]
        )
        
        mockFirebaseManager.mockUsers = [mockUser]
        
        let expectation = self.expectation(description: "Fetch friends data")
        
        viewModel.fetchFriendData(userID: mockUserId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.friends, [mockFriendAccepted])
            XCTAssertEqual(self.viewModel.blockFriends, [mockFriendBlocked])
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchFriendData_withNoFriends() {
        let mockUserWithoutFriends = User(
            id: "user456",
            status: .active,
            createdTime: Timestamp(date: Date()),
            email: "nofriends@example.com",
            name: "No Friends User",
            avatarUrl: nil,
            gender: .female,
            birthday: "1985-05-05",
            height: 160.0,
            weightRecord: [],
            activity: .light,
            target: .gainWeight,
            totalNutrition: [],
            friends: nil
        )
        
        mockFirebaseManager.mockUsers = [mockUserWithoutFriends]
        
        viewModel.fetchFriendData(userID: mockUserId)
        
        XCTAssertEqual(viewModel.friends, [])
        XCTAssertEqual(viewModel.blockFriends, [])
    }
    
    func testFetchFriendData_withEmptyFriends() {
        let mockUserWithEmptyFriends = User(
            id: "user789",
            status: .active,
            createdTime: Timestamp(date: Date()),
            email: "emptyfriends@example.com",
            name: "Empty Friends User",
            avatarUrl: nil,
            gender: .female,
            birthday: "1995-12-12",
            height: 170.0,
            weightRecord: [],
            activity: .active,
            target: .loseWeight,
            totalNutrition: [],
            friends: []
        )
        
        mockFirebaseManager.mockUsers = [mockUserWithEmptyFriends]
        
        viewModel.fetchFriendData(userID: mockUserId)
        
        XCTAssertEqual(viewModel.friends, [])
        XCTAssertEqual(viewModel.blockFriends, [])
    }
}
