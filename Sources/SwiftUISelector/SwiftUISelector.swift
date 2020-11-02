// @p.larson
import SwiftUI

public struct SelectionColorEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Color? {
        nil
    }
}

public struct SelectionBarColorEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Color {
        .black
    }
}

public struct OptionStackSpacingEnvironmentKey: EnvironmentKey {
    public static var defaultValue: CGFloat {
        40.0
    }
}

public struct SelectionBarHeightEnvironmentKey: EnvironmentKey {
    public static var defaultValue: CGFloat {
        1.5
    }
}

public extension EnvironmentValues {
    var selectionColor: Color? {
        get {
            return self[SelectionColorEnvironmentKey.self]
        }
        
        set {
            self[SelectionColorEnvironmentKey.self] = newValue
        }
    }
    
    var selectionBarColor: Color {
        get {
            return self[SelectionBarColorEnvironmentKey.self]
        }
        
        set {
            self[SelectionBarColorEnvironmentKey.self] = newValue
        }
    }
    
    var optionStackSpacing: CGFloat {
        get {
            return self[OptionStackSpacingEnvironmentKey.self]
        }
        
        set {
            self[OptionStackSpacingEnvironmentKey.self] = newValue
        }
    }
    
    var selectionBarHeight: CGFloat {
        get {
            return self[SelectionBarHeightEnvironmentKey.self]
        }
        
        set {
            self[SelectionBarHeightEnvironmentKey.self] = newValue
        }
    }
}

public struct SelectorView<Option, OptionView>: View where Option: Hashable, OptionView: View {
    // Geometry
    @Namespace fileprivate var environment
    // Style
    @Environment(\.selectionColor) fileprivate var selectionColor
    @Environment(\.selectionBarColor) fileprivate var selectionBarColor
    @Environment(\.optionStackSpacing) fileprivate var optionStackSpacing
    // Model Control
    @Binding fileprivate var selectedOption: Int
    // Identifiable Options for the user to choose from.
    var options: [Option]
    // Content builder for each option
    let content: (Option) -> OptionView
    // Default Initializer
    public init(selectedOption: Binding<Int>, options: [Option], @ViewBuilder content: @escaping (Option) -> OptionView) {
        self._selectedOption = selectedOption
        self.options = options
        self.content = content
    }
    // View
    public var body: some View {
        VStack {
            // Options
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { scrollProxy in
                    HStack(spacing: optionStackSpacing) {
                        ForEach(0 ..< options.count) { index -> AnyView in
                            let view = self.content(options[index])
                                .matchedGeometryEffect(id: options[index], in: environment, isSource: true)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        self.selectedOption = index
                                        scrollProxy.scrollTo(selectedOption, anchor: .center)
                                    }
                                }
                            
                            return AnyView(view.foregroundColor(options[index] == options[selectedOption] ? selectionColor : nil))
                            
                        }
                        .fixedSize()
                        .alignmentGuide(HorizontalAlignment.center, computeValue: { dimension in
                            dimension[.leading]
                        })
                    }
                }
                .padding()
            }
            // Selection Bar
            Capsule()
                .frame(height: 1.5)
                .matchedGeometryEffect(
                    id: options[selectedOption],
                    in: environment,
                    properties: MatchedGeometryProperties.frame,
                    isSource: false
                )
                .foregroundColor(selectionBarColor)
        }
    }
}
/*
 
 Convienient Initializer for Options that are Strings with a basic Text OptionView.
 
 SelectorView(
     selectedOption: $selectedOption,
     options: ["Option 1", "Option 2"]
 )
 
 **/
public extension SelectorView where Option: StringProtocol, OptionView == Text {
    init(selectedOption: Binding<Int>, options: [Option]) {
        self.options = options
        self._selectedOption = selectedOption
        self.content = { option in
            Text(option)
        }
    }
}

public extension View {
    dynamic func selectionColor(_ value: Color) -> some View {
        self.environment(\.selectionColor, value)
    }
    
    dynamic func selectionBarColor(_ value: Color) -> some View {
        self.environment(\.selectionBarColor, value)
    }
    
    dynamic func optionStackSpacing(_ value: CGFloat) -> some View {
        self.environment(\.optionStackSpacing, value)
    }
    
    dynamic func selectionBarHeight(_ value: CGFloat) -> some View {
        self.environment(\.selectionBarHeight, value)
    }
}

// LARSON 2020
