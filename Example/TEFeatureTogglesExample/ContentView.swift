//
//  ContentView.swift
//  TEFeatureTogglesExample
//
//  Created by Anastasia on 29.08.2023.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ContentViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            header
            
            Divider()
            
            featureTogglesList
            
            Spacer()
        }
    }
}

// MARK: - Nested Views

extension ContentView {
    
    private var header: some View {
        HStack {
            Text("Feature name")
            
            Spacer()
            
            Text("Value")
        }
        .padding()
    }
    
    private var featureTogglesList: some View {
        ForEach(viewModel.features) { feature in
            HStack {
                Text(feature.name)
                
                Spacer()
                
                Text(feature.isEnabled ? "enabled" : "disabled")
            }
            .padding()
            
            Divider()
        }
    }
    
}
