import UIKit
import Metal



private let kInflightCommandBuffers = 1

struct ComplexMetal
{
    var real: Float
    var imaginary: Float
}

struct FractalStateMetal {
    var iterations: Int32
    var maximumIterations: Int32
    var z: ComplexMetal
    var c: ComplexMetal
    var degree: Int32
    var threshold: Float
}



public class MandelbrotCalculatorMetal
{
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
            let (metalChannelDataKernelFunction, metalChannelDataPipelineState) = self.setupShaderInMetalPipelineWithName("mandelbrotFractalStatesForComplexGrid", withDevice: metalDevice, inLibrary: metalLibrary)
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

    public func fractalStatesForComplexGrid(complexGrid: OneTwoDimensionalArray<Complex<Double>>,
                                            maximumIterations: Int,
                                            degree: Int = 2,
                                            threshold: Double = 2.0,
                                            withCompletionHandler handler: ((OneTwoDimensionalArray<FractalState>)->())?)
    {
        initializeBuffersWithComplexGrid(complexGrid)

        if let metalCommandQueue = self.metalCommandQueue {
            let metalCommandBuffer = metalCommandQueue.commandBuffer()
            dispatch_semaphore_wait(self.inflightSemaphore, DISPATCH_TIME_FOREVER)
            self.fractalStatesForComplexGrid(complexGrid,
                                             maximumIterations: maximumIterations,
                                             degree: degree,
                                             threshold: threshold,
                                             withCommandBuffer: metalCommandBuffer)
            metalCommandBuffer.addCompletedHandler({ _ in
                if let outputFractalStateMetalBuffer = self.outputFractalStateMetalBuffer {
                    let contents = outputFractalStateMetalBuffer.contents()
                    let voidPointer = COpaquePointer(contents)
                    let fractalPointer = UnsafeMutablePointer<FractalStateMetal>(voidPointer)
                    let bufferPointer = UnsafeMutableBufferPointer<FractalStateMetal>(start: fractalPointer, count: complexGrid.count)

                    var fractalStates = OneTwoDimensionalArray<FractalState>(rows: complexGrid.rows, columns: complexGrid.columns,
                        repeatedValue: FractalState(type: .Mandelbrot,
                            iterations: 0,
                            maximumIterations: 0,
                            z: Complex<Double>(0, 0),
                            c: Complex<Double>(0, 0),
                            degree: 0,
                            threshold: 0))
                    for index in bufferPointer.startIndex ..< bufferPointer.endIndex {
                        let fractalStateMetal = bufferPointer[index]

                        let type = FractalType.Mandelbrot
                        let iterations = Int(fractalStateMetal.iterations)
                        let maximumIterations = Int(fractalStateMetal.maximumIterations)
                        let zRe = Double(fractalStateMetal.z.real)
                        let zIm = Double(fractalStateMetal.z.imaginary)
                        let cRe = Double(fractalStateMetal.c.real)
                        let cIm = Double(fractalStateMetal.c.imaginary)
                        let degree = Int(fractalStateMetal.degree)
                        let threshold = Double(fractalStateMetal.threshold)
                        let fractalStateSwift = FractalState(type: type,
                            iterations: iterations,
                            maximumIterations: maximumIterations,
                            z: Complex<Double>(zRe, zIm),
                            c: Complex<Double>(cRe, cIm),
                            degree: degree,
                            threshold: threshold)

                        fractalStates[index] = fractalStateSwift
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
    }

    public func fractalStatesForComplexGrid(complexGrid: OneTwoDimensionalArray<Complex<Double>>,
                                            maximumIterations: Int,
                                            degree: Int = 2,
                                            threshold: Double = 2.0,
                                            withCommandBuffer metalCommandBuffer: MTLCommandBuffer)
    {
        if let inputFractalStateMetalBuffer = self.inputFractalStateMetalBuffer,
            inputComplexGridMetalBuffer = self.inputComplexGridMetalBuffer,
            complexLinearArray = complexGrid.linearArray {
            let parameters = FractalStateMetal(iterations: Int32(0), maximumIterations: Int32(maximumIterations), z: ComplexMetal(real: 0, imaginary: 0), c: ComplexMetal(real: 0, imaginary: 0), degree: Int32(2), threshold: Float(2.0))
            UnsafeMutablePointer<FractalStateMetal>(inputFractalStateMetalBuffer.contents()).memory = parameters

            let byteCount = sizeof(ComplexMetal) * complexGrid.count
            let complexGridMetal = complexLinearArray.map({
                (complex: Complex<Double>) -> ComplexMetal in
                let real = Float(complex.re)
                let imaginary = Float(complex.im)
                return ComplexMetal(real: real, imaginary: imaginary)
            })

            let inputComplexGridMetalBufferPointer = inputComplexGridMetalBuffer.contents()
            memcpy(inputComplexGridMetalBufferPointer, complexGridMetal, byteCount)
            let commandEncoder = metalCommandBuffer.computeCommandEncoder()

            if let pipelineState = self.metalPipelineState {
                commandEncoder.pushDebugGroup("Mandelbrot Processing")
                commandEncoder.setComputePipelineState(pipelineState)

                commandEncoder.setBuffer(self.inputFractalStateMetalBuffer, offset: 0, atIndex: 0) // FractalState
                commandEncoder.setBuffer(self.inputComplexGridMetalBuffer, offset: 0, atIndex: 1) // float2
                commandEncoder.setBuffer(self.outputFractalStateMetalBuffer, offset: 0, atIndex: 2) // [[FractalState]]

                let maxPixelCount = complexGrid.count
                let threadExecutionWidth = pipelineState.maxTotalThreadsPerThreadgroup
                let threadsPerThreadgroup = MTLSize(width: threadExecutionWidth, height: 1, depth: 1)
                let threadGroups = MTLSize(width: maxPixelCount / threadsPerThreadgroup.width, height: 1, depth:1)

                commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsPerThreadgroup)
                commandEncoder.endEncoding()
                commandEncoder.popDebugGroup()
            }

            self.computeFrameCycle = (self.computeFrameCycle + 1) % kInflightCommandBuffers
        }
    }

    private func initializeBuffersWithComplexGrid(complexGrid: OneTwoDimensionalArray<Complex<Double>>)
    {
        if let metalDevice = self.metalDevice {
            if self.inputFractalStateMetalBuffer == nil {
                let byteCount = sizeof(FractalStateMetal) + 8
                self.inputFractalStateMetalBuffer = metalDevice.newBufferWithLength(byteCount, options: .StorageModeShared)
            }
            if self.inputComplexGridMetalBuffer == nil {
                let byteCount = sizeof(ComplexMetal) * complexGrid.count
                let options = MTLResourceOptions.StorageModeShared.union(.CPUCacheModeWriteCombined)
                self.inputComplexGridMetalBuffer = metalDevice.newBufferWithLength(byteCount, options: options)
            }
            if self.outputFractalStateMetalBuffer == nil {
                let byteCount = sizeof(FractalStateMetal) * complexGrid.count
                let options = MTLResourceOptions.StorageModeShared.union(.CPUCacheModeWriteCombined)
                self.outputFractalStateMetalBuffer = metalDevice.newBufferWithLength(byteCount, options: options)
            }
        }
    }
}