// Sources/Models/AppSettings.swift
import Foundation

/// Observable user preferences persisted via UserDefaults.
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

    @Published var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin") }
    }

    @Published var toolPaths: [String: String] {
        didSet { UserDefaults.standard.set(toolPaths, forKey: "toolPaths") }
    }

    private init() {
        self.currentThemeId = UserDefaults.standard.string(forKey: "currentThemeId") ?? "catppuccin-mocha"
        self.darkThemeId = UserDefaults.standard.string(forKey: "darkThemeId") ?? "catppuccin-mocha"
        self.lightThemeId = UserDefaults.standard.string(forKey: "lightThemeId") ?? "catppuccin-latte"
        self.followSystemAppearance = UserDefaults.standard.object(forKey: "followSystemAppearance") as? Bool ?? true
        self.launchAtLogin = UserDefaults.standard.object(forKey: "launchAtLogin") as? Bool ?? true
        self.toolPaths = UserDefaults.standard.dictionary(forKey: "toolPaths") as? [String: String] ?? [:]
    }
}
