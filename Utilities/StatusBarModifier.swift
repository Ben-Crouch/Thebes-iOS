//
//  StatusBarModifier.swift
//  Thebes
//
//  Created to force light status bar content
//

import SwiftUI

// UIViewController wrapper to properly set status bar style
struct StatusBarStyleView: UIViewControllerRepresentable {
    var style: UIStatusBarStyle
    
    func makeUIViewController(context: Context) -> StatusBarViewController {
        StatusBarViewController(style: style)
    }
    
    func updateUIViewController(_ uiViewController: StatusBarViewController, context: Context) {
        uiViewController.updateStatusBarStyle(style)
    }
}

class StatusBarViewController: UIViewController {
    private var currentStyle: UIStatusBarStyle = .lightContent
    
    init(style: UIStatusBarStyle) {
        self.currentStyle = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateStatusBarStyle(_ style: UIStatusBarStyle) {
        currentStyle = style
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentStyle
    }
}

