//
//  TemplateService.swift
//  Thebes
//
//  Created by Ben on 20/03/2025.
//

import FirebaseFirestore
import Foundation

class TemplateService {
    static let shared = TemplateService()
    private let db = Firestore.firestore()
    
    // Save a template to Firestore
    func saveTemplate(template: Template, completion: @escaping (Result<String, Error>) -> Void) {
        let templateRef = db.collection("templates").document() // Auto-generate ID
        
        let templateData: [String: Any] = [
            "userId": template.userId,
            "title": template.title
        ]
        
        templateRef.setData(templateData) { error in
            if let error = error {
                print("❌ Error saving template: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Template saved successfully with ID: \(templateRef.documentID)")
                completion(.success(templateRef.documentID))
            }
        }
    }
    
    func fetchTemplates(for userId: String, completion: @escaping (Result<[Template], Error>) -> Void) {
        db.collection("templates")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let templates = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Template.self)
                    } ?? []
                    completion(.success(templates))
                }
            }
    }
    
    func updateTemplate(template: Template, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let templateId = template.id else {
            completion(.failure(NSError(domain: "TemplateService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Template ID is missing."])))
            return
        }

        let templateRef = db.collection("templates").document(templateId)
        
        let updatedData: [String: Any] = [
            "title": template.title,
            "userId": template.userId
        ]

        templateRef.updateData(updatedData) { error in
            if let error = error {
                print("❌ Error updating template: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Template updated successfully")
                completion(.success(()))
            }
        }
    }
    
    func deleteTemplate(templateId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("templates").document(templateId).delete { error in
            if let error = error {
                print("❌ Error deleting template: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Template deleted successfully")
                completion(.success(()))
            }
        }
    }

}
