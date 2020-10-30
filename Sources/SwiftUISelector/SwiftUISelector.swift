import SwiftUI

public class SelectionsModel: ObservableObject {
    @Published public var selectionIndex: Int
    @Published public var options: [String]
    
    public init(_ selectionIndex: Int = 0, options: [String]) {
        self.selectionIndex = selectionIndex
        self.options = options
    }
}

public struct SelectorView: View {
    
    @Namespace private var environment
    
    @ObservedObject private var model: SelectionsModel
    
    public init(model: SelectionsModel) {
        self.model = model
    }
        
    public var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { scrollProxy in
                    HStack(spacing: 40) {
                        ForEach(0 ..< self.model.options.count) { option in
                            Text(self.model.options[option])
                                .matchedGeometryEffect(id: option, in: environment, isSource: true)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        self.model.selectionIndex = option
                                    }
                                }
                        }
                        .fixedSize()
                        .alignmentGuide(HorizontalAlignment.center, computeValue: { dimension in
                            dimension[.leading]
                        })
                    }
                    .font(
                        .system(
                            size: 24,
                            weight: Font.Weight.medium,
                            design: Font.Design.serif
                        )
                    )
                    .onReceive(self.model.$selectionIndex, perform: { _ in
                        withAnimation(.easeInOut) {
                            scrollProxy.scrollTo(self.model.selectionIndex, anchor: .center)
                        }
                    })
                }
                .padding()
            }
            
            Capsule()
                .frame(height: 1.5)
                .matchedGeometryEffect(
                    id: self.model.selectionIndex,
                    in: environment,
                    properties: MatchedGeometryProperties.frame,
                    isSource: false
                )
                .foregroundColor(.accentColor)
        }
    }
}
