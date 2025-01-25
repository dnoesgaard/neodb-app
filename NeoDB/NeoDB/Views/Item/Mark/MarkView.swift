//
//  MarkView.swift
//  NeoDB
//
//  Created by citron on 1/15/25.
//

import Parchment
import SwiftUI
import SwiftUIIntrospect

struct MarkView: View {
    @StateObject private var viewModel: MarkViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var accountsManager: AppAccountsManager
    @State private var showAdvanced = false
    @State private var detent: PresentationDetent = .fraction(0.7)

    init(
        item: any ItemProtocol, mark: MarkSchema? = nil,
        shelfType: ShelfType? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: MarkViewModel(
                item: item, mark: mark, shelfType: shelfType))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom title bar
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(viewModel.title)
                            .font(.headline)
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom)
                    .padding(.leading, 4)
                    shelfTypeButtons
                }
                .padding(.bottom)
                
                TabView(
                    selection: Binding(
                        get: { viewModel.shelfType },
                        set: { viewModel.shelfType = $0 }
                    )
                ) {
                    ForEach(ShelfType.allCases, id: \.self) { type in
                        if type == .wishlist {
                            markContentView
                                .tag(type)
                        } else {
                            markContentViewWithRating
                                .tag(type)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                if viewModel.existingMark != nil {
                    deleteButton
                } else {
                    deleteButton
                        .hidden()
                }
                
                NavigationLink {
                    Form {
                        Section {
                            Picker("Visibility", selection: $viewModel.visibility) {
                                ForEach(MarkVisibility.allCases, id: \.self) { visibility in
                                    Label {
                                        Text(visibility.displayText)
                                    } icon: {
                                        Image(symbol: visibility.symbolImage)
                                    }
                                    .tag(visibility)
                                    .labelStyle(.titleAndIcon)
                                }
                            }
                            .tint(.accentColor)


                            Toggle(
                                String(localized: "mark_share_fediverse_toggle", table: "Item"),
                                isOn: $viewModel.postToFediverse)
                            .tint(.accentColor)
                        }
                        Section (header: Text("Advanced")) {
                            Toggle(
                                String(localized: "mark_use_change_time_toggle", table: "Item"),
                                isOn: $viewModel.changeTime)
                            .tint(.accentColor)

                            if viewModel.changeTime {
                                DatePicker(
                                    String(localized: "mark_change_time_picker_label", table: "Item"),
                                    selection: $viewModel.createdTime,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                            }
                        }
                    }
                    .background(.ultraThinMaterial)
                    .compositingGroup()
                    .scrollContentBackground(.hidden)
                    .navigationTitle(String(localized: "mark_advanced_section", table: "Item"))
                } label: {
                    HStack {
                        Text(advancedOptionsLabel)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                VStack(alignment: .center, spacing: 0) {
                    saveButton
                }
                .background(.ultraThinMaterial)
                .compositingGroup()
            }
            .background(.ultraThinMaterial)
            .compositingGroup()
        }
        .navigationTitle(viewModel.title)
        .background(.ultraThinMaterial)
        .compositingGroup()
        .presentationDetents([.fraction(0.7), .large], selection: $detent)
        .presentationDragIndicator(.visible)
        .onChange(of: viewModel.isDismissed) { dismissed in
            if dismissed {
                dismiss()
            }
        }
        .alert(
            String(localized: "mark_error_title", table: "Item"),
            isPresented: $viewModel.showError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
        .task {
            viewModel.accountsManager = accountsManager
        }
        .enableInjection()
    }

    private var shelfTypeButtons: some View {
        TopTabBarView(
            items: ShelfType.allCases,
            selection: Binding(
                get: { viewModel.shelfType },
                set: { newValue in
                    if viewModel.shelfType != newValue {
                        viewModel.shelfType = newValue
                        HapticFeedback.impact(.light)
                    }
                }
            )
        ) { $0.displayName }
    }

    private var markContentView: some View {
        markContentViewBase(paddingTop: true) {
            EmptyView()
        }
    }

    private var markContentViewWithRating: some View {
        markContentViewBase {
            StarRatingView(inputRating: $viewModel.rating)
                .frame(maxWidth: .infinity)
        }
    }

    private func markContentViewBase<Content: View>(
        paddingTop: Bool = false,
        @ViewBuilder header: @escaping () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            VStack {
                header()

                TextEditor(text: $viewModel.comment)
                    .frame(
                        minHeight: detent == .large
                            ? 200 : paddingTop ? 100 : 50,
                        maxHeight: 300
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .overlay {
                        if viewModel.comment.isEmpty {
                            TextEditor(text: .constant("Write a comment..."))
                                .foregroundColor(.secondary)
                                .disabled(true)
                        }
                    }
                    .scrollDisabled(viewModel.comment.isEmpty)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top)
                    .onTapGesture {
                        withAnimation {
                            detent = .large
                        }
                    }

                Spacer()
            }
            .scrollContentBackground(.hidden)
        }
    }

    private var advancedOptionsLabel: String {
        var components: [String] = []
        
        if !viewModel.changeTime {
            if let mark = viewModel.existingMark,
               let date = mark.createdTime.asDate {
                components.append(date.formatted(date: .abbreviated, time: .shortened))
            } else {
                components.append("Now")
            }
        } else {
            components.append(viewModel.createdTime.formatted(date: .abbreviated, time: .shortened))
        }
        
        components.append(viewModel.visibility.displayText)
        
        if viewModel.postToFediverse {
            components.append("Post to fediverse")
        }
        
        return components.joined(separator: " · ")
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            Task {
                await viewModel.deleteMark()
            }
        } label: {
            Label(
                String(localized: "mark_delete_button", table: "Item"),
                systemSymbol: .trash
            )
            .frame(maxWidth: .infinity)
            .labelStyle(.titleOnly)
        }
        .disabled(viewModel.isLoading)
        .padding(.bottom)
    }

    private var saveButton: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await viewModel.saveMark()
                }
            } label: {
                Text("mark_save_button", tableName: "Item")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            .padding(.horizontal)
        }
        .padding(.vertical)
    }

    #if DEBUG
        @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    MarkView(item: ItemSchema.preview)
        .environmentObject(AppAccountsManager())
}
