// Sources/App/SystemAppearanceMonitor.swift

import AppKit

/// Watches for macOS dark/light mode changes and fires a callback.
final class SystemAppearanceMonitor {
    private let onChange: (Bool) -> Void

    /// Create a monitor that calls `onChange` whenever the system appearance toggles.
    ///
    /// Args:
    ///     onChange: Closure receiving `true` when the system switches to dark mode.
    init(onChange: @escaping (Bool) -> Void) {
        self.onChange = onChange
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(appearanceChanged),
            name: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }

    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
    }

    @objc private func appearanceChanged() {
        let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        DispatchQueue.main.async { [weak self] in
            self?.onChange(isDark)
        }
    }
}
