//
//  ViewOffsetKey.swift
//  BumperPick
//
//  Created by tauseef hussain on 11/06/25.
//


import SwiftUI

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewOffsetModifier: ViewModifier {
    let coordinateSpace: String
    let containerVisibleHeight: CGFloat
    let onVisibilityChanged: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    let frame = geo.frame(in: .named(coordinateSpace))
                    Color.clear
                        .onAppear {
                            onVisibilityChanged(isFrameVisible(frame))
                        }
                        .onChange(of: frame.minY) { _ in
                            onVisibilityChanged(isFrameVisible(frame))
                        }
                }
            )
    }

    private func isFrameVisible(_ frame: CGRect) -> Bool {
        let visibleTop = max(frame.minY, 0)
        let visibleBottom = min(frame.maxY, containerVisibleHeight)
        let visibleHeight = visibleBottom - visibleTop
        return visibleHeight > frame.height * 0.5
    }
}


extension View {
    func onScrollVisibilityChange(coordinateSpace: String, visibleHeight: CGFloat, perform: @escaping (Bool) -> Void) -> some View {
        self.modifier(ViewOffsetModifier(coordinateSpace: coordinateSpace, containerVisibleHeight: visibleHeight, onVisibilityChanged: perform))
    }
}

