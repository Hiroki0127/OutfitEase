import SwiftUI

/// Modern typography system using SF Pro Rounded for a friendly, contemporary look
extension Font {
    // MARK: - Display Fonts (Large, attention-grabbing) - Using Rounded for modern feel
    static let appDisplayLarge = Font.system(size: 42, weight: .heavy, design: .rounded)
    static let appDisplayMedium = Font.system(size: 36, weight: .bold, design: .rounded)
    static let appDisplaySmall = Font.system(size: 30, weight: .bold, design: .rounded)
    
    // MARK: - Headline Fonts (Section headers, titles) - Using Rounded
    static let appHeadline1 = Font.system(size: 26, weight: .bold, design: .rounded)
    static let appHeadline2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let appHeadline3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // MARK: - Title Fonts (Page titles, card titles) - Using Rounded
    static let appTitle1 = Font.system(size: 24, weight: .medium, design: .rounded)
    static let appTitle2 = Font.system(size: 22, weight: .medium, design: .rounded)
    static let appTitle3 = Font.system(size: 20, weight: .medium, design: .rounded)
    
    // MARK: - Body Fonts (Main content) - Using default SF Pro for readability
    static let appBodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let appBody = Font.system(size: 16, weight: .regular, design: .default)
    static let appBodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    // MARK: - Label Fonts (Buttons, tags, captions) - Using Rounded for consistency
    static let appLabel = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let appLabelSmall = Font.system(size: 14, weight: .medium, design: .rounded)
    static let appCaption = Font.system(size: 13, weight: .regular, design: .rounded)
    
    // MARK: - Button Fonts - Using Rounded for modern buttons
    static let appButtonLarge = Font.system(size: 18, weight: .bold, design: .rounded)
    static let appButton = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let appButtonSmall = Font.system(size: 14, weight: .semibold, design: .rounded)
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

