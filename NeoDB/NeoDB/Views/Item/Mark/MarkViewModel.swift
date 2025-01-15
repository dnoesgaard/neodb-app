//
//  MarkViewModel.swift
//  NeoDB
//
//  Created by citron on 1/15/25.
//

import Foundation
import OSLog

@MainActor
class MarkViewModel: ObservableObject {
    private let logger = Logger.views.mark
    
    let item: (any ItemProtocol)
    let existingMark: MarkSchema?
    
    @Published var shelfType: ShelfType = .wishlist
    @Published var rating: Int?
    @Published var comment: String = ""
    @Published var isPublic: Bool = true
    @Published var postToFediverse: Bool = false
    @Published var createdTime: Date = Date()
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showError = false
    @Published var isDismissed = false
    
    var accountsManager: AppAccountsManager?
    
    init(item: any ItemProtocol, mark: MarkSchema? = nil) {
        self.item = item
        self.existingMark = mark
        
        if let mark = mark {
            self.shelfType = mark.shelfType
            self.rating = mark.ratingGrade
            self.comment = mark.commentText ?? ""
            self.isPublic = mark.visibility == 0
            if let date = mark.createdTime.asDate {
                self.createdTime = date
            }
        }
    }
    
    var title: String {
        existingMark == nil ? "Add to Shelf" : "Edit Mark"
    }
    
    func saveMark() async {
        guard let accountsManager = accountsManager else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let mark = MarkInSchema(
                shelfType: shelfType,
                visibility: isPublic ? 0 : 1,
                commentText: comment.isEmpty ? nil : comment,
                ratingGrade: rating,
                tags: [],
                createdTime: existingMark != nil ? ServerDate.from(createdTime) : nil,
                postToFediverse: postToFediverse
            )
            
            let endpoint = MarkEndpoint.mark(itemId: item.uuid, mark: mark)
            _ = try await accountsManager.currentClient.fetch(endpoint, type: MessageSchema.self)
            
            isDismissed = true
        } catch {
            self.error = error
            self.showError = true
            logger.error("Failed to save mark: \(error.localizedDescription)")
        }
    }
    
    func deleteMark() async {
        guard let accountsManager = accountsManager,
              existingMark != nil else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let endpoint = MarkEndpoint.delete(itemId: item.uuid)
            _ = try await accountsManager.currentClient.fetch(endpoint, type: MessageSchema.self)
            
            isDismissed = true
        } catch {
            self.error = error
            self.showError = true
            logger.error("Failed to delete mark: \(error.localizedDescription)")
        }
    }
} 
