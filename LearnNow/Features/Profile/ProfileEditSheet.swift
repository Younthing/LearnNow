import SwiftUI

struct ProfileEditSheet: View {
    let initialDisplayName: String
    let initialAvatarID: String
    let onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var displayName: String
    @State private var selectedAvatarID: String
    @FocusState private var isNameFocused: Bool

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    init(
        initialDisplayName: String,
        initialAvatarID: String,
        onSave: @escaping (String, String) -> Void
    ) {
        self.initialDisplayName = initialDisplayName
        self.initialAvatarID = initialAvatarID
        self.onSave = onSave
        _displayName = State(initialValue: initialDisplayName)
        _selectedAvatarID = State(initialValue: initialAvatarID)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("昵称")
                            .font(LearnNowTypography.cardTitle)
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        TextField("学习者", text: $displayName)
                            .focused($isNameFocused)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(LearnNowTypography.body)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(LearnNowPalette.base)
                                    .modifier(InsetSurface(cornerRadius: 16))
                            )
                            .accessibilityIdentifier("profile.name.field")
                            .onChange(of: displayName) { _, newValue in
                                if newValue.count > 12 {
                                    displayName = String(newValue.prefix(12))
                                }
                            }

                        Text("\(displayName.count)/12")
                            .font(LearnNowTypography.metadata)
                            .foregroundStyle(LearnNowPalette.textMuted)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("选择头像")
                            .font(LearnNowTypography.cardTitle)
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(AvatarOption.all) { avatar in
                                Button {
                                    selectedAvatarID = avatar.id
                                } label: {
                                    ZStack(alignment: .bottomTrailing) {
                                        Image(avatar.assetName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .aspectRatio(1, contentMode: .fit)
                                            .clipShape(Circle())
                                            .overlay {
                                                Circle()
                                                    .stroke(
                                                        selectedAvatarID == avatar.id
                                                            ? LearnNowPalette.color(for: .blue)
                                                            : .white.opacity(0.7),
                                                        lineWidth: selectedAvatarID == avatar.id ? 3 : 1
                                                    )
                                            }

                                        if selectedAvatarID == avatar.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title3.weight(.bold))
                                                .foregroundStyle(LearnNowPalette.color(for: .blue))
                                                .background(.white, in: Circle())
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(avatar.name)
                                .accessibilityValue(selectedAvatarID == avatar.id ? "已选择" : "")
                                .accessibilityIdentifier("profile.avatar.\(avatar.id)")
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(LearnNowPalette.canvas.ignoresSafeArea())
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(trimmedDisplayName, selectedAvatarID)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(!canSave)
                    .accessibilityIdentifier("profile.edit.save")
                }
            }
        }
    }

    private var trimmedDisplayName: String {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        (1...12).contains(trimmedDisplayName.count)
    }
}
