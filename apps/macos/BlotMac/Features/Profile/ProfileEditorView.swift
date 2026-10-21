import SwiftUI

struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let save: (ProfileDetails) -> Void
    @State private var name: String
    @State private var username: String
    @State private var bio: String

    init(details: ProfileDetails, save: @escaping (ProfileDetails) -> Void) {
        self.save = save
        _name = State(initialValue: details.name)
        _username = State(initialValue: details.username)
        _bio = State(initialValue: details.bio)
    }

    private var details: ProfileDetails {
        ProfileDetails(name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                       username: username.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "@")),
                       bio: bio.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit profile").font(KFont.ui(20, .semibold))
            SettingsTextField(label: "Name", text: $name)
            SettingsTextField(label: "Username", text: $username)
            Text("Use letters, numbers, and underscores. Up to 32 characters.").font(KFont.caption()).foregroundStyle(K.text2)
            Text("Bio").font(KFont.body(.medium))
            TextEditor(text: $bio).font(KFont.body()).scrollContentBackground(.hidden)
                .padding(10).frame(height: 120).kCard(fill: K.surface).accessibilityLabel("Profile bio")
            Text("Changes are saved on this Mac.").font(KFont.caption()).foregroundStyle(K.text2)
            HStack {
                Spacer()
                KButton(title: "Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
                KButton(title: "Save", kind: .primary) { save(details); dismiss() }
                    .disabled(!details.isValid).keyboardShortcut(.defaultAction)
            }
        }.padding(24).frame(width: 480).background(K.bg).foregroundStyle(K.text)
    }
}

struct ProfileShowcaseEditor: View {
    @Environment(\.dismiss) private var dismiss
    let sites: [SavedSite]
    let save: (Set<UUID>) -> Void
    @State private var selected: Set<UUID>

    init(sites: [SavedSite], selected: Set<UUID>, save: @escaping (Set<UUID>) -> Void) {
        self.sites = sites
        self.save = save
        _selected = State(initialValue: selected)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit showcase").font(KFont.ui(20, .semibold))
            if sites.isEmpty {
                Text("Save a website in Sites from the three-dot menu, then feature it here.")
                    .font(KFont.body()).foregroundStyle(K.text2)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(sites) { site in
                            Toggle(isOn: Binding(get: { selected.contains(site.id) }, set: { enabled in
                                if enabled { selected.insert(site.id) } else { selected.remove(site.id) }
                            })) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(site.name).font(KFont.body()).foregroundStyle(K.text)
                                    Text(site.url.host ?? site.url.absoluteString).font(KFont.caption()).foregroundStyle(K.text2)
                                }
                            }.toggleStyle(.checkbox)
                        }
                    }
                }.frame(maxHeight: 280)
            }
            HStack {
                Spacer()
                KButton(title: "Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
                if !sites.isEmpty {
                    KButton(title: "Save", kind: .primary) { save(selected); dismiss() }.keyboardShortcut(.defaultAction)
                }
            }
        }.padding(24).frame(width: 480).background(K.bg).foregroundStyle(K.text)
    }
}
