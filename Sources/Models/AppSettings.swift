// Sources/Models/AppSettings.swift
import Foundation

/// Observable user preferences persisted via UserDefaults.
@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var currentThemeId: String {
        didSet { UserDefaults.standard.set(currentThemeId, forKey: "currentThemeId") }
    }

    @Published var darkThemeId: String {
        didSet { UserDefaults.standard.set(darkThemeId, forKey: "darkThemeId") }
    }

    @Published var lightThemeId: String {
        didSet { UserDefaults.standard.set(lightThemeId, forKey: "lightThemeId") }
    }

    @Published var followSystemAppearance: Bool {
        didSet { UserDefaults.standard.set(followSystemAppearance, forKey: "followSystemAppearance") }
    }

    @Published var toolPaths: [String: String] {
        didSet { UserDefaults.standard.set(toolPaths, forKey: "toolPaths") }
    }

    @Published var previousThemeId: String? {
        didSet { UserDefaults.standard.set(previousThemeId, forKey: "previousThemeId") }
    }

    @Published var disabledTools: Set<String> {
        didSet { UserDefaults.standard.set(Array(disabledTools), forKey: "disabledTools") }
    }

    @Published var onboardingCompleted: Bool {
        didSet { UserDefaults.standard.set(onboardingCompleted, forKey: "onboardingCompleted") }
    }

    private init() {
        self.currentThemeId = UserDefaults.standard.string(forKey: "currentThemeId") ?? "catppuccin-mocha"
        self.darkThemeId = UserDefaults.standard.string(forKey: "darkThemeId") ?? "catppuccin-mocha"
        self.lightThemeId = UserDefaults.standard.string(forKey: "lightThemeId") ?? "catppuccin-latte"
        self.followSystemAppearance = UserDefaults.standard.object(forKey: "followSystemAppearance") as? Bool ?? true
        self.toolPaths = UserDefaults.standard.dictionary(forKey: "toolPaths") as? [String: String] ?? [:]
        self.previousThemeId = UserDefaults.standard.string(forKey: "previousThemeId")
        self.disabledTools = Set(UserDefaults.standard.stringArray(forKey: "disabledTools") ?? [])
        self.onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        // Existing users who already have a theme set don't need onboarding
        if !self.onboardingCompleted && UserDefaults.standard.string(forKey: "currentThemeId") != nil {
            self.onboardingCompleted = true
        }
    }

    /// 从 UserDefaults 重读全部设置（CLI 等外部进程修改 defaults 后调用）。
    func reload() {
        currentThemeId = UserDefaults.standard.string(forKey: "currentThemeId") ?? "catppuccin-mocha"
        darkThemeId = UserDefaults.standard.string(forKey: "darkThemeId") ?? "catppuccin-mocha"
        lightThemeId = UserDefaults.standard.string(forKey: "lightThemeId") ?? "catppuccin-latte"
        followSystemAppearance = UserDefaults.standard.object(forKey: "followSystemAppearance") as? Bool ?? true
        toolPaths = UserDefaults.standard.dictionary(forKey: "toolPaths") as? [String: String] ?? [:]
        previousThemeId = UserDefaults.standard.string(forKey: "previousThemeId")
        disabledTools = Set(UserDefaults.standard.stringArray(forKey: "disabledTools") ?? [])
    }
}
