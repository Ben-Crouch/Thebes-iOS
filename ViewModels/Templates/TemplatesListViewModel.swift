//
//  TemplatesListViewModel.swift
//  Thebes
//
//  Created by Ben on 20/03/2025.
//

import Foundation

class TemplatesListViewModel: ObservableObject {
    @Published var templates: [Template] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profileImageUrl: String?
    @Published var username: String = "User"
    @Published var templateCount: Int = 0
    
    private var userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func updateUserId(_ newUserId: String) {
        self.userId = newUserId
    }
    
    func loadTemplates() {
        isLoading = true
        errorMessage = nil
        
        TemplateService.shared.fetchTemplates(for: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let templates):
                    self?.templates = templates
                    self?.templateCount = templates.count
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error loading templates: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadUserProfile() {
        UserService.shared.fetchUserProfile(userId: userId) { [weak self] userProfile in
            DispatchQueue.main.async {
                guard let profile = userProfile else {
                    print("❌ Error loading user profile: Profile not found")
                    return
                }
                self?.username = profile.displayName
                self?.profileImageUrl = profile.profilePic
            }
        }
    }
    
    func deleteTemplate(at index: Int) {
        guard index < templates.count else { return }
        let template = templates[index]
        
        guard let templateId = template.id else { return }
        
        TemplateService.shared.deleteTemplate(templateId: templateId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.templates.remove(at: index)
                    self?.templateCount = self?.templates.count ?? 0
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error deleting template: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func refreshTemplates() {
        loadTemplates()
    }
}
