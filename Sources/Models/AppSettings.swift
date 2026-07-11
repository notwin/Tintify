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

    /// v1.10 裁撤的主题 id → 同族保留款（存量用户设置迁移用）
    static let retiredThemeIds: [String: String] = [
        "catppuccin-macchiato": "catppuccin-mocha",
        "catppuccin-frappe": "catppuccin-mocha",
        "rose-pine-moon": "rose-pine",
    ]

    /// 已裁撤的 id 映射到保留款，其余原样返回
    static func migratedThemeId(_ id: String) -> String {
        retiredThemeIds[id] ?? id
    }

    private init() {
        self.currentThemeId = Self.migratedThemeId(UserDefaults.standard.string(forKey: "currentThemeId") ?? "catppuccin-mocha")
        self.darkThemeId = Self.migratedThemeId(UserDefaults.standard.string(forKey: "darkThemeId") ?? "catppuccin-mocha")
        self.lightThemeId = Self.migratedThemeId(UserDefaults.standard.string(forKey: "lightThemeId") ?? "catppuccin-latte")
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
        currentThemeId = Self.migratedThemeId(UserDefaults.standard.string(forKey: "currentThemeId") ?? "catppuccin-mocha")
        darkThemeId = Self.migratedThemeId(UserDefaults.standard.string(forKey: "darkThemeId") ?? "catppuccin-mocha")
        lightThemeId = Self.migratedThemeId(UserDefaults.standard.string(forKey: "lightThemeId") ?? "catppuccin-latte")
        followSystemAppearance = UserDefaults.standard.object(forKey: "followSystemAppearance") as? Bool ?? true
        toolPaths = UserDefaults.standard.dictionary(forKey: "toolPaths") as? [String: String] ?? [:]
        previousThemeId = UserDefaults.standard.string(forKey: "previousThemeId")
        disabledTools = Set(UserDefaults.standard.stringArray(forKey: "disabledTools") ?? [])
    }
}
