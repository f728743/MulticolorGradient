//
//  MulticolorGradient.swift
//  RandomPathAinmation
//
//  Created by Alexey Vorobyov on 09.09.2023.
//

import SwiftUI

struct MulticolorGradient: View, Animatable {
    var points: ColorSpots
    var bias: Float = 0.001
    var power: Float = 2
    var noise: Float = 2

    var animatableData: ColorSpots.AnimatableData {
        get { points.animatableData }
        set { points = .init(newValue) }
    }

    var body: some View {
        WrapedMulticolorGradient(points: points, bias: bias, power: power, noise: noise)
    }
}

private struct WrapedMulticolorGradient: UIViewRepresentable {
    let points: ColorSpots
    let bias: Float
    let power: Float
    let noise: Float

    func makeUIView(context _: Context) -> MulticolorGradientView {
        let view = MulticolorGradientView()
        view.update(with: .init(spots: points, bias: bias, power: power, noise: noise))
        return view
    }

    func updateUIView(_ view: MulticolorGradientView, context _: Context) {
        view.update(with: .init(spots: points, bias: bias, power: power, noise: noise))
    }
}

struct AnimatedGradientView_Previews: PreviewProvider {
    static var previews: some View {
        MulticolorGradient(
            points: [
                .init(position: .top, color: .pink),
                .init(position: .leading, color: .indigo),
                .init(position: .bottomTrailing, color: .cyan)
            ]
        )
        .ignoresSafeArea()
    }
}
