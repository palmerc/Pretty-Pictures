import UIKit
import Metal

private let kInflightCommandBuffers = 1



public class JuliaCalculatorMetal
{
    private static let _defaultDegree: Int = 2
    private static let _defaultThreshold: Double = 2.0

    private var metalDevice: MTLDevice! = nil
    private var metalDefaultLibrary: MTLLibrary! = nil
    private var metalCommandQueue: MTLCommandQueue! = nil

    private var metalKernelFunction: MTLFunction!
    private var metalPipelineState: MTLComputePipelineState!

    private var computeFrameCycle: Int = 0
    private var queue: dispatch_queue_t!
    private var inflightSemaphore: dispatch_semaphore_t

    private var inputFractalStateMetalBuffer: MTLBuffer?
    private var inputComplexGridMetalBuffer: MTLBuffer?
    private var outputFractalStateMetalBuffer: MTLBuffer?
    //    private var inflightMetalBuffers: [MTLBuffer]?

    init()
    {
        self.computeFrameCycle = 0
        self.inflightSemaphore = dispatch_semaphore_create(kInflightCommandBuffers)

        let (metalDevice, metalLibrary, metalCommandQueue) = self.setupMetalDevice()
        if let metalDevice = metalDevice, metalLibrary = metalLibrary, metalCommandQueue = metalCommandQueue {
            let (metalChannelDataKernelFunction, metalChannelDataPipelineState) = self.setupShaderInMetalPipelineWithName("juliaFractalStatesForComplexGrid", withDevice: metalDevice, inLibrary: metalLibrary)
            self.metalKernelFunction = metalChannelDataKernelFunction
            self.metalPipelineState = metalChannelDataPipelineState

            self.metalDevice = metalDevice
            self.metalDefaultLibrary = metalLibrary
            self.metalCommandQueue = metalCommandQueue

            self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        } else {
            print("Failed to find a Metal device. Processing will be performed on CPU.")
        }
    }

    private func setupMetalDevice() -> (metalDevice: MTLDevice?,
        metalLibrary: MTLLibrary?,
        metalCommandQueue: MTLCommandQueue?)
    {
        let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
        let metalLibrary = metalDevice?.newDefaultLibrary()
        let metalCommandQueue = metalDevice?.newCommandQueue()

        return (metalDevice, metalLibrary, metalCommandQueue)
    }

    private func setupShaderInMetalPipelineWithName(kernelFunctionName: String, withDevice metalDevice: MTLDevice?, inLibrary metalLibrary: MTLLibrary?) ->
        (metalKernelFunction: MTLFunction?,
        metalPipelineState: MTLComputePipelineState?)
    {
        let metalKernelFunction: MTLFunction? = metalLibrary?.newFunctionWithName(kernelFunctionName)

        let computePipeLineDescriptor = MTLComputePipelineDescriptor()
        computePipeLineDescriptor.computeFunction = metalKernelFunction

        var metalPipelineState: MTLComputePipelineState? = nil
        do {
            metalPipelineState = try metalDevice?.newComputePipelineStateWithFunction(metalKernelFunction!)
        } catch let error as NSError {
            print("Compute pipeline state acquisition failed. \(error.localizedDescription)")
        }

        return (metalKernelFunction, metalPipelineState)
    }

    public func fractalStatesForComplexGrid(complexGrid: [[Complex<Double>]],
                                            coordinate: Complex<Double>,
                                            maximumIterations: Int,
                                            degree: Int = _defaultDegree,
                                            threshold: Double = _defaultThreshold,
                                            withCompletionHandler handler: (([[FractalState]])->())?)
    {
        initializeBuffersWithComplexGrid(complexGrid)

        var width = 0
        var height = 0
        if let vector = complexGrid.first {
            width = vector.count
            height = complexGrid.count
        }

        let metalCommandBuffer = self.metalCommandQueue.commandBuffer()
        dispatch_semaphore_wait(self.inflightSemaphore, DISPATCH_TIME_FOREVER)
        self.fractalStatesForComplexGrid(complexGrid,
                                         coordinate: coordinate,
                                         maximumIterations: maximumIterations,
                                         degree: degree,
                                         threshold: threshold,
                                         withCommandBuffer: metalCommandBuffer)
        metalCommandBuffer.addCompletedHandler({ _ in
            if let outputFractalStateMetalBuffer = self.outputFractalStateMetalBuffer {
                let contents = outputFractalStateMetalBuffer.contents()
                let voidPointer = COpaquePointer(contents)
                let fractalPointer = UnsafeMutablePointer<FractalStateMetal>(voidPointer)
                let bufferPointer = UnsafeMutableBufferPointer<FractalStateMetal>(start: fractalPointer, count: width * height)

                var fractalStates = [[FractalState]](count: height,
                    repeatedValue: [FractalState](count: width,
                        repeatedValue:FractalState(type: .Mandelbrot,
                            iterations: 0,
                            maximumIterations: 0,
                            z: Complex<Double>(0, 0),
                            c: Complex<Double>(0, 0),
                            degree: 0,
                            threshold: 0)))
                for index in bufferPointer.startIndex ..< bufferPointer.endIndex {
                    let row = index / width
                    let column = index % width
                    var fractalStateSwift = fractalStates[row][column]
                    let fractalStateMetal = bufferPointer[index]

                    fractalStateSwift.type = .Mandelbrot
                    fractalStateSwift.iterations = Int(fractalStateMetal.iterations)
                    fractalStateSwift.maximumIterations = Int(fractalStateMetal.maximumIterations)
                    fractalStateSwift.z.re = Double(fractalStateMetal.z.real)
                    fractalStateSwift.z.im = Double(fractalStateMetal.z.imaginary)
                    fractalStateSwift.c.re = Double(fractalStateMetal.c.real)
                    fractalStateSwift.c.im = Double(fractalStateMetal.c.imaginary)
                    fractalStateSwift.degree = Int(fractalStateMetal.degree)
                    fractalStateSwift.threshold = Double(fractalStateMetal.threshold)

                    fractalStates[row][column] = fractalStateSwift
                }

                dispatch_semaphore_signal(self.inflightSemaphore)
                if let handler = handler {
                    dispatch_async(dispatch_get_main_queue(), {
                        handler(fractalStates);
                    })
                }
            }
        })
        metalCommandBuffer.commit()
    }

    public func fractalStatesForComplexGrid(complexGrid: [[Complex<Double>]],
                                            coordinate: Complex<Double>,
                                            maximumIterations: Int,
                                            degree: Int = _defaultDegree,
                                            threshold: Double = _defaultThreshold,
                                            withCommandBuffer metalCommandBuffer: MTLCommandBuffer)
    {
        if let inputFractalStateMetalBuffer = self.inputFractalStateMetalBuffer,
            inputComplexGridMetalBuffer = self.inputComplexGridMetalBuffer {
            let parameters = FractalStateMetal(iterations: Int32(0), maximumIterations: Int32(maximumIterations), z: ComplexMetal(real: 0, imaginary: 0), c: ComplexMetal(real: Float(coordinate.re), imaginary: Float(coordinate.im)), degree: Int32(degree), threshold: Float(threshold))
            UnsafeMutablePointer<FractalStateMetal>(inputFractalStateMetalBuffer.contents()).memory = parameters

            var width = 0
            var height = 0
            if let vector = complexGrid.first {
                width = vector.count
                height = complexGrid.count
            }

            let complexMetalCount = inputComplexGridMetalBuffer.length / sizeof(ComplexMetal)
            var complexGridMetal = [ComplexMetal](count: complexMetalCount, repeatedValue: ComplexMetal(real: 0, imaginary: 0))
            for row in 0 ..< height {
                for column in 0 ..< width {
                    let index = row * width + column

                    let complex = complexGrid[row][column]
                    complexGridMetal[index].real = Float(complex.re)
                    complexGridMetal[index].imaginary = Float(complex.im)
                }
            }
            let inputComplexGridMetalBufferPointer = inputComplexGridMetalBuffer.contents()
            memcpy(inputComplexGridMetalBufferPointer, complexGridMetal, inputComplexGridMetalBuffer.length)
            let commandEncoder = metalCommandBuffer.computeCommandEncoder()

            if let pipelineState = self.metalPipelineState {
                commandEncoder.pushDebugGroup("Julia Metal Processing")
                commandEncoder.setComputePipelineState(pipelineState)

                commandEncoder.setBuffer(self.inputFractalStateMetalBuffer, offset: 0, atIndex: 0) // FractalState
                commandEncoder.setBuffer(self.inputComplexGridMetalBuffer, offset: 0, atIndex: 1) // float2
                commandEncoder.setBuffer(self.outputFractalStateMetalBuffer, offset: 0, atIndex: 2) // [[FractalState]]

                let maxPixelCount = width * height
                let roundedUp = Int(pow(2.0, ceil(log2(Float(maxPixelCount))))) // nearest power of 2
                let threadExecutionWidth = pipelineState.threadExecutionWidth
                //                let dimensionalExecutionWidth = Int(log2(Double(threadExecutionWidth)))
                let threadsPerThreadgroup = MTLSize(width: threadExecutionWidth, height: 1, depth: 1)
                let threadGroupWidth = roundedUp / threadsPerThreadgroup.width
                let threadGroups = MTLSize(width: threadGroupWidth, height: 1, depth:1)

                commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsPerThreadgroup)
                commandEncoder.endEncoding()
                commandEncoder.popDebugGroup()
            }

            self.computeFrameCycle = (self.computeFrameCycle + 1) % kInflightCommandBuffers
        }
    }

    private func initializeBuffersWithComplexGrid(complexGrid: [[Complex<Double>]])
    {
        var width = 0
        var height = 0
        if let vector = complexGrid.first {
            width = vector.count
            height = complexGrid.count
        }
        if self.inputFractalStateMetalBuffer == nil {
            let byteCount = sizeof(FractalStateMetal)
            let bytesToAllocate = Int(pow(2.0, ceil(log2(Float(byteCount))) + 1))
            self.inputFractalStateMetalBuffer = self.metalDevice.newBufferWithLength(bytesToAllocate, options: .StorageModeShared)
        }
        if self.inputComplexGridMetalBuffer == nil {
            let byteCount = sizeof(ComplexMetal) * width * height
            let bytesToAllocate = Int(pow(2.0, ceil(log2(Float(byteCount)))))
            let options = MTLResourceOptions.StorageModeShared.union(.CPUCacheModeWriteCombined)
            self.inputComplexGridMetalBuffer = self.metalDevice.newBufferWithLength(bytesToAllocate, options: options)
        }
        if self.outputFractalStateMetalBuffer == nil {
            let byteCount = sizeof(FractalStateMetal) * width * height
            let bytesToAllocate = Int(pow(2.0, ceil(log2(Float(byteCount)))))
            let options = MTLResourceOptions.StorageModeShared.union(.CPUCacheModeWriteCombined)
            self.outputFractalStateMetalBuffer = self.metalDevice.newBufferWithLength(bytesToAllocate, options: options)
        }
    }
}