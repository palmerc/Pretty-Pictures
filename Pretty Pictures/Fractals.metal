#include <metal_stdlib>
using namespace metal;



kernel void mandelbrotFractalStatesForComplexGrid(const device FractalParameters *inputFractalParameters [[ buffer(0) ]],
                                                  const device float2 *inputComplexGrid [[ buffer(1) ]],
                                                  device FractalParameters *outputFractalParameters [[ buffer(0) ]]
                                                  device float *outputComplexGrid [[ buffer(2) ]],
                                                  uint threadIdentifier [[ thread_position_in_grid ]])
{
    int maximumIterations = inputFractalParameters->maximumIterations
    int degree = inputFractalParameters->degree
    int threshold = inputFractalParameters->threshold
    float2 z = inputFractalParameters->z
    float2 c = inputFractalParameters->c

    for (int i = 0; i < maximumIterations; i++) {
        z = pow(z, degree) + c
        if abs(z) > threshold {
            iterations = iteration
            break;
        }
    }

    outputFractalParameters->iterations = iterations
    outputFractalParameters->degree = degree
    outputFractalParameters->z = z
    outputFractalParameters->c = c
}

kernel void juliaFractalStatesForComplexGrid(const device FractalParameters *inputFractalParameters [[ buffer(0) ]],
                                             const device float2 *inputComplexGrid [[ buffer(1) ]],
                                             device FractalParameters *outputFractalParameters [[ buffer(0) ]]
                                             device float *outputComplexGrid [[ buffer(2) ]],
                                             uint threadIdentifier [[ thread_position_in_grid ]])
{
    int maximumIterations = inputFractalParameters->maximumIterations
    int degree = inputFractalParameters->degree
    int threshold = inputFractalParameters->threshold
    float2 z = inputFractalParameters->z
    float2 c = inputFractalParameters->c

    for (int i = 0; i < maximumIterations; i++) {
        z = pow(z, degree) + c
        if abs(z) > threshold {
            iterations = iteration
            break;
        }
    }

    outputFractalParameters->iterations = iterations
    outputFractalParameters->degree = degree
    outputFractalParameters->z = z
    outputFractalParameters->c = c
}

kernel void shipFractalStatesForComplexGrid(const device FractalParameters *inputFractalParameters [[ buffer(0) ]],
                                            const device float2 *inputComplexGrid [[ buffer(1) ]],
                                            device FractalParameters *outputFractalParameters [[ buffer(0) ]]
                                            device float *outputComplexGrid [[ buffer(2) ]],
                                            uint threadIdentifier [[ thread_position_in_grid ]])
{
    int maximumIterations = inputFractalParameters->maximumIterations
    int degree = inputFractalParameters->degree
    int threshold = inputFractalParameters->threshold
    float2 z = inputFractalParameters->z
    float2 c = inputFractalParameters->c

    for (int i = 0; i < maximumIterations; i++) {
        for iteration in 1...maximumIterations {
            let real = (z.x * z.x) - (z.y * z.y) - c.x;
            let imaginary = 2.0 * abs(z.x * z.y) - c.y;
            z.x = real
            z.y = imaginary
            if abs(z) > threshold {
                iterations = iteration
                break;
            }
        }
    }

    outputFractalParameters->iterations = iterations
    outputFractalParameters->degree = degree
    outputFractalParameters->z = z
    outputFractalParameters->c = c
}