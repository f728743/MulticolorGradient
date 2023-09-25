//
//  ContentView.swift
//  RandomPathAinmation
//
//  Created by Alexey Vorobyov on 06.09.2023.
//

import SwiftUI

struct ContentView: View {
    static let colors: [Color] = [.pink, .indigo, .cyan, .red]
    @State var points: ColorSpots = ContentView.colors.map { .random(withColor: $0) }

    static let animationDuration: Double = 5
    @State var bias: Float = 0.05
    @State var power: Float = 2.5
    @State var noise: Float = 2

    let timer = Timer
        .publish(every: ContentView.animationDuration * 0.8, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        ZStack {
            MulticolorGradient(
                points: points,
                bias: bias,
                power: power,
                noise: noise
            )
            .ignoresSafeArea()
            controls
                .padding()
        }
        .onReceive(timer) { _ in animate() }
        .onAppear { animate() }
    }
}

private extension ContentView {
    var controls: some View {
        VStack {
            Spacer()
            labeldSlider("bias", value: $bias, in: 0.001 ... 0.5)
            labeldSlider("power", value: $power, in: 1 ... 10)
            labeldSlider("noise", value: $noise, in: 0 ... 400)
        }
    }

    func animate() {
        withAnimation(.easeInOut(duration: ContentView.animationDuration)) {
            points = ContentView.colors.map { .random(withColor: $0) }
        }
    }

    func labeldSlider(
        _ label: String,
        value: Binding<Float>,
        in bounds: ClosedRange<Float>
    ) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label)
                Text(String(format: "%.4f", value.wrappedValue))
            }
            .font(.system(size: 10))
            .frame(minWidth: 50, alignment: .leading)

            Slider(value: value, in: bounds)
        }
    }
}

private extension ColorSpot {
    static func random(withColor color: Color) -> ColorSpot {
        .init(
            position: .init(x: CGFloat.random(in: 0 ..< 1), y: CGFloat.random(in: 0 ..< 1)),
            color: color
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
