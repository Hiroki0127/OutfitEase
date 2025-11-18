import SwiftUI

/// Modern typography system using SF Pro with contemporary weights and sizes
extension Font {
    // MARK: - Display Fonts (Large, attention-grabbing)
    static let appDisplayLarge = Font.system(size: 40, weight: .bold, design: .default)
    static let appDisplayMedium = Font.system(size: 34, weight: .bold, design: .default)
    static let appDisplaySmall = Font.system(size: 28, weight: .semibold, design: .default)
    
    // MARK: - Headline Fonts (Section headers, titles)
    static let appHeadline1 = Font.system(size: 24, weight: .semibold, design: .default)
    static let appHeadline2 = Font.system(size: 20, weight: .semibold, design: .default)
    static let appHeadline3 = Font.system(size: 18, weight: .semibold, design: .default)
    
    // MARK: - Title Fonts (Page titles, card titles)
    static let appTitle1 = Font.system(size: 22, weight: .regular, design: .default)
    static let appTitle2 = Font.system(size: 20, weight: .medium, design: .default)
    static let appTitle3 = Font.system(size: 18, weight: .medium, design: .default)
    
    // MARK: - Body Fonts (Main content)
    static let appBodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let appBody = Font.system(size: 15, weight: .regular, design: .default)
    static let appBodySmall = Font.system(size: 13, weight: .regular, design: .default)
    
    // MARK: - Label Fonts (Buttons, tags, captions)
    static let appLabel = Font.system(size: 15, weight: .medium, design: .default)
    static let appLabelSmall = Font.system(size: 13, weight: .medium, design: .default)
    static let appCaption = Font.system(size: 12, weight: .regular, design: .default)
    
    // MARK: - Button Fonts
    static let appButtonLarge = Font.system(size: 17, weight: .semibold, design: .default)
    static let appButton = Font.system(size: 15, weight: .semibold, design: .default)
    static let appButtonSmall = Font.system(size: 13, weight: .semibold, design: .default)
}

/// Text style modifiers for consistent typography
extension Text {
    func appDisplayLarge() -> some View {
        self.font(.appDisplayLarge)
    }
    
    func appDisplayMedium() -> some View {
        self.font(.appDisplayMedium)
    }
    
    func appHeadline1() -> some View {
        self.font(.appHeadline1)
    }
    
    func appHeadline2() -> some View {
        self.font(.appHeadline2)
    }
    
    func appHeadline3() -> some View {
        self.font(.appHeadline3)
    }
    
    func appTitle1() -> some View {
        self.font(.appTitle1)
    }
    
    func appTitle2() -> some View {
        self.font(.appTitle2)
    }
    
    func appTitle3() -> some View {
        self.font(.appTitle3)
    }
    
    func appBodyLarge() -> some View {
        self.font(.appBodyLarge)
    }
    
    func appBody() -> some View {
        self.font(.appBody)
    }
    
    func appBodySmall() -> some View {
        self.font(.appBodySmall)
    }
    
    func appLabel() -> some View {
        self.font(.appLabel)
    }
    
    func appCaption() -> some View {
        self.font(.appCaption)
    }
}

