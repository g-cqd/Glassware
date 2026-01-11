//
//  VisualEffect.swift
//  Glassware
//
//  SwiftUI wrapper for customizable blur effects using platform-specific visual effect systems.
//
//  Based on VisualEffectView by Lasha Efremidze.
//  SwiftUI integration by 朱浩宇.
//

import SwiftUI

#if canImport(UIKit)
import UIKit

// MARK: - SwiftUI View (iOS)

/// A SwiftUI view that provides customizable blur effects.
///
/// This view wraps `VisualEffectView` to provide fine-grained control over
/// blur radius, color tint, and scale factor.
///
/// ## Usage
/// ```swift
/// VisualEffect(colorTint: .white, colorTintAlpha: 0.5, blurRadius: 18)
///     .frame(width: 200, height: 100)
/// ```
public struct VisualEffect: UIViewRepresentable {
    let colorTint: Color?
    let colorTintAlpha: CGFloat
    let blurRadius: CGFloat
    let scale: CGFloat

    /// Creates a visual effect view with customizable blur properties.
    ///
    /// - Parameters:
    ///   - colorTint: Optional tint color applied over the blur. Default is `nil`.
    ///   - colorTintAlpha: Alpha value for the tint color. Default is `0`.
    ///   - blurRadius: The blur radius. Default is `0`.
    ///   - scale: Scale factor for the effect. Default is `1`.
    public init(
        colorTint: Color? = nil,
        colorTintAlpha: CGFloat = 0,
        blurRadius: CGFloat = 0,
        scale: CGFloat = 1
    ) {
        self.colorTint = colorTint
        self.colorTintAlpha = colorTintAlpha
        self.blurRadius = blurRadius
        self.scale = scale
    }

    public func makeUIView(context: Context) -> VisualEffectView {
        let view = VisualEffectView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        configureView(view)
        return view
    }

    public func updateUIView(_ uiView: VisualEffectView, context: Context) {
        configureView(uiView)
    }

    private func configureView(_ view: VisualEffectView) {
        if let colorTint {
            view.colorTint = UIColor(colorTint)
        }
        view.colorTintAlpha = colorTintAlpha
        view.blurRadius = blurRadius
        view.scale = scale
    }
}

// MARK: - UIKit View

/// A dynamic background blur view with customizable blur radius, tint color, and scale.
///
/// This class provides direct access to the private blur effect APIs in UIKit,
/// allowing fine-grained control over visual effect properties that aren't
/// exposed through the standard `UIBlurEffect` API.
///
/// - Warning: This implementation uses private APIs and may break in future iOS versions.
@objcMembers
open class VisualEffectView: UIVisualEffectView {
    // swiftlint:disable force_cast
    /// The underlying blur effect instance.
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    // swiftlint:enable force_cast

    /// The tint color applied over the blur.
    ///
    /// The default value is `nil`.
    open var colorTint: UIColor? {
        get {
            sourceOver?.value(forKeyPath: "color") as? UIColor
        }
        set {
            prepareForChanges()
            sourceOver?.setValue(newValue, forKeyPath: "color")
            sourceOver?.perform(Selector(("applyRequestedEffectToView:")), with: overlayView)
            applyChanges()
            overlayView?.backgroundColor = newValue
        }
    }

    /// The alpha value for the tint color.
    ///
    /// Only has an effect when `colorTint` is not `nil`.
    /// The default value is `0.0`.
    open var colorTintAlpha: CGFloat {
        get { value(forKey: .colorTintAlpha) ?? 0.0 }
        set { colorTint = colorTint?.withAlphaComponent(newValue) }
    }

    /// The blur radius.
    ///
    /// The default value is `0.0`.
    open var blurRadius: CGFloat {
        get {
            gaussianBlur?.requestedValues?["inputRadius"] as? CGFloat ?? 0
        }
        set {
            prepareForChanges()
            gaussianBlur?.requestedValues?["inputRadius"] = newValue
            applyChanges()
        }
    }

    /// The scale factor for the effect.
    ///
    /// Determines how content is mapped from logical coordinates (points)
    /// to device coordinates (pixels).
    /// The default value is `1.0`.
    open var scale: CGFloat {
        get { value(forKey: .scale) ?? 1.0 }
        set { setValue(newValue, forKey: .scale) }
    }

    // MARK: - Initialization

    public override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        scale = 1
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scale = 1
    }
}

// MARK: - Private Helpers

private extension VisualEffectView {
    enum Key: String {
        case colorTint, colorTintAlpha, blurRadius, scale
    }

    func value<T>(forKey key: Key) -> T? {
        blurEffect.value(forKeyPath: key.rawValue) as? T
    }

    func setValue(_ value: (some Any)?, forKey key: Key) {
        blurEffect.setValue(value, forKeyPath: key.rawValue)
    }
}

// MARK: - UIVisualEffectView Extensions

private extension UIVisualEffectView {
    var backdropView: UIView? {
        subview(of: NSClassFromString("_UIVisualEffectBackdropView"))
    }

    var overlayView: UIView? {
        subview(of: NSClassFromString("_UIVisualEffectSubview"))
    }

    var gaussianBlur: NSObject? {
        backdropView?.value(forKey: "filters", withFilterType: "gaussianBlur")
    }

    var sourceOver: NSObject? {
        overlayView?.value(forKey: "viewEffects", withFilterType: "sourceOver")
    }

    func prepareForChanges() {
        effect = UIBlurEffect(style: .light)
        gaussianBlur?.setValue(1.0, forKeyPath: "requestedScaleHint")
    }

    func applyChanges() {
        backdropView?.perform(Selector(("applyRequestedFilterEffects")))
    }
}

// MARK: - NSObject Extensions

private extension NSObject {
    var requestedValues: [String: Any]? {
        get { value(forKeyPath: "requestedValues") as? [String: Any] }
        set { setValue(newValue, forKeyPath: "requestedValues") }
    }

    func value(forKey key: String, withFilterType filterType: String) -> NSObject? {
        guard let objects = value(forKeyPath: key) as? [NSObject] else {
            return nil
        }
        return objects.first { $0.value(forKeyPath: "filterType") as? String == filterType }
    }
}

// MARK: - UIView Extensions

private extension UIView {
    func subview(of classType: AnyClass?) -> UIView? {
        subviews.first { type(of: $0) == classType }
    }
}

#elseif canImport(AppKit)
import AppKit

// MARK: - SwiftUI View (macOS)

/// A SwiftUI view that provides customizable blur effects using AppKit's visual effect system.
///
/// On macOS, this uses `NSVisualEffectView` with material-based blurring.
public struct VisualEffect: NSViewRepresentable {
    let colorTint: Color?
    let colorTintAlpha: CGFloat
    let blurRadius: CGFloat
    let scale: CGFloat

    /// Creates a visual effect view with customizable blur properties.
    ///
    /// - Parameters:
    ///   - colorTint: Optional tint color applied over the blur. Default is `nil`.
    ///   - colorTintAlpha: Alpha value for the tint color. Default is `0`.
    ///   - blurRadius: The blur radius (used to select material). Default is `0`.
    ///   - scale: Scale factor (unused on macOS). Default is `1`.
    public init(
        colorTint: Color? = nil,
        colorTintAlpha: CGFloat = 0,
        blurRadius: CGFloat = 0,
        scale: CGFloat = 1
    ) {
        self.colorTint = colorTint
        self.colorTintAlpha = colorTintAlpha
        self.blurRadius = blurRadius
        self.scale = scale
    }

    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.autoresizingMask = [.width, .height]
        configureView(view)
        return view
    }

    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        configureView(nsView)
    }

    private func configureView(_ view: NSVisualEffectView) {
        view.blendingMode = .behindWindow
        view.state = .active

        // Map blur radius to material - higher blur = thicker material
        if blurRadius > 15 {
            view.material = .hudWindow
        } else if blurRadius > 8 {
            view.material = .popover
        } else {
            view.material = .headerView
        }
    }
}

#endif

// MARK: - Previews

#Preview("VisualEffect") {
    ZStack {
        Color.blue
            .frame(width: 400, height: 400)
        Color.red
            .frame(width: 200, height: 100)
        VisualEffect(colorTint: .white, colorTintAlpha: 0.5, blurRadius: 18)
            .frame(width: 300, height: 200)
    }
}
