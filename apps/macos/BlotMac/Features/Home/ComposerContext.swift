import SwiftUI

struct ComposerContext {
    @Binding var project: String
    @Binding var environment: String
    @Binding var branch: String
    let projects: [String]
}

struct ComposerContextBar: View {
    var context: ComposerContext
    var body: some View {
        HStack(spacing: 4) {
            MenuChip(icon: "folder", label: context.project) {
                KMenuItem.choices(context.projects, selected: context.project) { context.project = $0 }
            }
            MenuChip(icon: "laptop", label: context.environment) {
                KMenuItem.choices(["This Mac", "Local worktree"], selected: context.environment) { context.environment = $0 }
            }
            MenuChip(icon: "git-branch", label: context.branch) {
                KMenuItem.choices(["main", "New branch"], selected: context.branch) { context.branch = $0 }
            }
            Spacer(minLength: 0)
        }.padding(.horizontal, 8).padding(.bottom, 12).frame(height: K.composerContextHeight)
            .background(UnevenRoundedRectangle(topLeadingRadius: 14, topTrailingRadius: 14).fill(K.composerContext))
    }
}
