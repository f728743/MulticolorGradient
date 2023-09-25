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

    var uiforms: Uniforms {
        .init(params: .init(spots: points, bias: bias, power: power, noise: noise))
    }

    var body: some View {
        Rectangle()
            .colorEffect(ShaderLibrary.gradient(.boundingRect, uiforms.shaderaArgument))
    }
}

extension Uniforms {
    var shaderaArgument: Shader.Argument {
        var copy = self
        return .data(Data(bytes: &copy, count: MemoryLayout<Uniforms>.stride))
    }
}
