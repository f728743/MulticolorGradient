//
//  MulticolorGradientView.swift
//  RandomPathAinmation
//
//  Created by Alexey Vorobyov on 09.09.2023.
//

import MetalKit
import SwiftUI
import UIKit

class MulticolorGradientView: UIView {
    private var mtkView: MTKView?
    private var computePipelineState: MTLComputePipelineState?
    private var commandQueue: MTLCommandQueue! = nil
    private var params = GradientParams()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let mtkView = MTKView()
        addSubview(mtkView)
        mtkView.frame = bounds
        mtkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevice
        mtkView.delegate = self
        mtkView.preferredFramesPerSecond = 60
        mtkView.device = defaultDevice
        mtkView.framebufferOnly = false
        mtkView.isPaused = false

        self.mtkView = mtkView

        if !setComputePipeline(device: defaultDevice) {
            fatalError("Default fragment shader has problem compiling")
        }

        commandQueue = defaultDevice.makeCommandQueue()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with params: GradientParams) {
        self.params = params
        mtkView?.draw()
    }
}

extension MulticolorGradientView: MTKViewDelegate {
    public func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        draw(with: params, in: drawable)
    }

    public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}
}

private extension MulticolorGradientView {
    func setComputePipeline(device: MTLDevice) -> Bool {
        guard let computeProgram = loadShaders(device: device) else { return false }
        computePipelineState = try? device.makeComputePipelineState(function: computeProgram)
        return computePipelineState != nil
    }

    func loadShaders(device: MTLDevice) -> MTLFunction? {
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle.main)
        else { fatalError("Unable to create default library") }
        return library.makeFunction(name: "gradient")
    }

    private func draw(with params: GradientParams, in drawable: CAMetalDrawable) {
        guard let computePipelineState,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }

        var uniforms = Uniforms(params: params)
        let texture = drawable.texture

        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
        computeEncoder.setTexture(texture, index: 4)

        if mtkView?.device?.supportsFamily(.apple4) == true {
            let gridSize = MTLSize(width: texture.width, height: texture.height, depth: 1)
            let groupWidth = computePipelineState.threadExecutionWidth
            let groupHeight = computePipelineState.maxTotalThreadsPerThreadgroup / groupWidth
            let threadGroupSize = MTLSize(width: groupWidth, height: groupHeight, depth: 1)
            computeEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
        } else {
            let groupCount = MTLSizeMake(8, 8, 1)
            let groups = MTLSizeMake(texture.width / groupCount.width, texture.height / groupCount.height, 1)
            computeEncoder.dispatchThreadgroups(groups, threadsPerThreadgroup: groupCount)
        }
        computeEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
