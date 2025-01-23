//
//  MastodonLoginView.swift
//  NeoDB
//
//  Created by citron on 2/10/25.
//

import SwiftUI
import AuthenticationServices

struct MastodonLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @EnvironmentObject private var accountsManager: AppAccountsManager
    
    @StateObject private var viewModel = MastodonLoginViewModel()
    
    // Animation states
    @State private var inputScale = 0.9
    @State private var contentOpacity = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            stepperView
            
            if viewModel.currentStep == 1 {
                mastodonInstanceStep
            } else {
                neodbInstanceStep
            }
            
            actionButton
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showInstanceInput) {
            InstanceInputView(
                selectedInstance: accountsManager.currentAccount.instance
            ) { newInstance in
                viewModel.updateNeoDBInstance(newInstance)
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .task {
            viewModel.accountsManager = accountsManager
            
            // Trigger animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                inputScale = 1.0
                contentOpacity = 1.0
            }
            
            // Load initial instances
            await viewModel.loadInitialInstances()
        }
        .enableInjection()
    }
    
    // MARK: - Subviews
    private var stepperView: some View {
        HStack {
            StepIndicator(
                step: 1,
                title: "Mastodon Instance",
                isActive: viewModel.currentStep == 1,
                isCompleted: viewModel.currentStep > 1
            )
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.3))
            
            StepIndicator(
                step: 2,
                title: "NeoDB Instance",
                isActive: viewModel.currentStep == 2,
                isCompleted: viewModel.currentStep > 2
            )
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var mastodonInstanceStep: some View {
        VStack(spacing: 8) {
            Text("Enter Mastodon Instance")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enter your Mastodon instance to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Instance")
                    .font(.headline)
                
                TextField("mastodon.social", text: $viewModel.mastodonInstance)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.mastodonInstance) { _ in
                        viewModel.searchInstances()
                    }
            }
            .padding(.top)
            
            // Instance Detail
            if let instance = viewModel.selectedMastodonInstance {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Title and Description
                        VStack(alignment: .leading, spacing: 4) {
                            Text(instance.title)
                                .font(.headline)
                            Text(instance.shortDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Stats
                        HStack(spacing: 16) {
                            StatView(title: "Users", value: instance.stats.userCount)
                            StatView(title: "Posts", value: instance.stats.statusCount)
                            if let languages = instance.languages, !languages.isEmpty {
                                Text(languages.joined(separator: ", "))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Rules if available
                        if let rules = instance.rules, !rules.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Server Rules")
                                    .font(.headline)
                                ForEach(rules) { rule in
                                    Text("• \(rule.text)")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .frame(maxHeight: 300)
            }
            
            // Instance List
            if !viewModel.filteredInstances.isEmpty && viewModel.selectedMastodonInstance == nil {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.filteredInstances) { instance in
                            Button {
                                viewModel.selectInstance(instance)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(instance.domain)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("\(instance.totalUsers) users")
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(instance.description)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.top)
                }
                .frame(maxHeight: 300)
            }
        }
        .padding(.horizontal)
    }
    
    private struct StatView: View {
        let title: String
        let value: Int
        
        var body: some View {
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value.formatted())
                    .font(.subheadline.bold())
            }
        }
    }
    
    private var neodbInstanceStep: some View {
        VStack(spacing: 8) {
            Text("Select NeoDB Instance")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choose your NeoDB instance to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // Instance display
            HStack {
                Text(accountsManager.currentAccount.instance)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Change") {
                    withAnimation {
                        viewModel.showInstanceInput = true
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.top)
            
            // Back to Step 1 Button
            Button(role: .cancel) {
                withAnimation {
                    viewModel.currentStep = 1
                }
            } label: {
                Text("Back to Mastodon Instance")
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
    }
    
    private var actionButton: some View {
        Button(action: {
            if viewModel.currentStep == 1 {
                if viewModel.validateAndContinue() {
                    withAnimation {
                        viewModel.currentStep = 2
                    }
                }
            } else {
                Task {
                    await viewModel.authenticate(using: webAuthenticationSession)
                }
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(viewModel.currentStep == 1 ? "Continue" : "Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal)
        .disabled(viewModel.isLoading || (viewModel.currentStep == 1 && viewModel.mastodonInstance.isEmpty))
    }
    
    #if DEBUG
        @ObserveInjection var forceRedraw
    #endif
}

// MARK: - Step Indicator
struct StepIndicator: View {
    let step: Int
    let title: String
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(backgroundColor)
                .frame(width: 28, height: 28)
                .overlay {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step)")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(isActive ? .white : .secondary)
                    }
                }
            Text(title)
                .font(.caption)
                .foregroundStyle(isActive ? .primary : .secondary)
        }
        .enableInjection()
    }
    
    #if DEBUG
        @ObserveInjection var forceRedraw
    #endif
    
    private var backgroundColor: Color {
        if isActive {
            return .accentColor
        } else {
            return Color(.systemGray5)
        }
    }
} 
