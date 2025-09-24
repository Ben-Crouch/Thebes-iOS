//
//  MockData.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation

class MockData: ObservableObject {
    static let shared = MockData()
    
    @Published var sampleTemplates: [Template] = [
        Template(
            title: "Push Day Strength",
            userId: ""
        )
    ]
    
    // ✅ Add New Template

    
    // ✅ Update Existing Template
    func updateTemplate(_ updatedTemplate: Template) {
        if let index = sampleTemplates.firstIndex(where: { $0.id == updatedTemplate.id }) {
            sampleTemplates[index] = updatedTemplate
            print("✏️ Updated Template: \(updatedTemplate.title)")
        } else {
            print("⚠️ Template with ID \(updatedTemplate.id ?? "Unknown") not found.")
        }
    }
}
