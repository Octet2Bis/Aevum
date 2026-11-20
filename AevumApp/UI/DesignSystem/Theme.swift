import SwiftUI
import UIKit

// MARK: - Aevum Design System & Dynamic Theme Tokens (Light & Dark)
public struct AevumTheme {
    /// Une couleur qui suit le thème du système (clair / sombre) sans lire `colorScheme` dans la vue.
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }

    // Mode Lumineux (Daylight Luxury) vs Sombre
    public static let bgPrimary = adaptive(light: Color(red: 0.97, green: 0.98, blue: 0.99), dark: Color(red: 0.03, green: 0.04, blue: 0.07))
    
    public static let bgSecondary = adaptive(light: Color(red: 0.95, green: 0.96, blue: 0.98), dark: Color(red: 0.05, green: 0.08, blue: 0.13))
    
    public static let bgCard = adaptive(light: Color.white, dark: Color(red: 0.08, green: 0.11, blue: 0.18))
    
    public static let cardBorder = adaptive(light: Color(red: 0.89, green: 0.91, blue: 0.94), dark: Color(red: 0.12, green: 0.17, blue: 0.27))
    
    // Accents Lumineux
    public static let cyanAccent = Color(red: 0.01, green: 0.52, blue: 0.78)     // #0284C7
    public static let emeraldAccent = Color(red: 0.02, green: 0.59, blue: 0.41)  // #059669
    public static let violetAccent = Color(red: 0.49, green: 0.23, blue: 0.93)   // #7C3AED
    public static let amberAccent = Color(red: 0.85, green: 0.47, blue: 0.02)    // #D97706
    public static let roseAccent = Color(red: 0.88, green: 0.11, blue: 0.28)     // #E11D48
    
    // Typographie & Textes
    public static let textPrimary = adaptive(light: Color(red: 0.06, green: 0.09, blue: 0.16), dark: Color.white)
    
    public static let textSecondary = adaptive(light: Color(red: 0.28, green: 0.33, blue: 0.41), dark: Color(red: 0.58, green: 0.64, blue: 0.72))
    
    public static let textMuted = adaptive(light: Color(red: 0.58, green: 0.64, blue: 0.72), dark: Color(red: 0.39, green: 0.45, blue: 0.55))
    
    // Dégradés
    public static let vitalityGradient = LinearGradient(
        colors: [cyanAccent, emeraldAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Rayons de courbure
    public static let radiusCard: CGFloat = 24
    public static let radiusButton: CGFloat = 16
    public static let radiusPill: CGFloat = 999
    
    // MARK: - Swiss Transit Tokens (Poster Civil / Platform 08)
    public static let swissCanvas = Color(red: 0.89, green: 0.89, blue: 0.87)    // #E3E4DF
    public static let swissInk = Color(red: 0.12, green: 0.13, blue: 0.13)       // #1F2022
    public static let signalOrange = Color(red: 1.0, green: 0.27, blue: 0.0)     // #FF4400
    public static let transitGreen = Color(red: 0.0, green: 0.72, blue: 0.37)    // #00B75F
    public static let petrolTeal = Color(red: 0.0, green: 0.50, blue: 0.50)      // #008080
    public static let swissRadiusBox: CGFloat = 0.0                               // Angles droits 0px
    public static let swissRadiusCircle: CGFloat = 999.0
    public static let swissBorderFine: CGFloat = 1.5
}

// MARK: - Modificateur Bento Card Dynamique
public struct BentoCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    public var customBorderColor: Color?
    
    public func body(content: Content) -> some View {
        let border = customBorderColor ?? AevumTheme.cardBorder
        let bg = AevumTheme.bgCard
        let shadowColor = colorScheme == .dark ? Color.black.opacity(0.35) : Color(red: 0.06, green: 0.09, blue: 0.16).opacity(0.06)
        
        content
            .background(bg)
            .overlay(
                RoundedRectangle(cornerRadius: AevumTheme.radiusCard)
                    .stroke(border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AevumTheme.radiusCard))
            .shadow(color: shadowColor, radius: 16, x: 0, y: 8)
    }
}

public extension View {
    func bentoCardStyle(borderColor: Color? = nil) -> some View {
        self.modifier(BentoCardModifier(customBorderColor: borderColor))
    }
}

// MARK: - Couleurs hexadécimales (« #1B3B2B » ou « 1B3B2B », 6 chiffres)
public extension Color {
    init(hex: String) {
        let digits = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let value = UInt64(digits, radix: 16) ?? 0
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
