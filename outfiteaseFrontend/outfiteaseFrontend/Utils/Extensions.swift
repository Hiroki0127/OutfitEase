import SwiftUI

// MARK: - Navigation Title Font Helper
extension View {
    /// Applies the app headline2 font to navigation titles
    func navigationTitleFont(_ title: String) -> some View {
        self.navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.appHeadline2)
                }
            }
    }
}

