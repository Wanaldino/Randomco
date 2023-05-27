//
//  AnimatePlaceholder.swift
//  Randomco
//
//  Created by Carlos Martinez Medina on 27/5/23.
//

import SwiftUI

extension View {
    func animatePlaceholder(isLoading: Binding<Bool> = .constant(true)) -> some View {
        self.modifier(AnimatePlaceholderModifier(isLoading: isLoading))
    }
}

struct AnimatePlaceholderModifier: AnimatableModifier {
    @Binding var isLoading: Bool

    @State private var isAnim: Bool = false
    private var center = (UIScreen.main.bounds.width / 2) + 110
    private let animation: Animation = .linear(duration: 1.5)

    init(isLoading: Binding<Bool>) {
        self._isLoading = isLoading
    }

    func body(content: Content) -> some View {
        content.overlay(animView.mask(content))
    }

    var animView: some View {
        ZStack {
            Color.black.opacity(isLoading ? 0.75 : 0.0)
            Color.white.mask(
                Rectangle()
                    .fill(
                        LinearGradient(gradient: .init(colors: [.clear, .white.opacity(0.48), .clear]), startPoint: .top , endPoint: .bottom)
                    )
                    .scaleEffect(1.5)
                    .rotationEffect(.init(degrees: 70.0))
                    .offset(x: isAnim ? center : -center)
            )
        }
        .animation(isLoading ? animation.repeatForever(autoreverses: false) : nil, value: isAnim)
        .onAppear {
            guard isLoading else { return }
            isAnim.toggle()
        }
        .onChange(of: isLoading) { _ in
            isAnim.toggle()
        }
    }
}
