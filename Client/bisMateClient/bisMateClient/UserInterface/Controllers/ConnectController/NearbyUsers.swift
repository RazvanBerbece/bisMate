//
//  NearbyUsers.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 08/08/2021.
//

import Foundation

// A container class that manages the list of nearby users gathered from the DB
class NearbyUsers {
    
    private var users : [bisMateClient.User]?
    private var count : Int?
    
    init(users: [bisMateClient.User], count: Int) {
        self.users = users
        self.count = count
    }
    
    /** Getters */
    public func getUsers() -> [User] {
        return self.users!
    }
    public func getCount() -> Int {
        return count!
    }
    
    /** Setters */
    public func pushUser(user: User) { // on download
        self.users?.append(user)
        self.incrementCount()
    }
    public func removeUser(deleteUser: User) { // on swipe left
        for (index, user) in self.users!.enumerated() {
            if user.getUID() == deleteUser.getUID() {
                self.users?.remove(at: index)
            }
        }
    }
    private func incrementCount() {
        self.count! += 1
    }
    
}
