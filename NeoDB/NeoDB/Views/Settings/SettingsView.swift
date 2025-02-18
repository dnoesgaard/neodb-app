//
//  SettingsView.swift
//  NeoDB
//
//  Created by citron(https://github.com/lcandy2) on 1/7/25.
//

import Kingfisher
import OSLog
import SwiftUI
import WishKit

@MainActor
class SettingsViewModel: ObservableObject {
    var accountsManager: AppAccountsManager? {
        didSet {
            if oldValue !== accountsManager {
                user = nil
            }
        }
    }

    @Published var user: User?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isCacheClearing = false
    @Published var showClearCacheConfirmation = false

    private let cacheService = CacheService()
    private let logger = Logger.views.settings

    func loadUserProfile(forceRefresh: Bool = false) async {
        guard accountsManager != nil else { return }

        if forceRefresh {
            isLoading = true
        }
        error = nil

        do {
            user = try await getCurrentUser(forceRefresh: forceRefresh)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    private func getCurrentUser(forceRefresh: Bool = false) async throws -> User
    {
        guard let accountsManager = accountsManager else {
            throw NetworkError.unauthorized
        }

        if !forceRefresh,
            let cachedUser = try? await cacheService.retrieveUser(
                key: accountsManager.currentAccount.id)
        {
            logger.debug(
                "Returning cached user for instance: \(accountsManager.currentAccount.instance)"
            )
            return cachedUser
        }

        guard accountsManager.isAuthenticated else {
            logger.error("No access token available")
            throw NetworkError.unauthorized
        }

        logger.debug("Fetching user profile from network")
        let user = try await accountsManager.currentClient.fetch(
            UserEndpoint.me, type: User.self)

        try? await cacheService.cacheUser(
            user, key: accountsManager.currentAccount.id)
        logger.debug(
            "Cached user profile for instance: \(accountsManager.currentAccount.instance)"
        )

        return user
    }

    func logout() {
        guard let accountsManager = accountsManager else { return }
        Task {
            try? await cacheService.removeUser(
                key: accountsManager.currentAccount.id)
            logger.debug("Cleared user cache")
        }
        accountsManager.delete(account: accountsManager.currentAccount)
    }

    func clearAllCaches() async {
        isCacheClearing = true
        await cacheService.removeAll()
        isCacheClearing = false
    }
}

struct ProfileHeaderView: View {
    let user: User?
    let isLoading: Bool
    let avatarSize: CGFloat

    var body: some View {
        HStack(spacing: 16) {
            if let user = user {
                KFImage(user.avatar)
                    .placeholder {
                        AvatarPlaceholderView(
                            isLoading: isLoading, size: avatarSize)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: avatarSize, height: avatarSize)
                    .clipShape(Circle())
                    .transition(.scale.combined(with: .opacity))
            } else {
                AvatarPlaceholderView(isLoading: isLoading, size: avatarSize)
            }

            VStack(alignment: .leading, spacing: 4) {
                if let user = user {
                    Text(user.displayName)
                        .font(.headline)
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(User.placeholder().displayName)
                        .font(.headline)
                    Text(User.placeholder().username)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .redacted(reason: user == nil || isLoading ? .placeholder : [])
        }
        .enableInjection()
    }

    #if DEBUG
        @ObserveInjection var forceRedraw
    #endif
}

struct AvatarPlaceholderView: View {
    let isLoading: Bool
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: size, height: size)
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.5)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.5))
                        .foregroundStyle(.secondary)
                }
            }
            .enableInjection()
    }

    #if DEBUG
        @ObserveInjection var forceRedraw
    #endif
}

struct SettingsView: View {
    @EnvironmentObject private var accountsManager: AppAccountsManager
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.refresh) private var refresh
    @EnvironmentObject private var router: Router

    private let avatarSize: CGFloat = 60

    init() {
        WishKit.configure(with: AppConfig.wishkitApiKey)
        WishKit.theme.primaryColor = .accent
    }

    // MARK: - Body
    var body: some View {
        Group {
            contentView
        }
        .task {
            viewModel.accountsManager = accountsManager
            await viewModel.loadUserProfile()
        }
        .navigationTitle(String(localized: "settings_title", table: "Settings"))
        .navigationBarTitleDisplayMode(.large)
        #if DEBUG
            .enableInjection()
        #endif
    }

    // MARK: - Content Views
    @ViewBuilder
    private var contentView: some View {
        Group {
            if viewModel.isLoading && viewModel.user == nil {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else {
                profileContent
            }
        }
        .animation(.smooth, value: viewModel.isLoading)
        .animation(.smooth, value: viewModel.error)
    }

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: String) -> some View {
        EmptyStateView(
            "Couldn't Load Profile",
            systemImage: "exclamationmark.triangle",
            description: Text(error)
        )
    }

    private var profileContent: some View {
        List {
            profileHeaderSection
            accountInformationSection
            purchaseSection
            appSection
            cacheManagementSection
            logoutSection
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.loadUserProfile(forceRefresh: true)
        }
        .confirmationDialog(
            Text("cache_clear_button", tableName: "Settings"),
            isPresented: $viewModel.showClearCacheConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear", role: .destructive) {
                Task {
                    await viewModel.clearAllCaches()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("cache_clear_confirmation", tableName: "Settings")
        }
    }

    // MARK: - Section Views
    private var profileHeaderSection: some View {
        Section {
            ProfileHeaderView(
                user: viewModel.user,
                isLoading: viewModel.isLoading,
                avatarSize: avatarSize
            )
        }
    }

    private var accountInformationSection: some View {
        Group {
            if let user = viewModel.user, !user.externalAccounts.isEmpty {
                Section {
                    ForEach(user.externalAccounts, id: \.self) {
                        externalAccount in
                        LabeledContent {
                            Text(externalAccount.handle)
                        } label: {
                            Text(externalAccount.platform.capitalized)
                        }
                    }
                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                } header: {
                    Text("account_title", tableName: "Settings")
                }
            } else if viewModel.user == nil {
                Section {
                    LabeledContent {
                        Text("loading...")
                    } label: {
                        Text("account_external", tableName: "Settings")
                    }
                    .redacted(reason: .placeholder)
                } header: {
                    Text("account_title", tableName: "Settings")
                }
            }
        }
    }

    private var purchaseSection: some View {
        Section {
            NavigationLink {
                PurchaseView()
            } label: {
                Label {
                    Text("app_plus_purchase", tableName: "Settings")
                } icon: {
                    Image(systemName: "bubbles.and.sparkles")
                }
            }
        }
    }

    private var appSection: some View {
        Section {
            NavigationLink {
                WishKit.FeedbackListView()
                    .padding(.bottom)
            } label: {
                Label {
                    Text("app_feature_requests", tableName: "Settings")
                } icon: {
                    Image(systemName: "lightbulb")
                }
            }
            NavigationLink {
                AboutView()
            } label: {
                Label {
                    Text("app_about", tableName: "Settings")
                } icon: {
                    Image(systemName: "info.circle")
                }
            }
        } header: {
            Text("app_title", tableName: "Settings")
        }
    }

    private var cacheManagementSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showClearCacheConfirmation = true
            } label: {
                HStack {
                    if viewModel.isCacheClearing {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text("cache_clear_button", tableName: "Settings")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .disabled(viewModel.isCacheClearing)
        } header: {
            Text("cache_title", tableName: "Settings")
        } footer: {
            Text("cache_clear_footer", tableName: "Settings")
        }
    }

    private var logoutSection: some View {
        Section {
            Button(role: .destructive) {
                withAnimation {
                    viewModel.logout()
                    dismiss()
                }
            } label: {
                Text("signout_button", tableName: "Settings")
                    .frame(maxWidth: .infinity)
            }
            .disabled(viewModel.user == nil)
        }
    }
}
