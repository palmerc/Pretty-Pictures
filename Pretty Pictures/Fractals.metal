#include <metal_stdlib>
using namespace metal;



enum FractalType {
    MANDELBROT,
    JULIA,
    BURNING_SHIP
};

struct FractalState
{
    int iterations;
    int maximumIterations;
    float2 z;
    float2 c;
    int degree;
    float threshold;
};

inline float2 addC(float2 lhs, float2 rhs);
inline float2 multiplyC(float2 lhs, float2 rhs);
inline float absC(float2 lhs);



kernel void mandelbrotFractalStatesForComplexGrid(const device FractalState *inputFractalState [[ buffer(0) ]],
                                                  const device float2 *inputComplexGrid [[ buffer(1) ]],
                                                  device FractalState *outputFractalState [[ buffer(2) ]],
                                                  uint threadIdentifier [[ thread_position_in_grid ]])
{
    float2 input = inputComplexGrid[threadIdentifier];

    int maximumIterations = inputFractalState->maximumIterations;
    int degree = inputFractalState->degree;
    int threshold = inputFractalState->threshold;
    float2 z = input;
    float2 c = input;

    int iterations = 0;
    for (int i = 1; i < maximumIterations; i++) {
        float2 zDegree = z;
        for (int j = 0; j < degree - 1; j++) {
            zDegree = multiplyC(z, zDegree);
        }
        z = addC(zDegree, c);
        if (absC(z) > threshold) {
            iterations = i;
            break;
        }
    }

    outputFractalState[threadIdentifier].iterations = iterations;
    outputFractalState[threadIdentifier].maximumIterations = maximumIterations;
    outputFractalState[threadIdentifier].z = z;
    outputFractalState[threadIdentifier].c = c;
    outputFractalState[threadIdentifier].degree = degree;
    outputFractalState[threadIdentifier].threshold = threshold;
}

//kernel void juliaFractalStatesForComplexGrid(const device FractalParameters *inputFractalParameters [[ buffer(0) ]],
//                                             const device float2 *inputComplexGrid [[ buffer(1) ]],
//                                             device FractalParameters *outputFractalParameters [[ buffer(2) ]]
//                                             device float *outputComplexGrid [[ buffer(3) ]],
//                                             uint threadIdentifier [[ thread_position_in_grid ]])
//{
//    int maximumIterations = inputFractalParameters->maximumIterations
//    int degree = inputFractalParameters->degree
//    int threshold = inputFractalParameters->threshold
//    float2 z = inputFractalParameters->z
//    float2 c = inputFractalParameters->c
//
//    for (int i = 0; i < maximumIterations; i++) {
//        z = pow(z, degree) + c
//        if abs(z) > threshold {
//            iterations = iteration
//            break;
//        }
//    }
//
//    outputFractalParameters->iterations = iterations
//    outputFractalParameters->degree = degree
//    outputFractalParameters->z = z
//    outputFractalParameters->c = c
//}
//
//kernel void shipFractalStatesForComplexGrid(const device FractalParameters *inputFractalParameters [[ buffer(0) ]],
//                                            const device float2 *inputComplexGrid [[ buffer(1) ]],
//                                            device FractalParameters *outputFractalParameters [[ buffer(0) ]]
//                                            device float *outputComplexGrid [[ buffer(2) ]],
//                                            uint threadIdentifier [[ thread_position_in_grid ]])
//{
//    int maximumIterations = inputFractalParameters->maximumIterations
//    int degree = inputFractalParameters->degree
//    int threshold = inputFractalParameters->threshold
//    float2 z = inputFractalParameters->z
//    float2 c = inputFractalParameters->c
//
//    for (int i = 0; i < maximumIterations; i++) {
//        for iteration in 1...maximumIterations {
//            let real = (z.x * z.x) - (z.y * z.y) - c.x;
//            let imaginary = 2.0 * abs(z.x * z.y) - c.y;
//            z.x = real
//            z.y = imaginary
//            if abs(z) > threshold {
//                iterations = iteration
//                break;
//            }
//        }
//    }
//
//    outputFractalParameters->iterations = iterations
//    outputFractalParameters->degree = degree
//    outputFractalParameters->z = z
//    outputFractalParameters->c = c
//}

inline float2 multiplyC(float2 lhs, float2 rhs)
{
    return { lhs.x * rhs.x - lhs.y * rhs.y, lhs.x * rhs.y + rhs.x * lhs.y };
}
inline float2 addC(float2 lhs, float2 rhs)
{
    return { lhs.x + rhs.x, lhs.y + rhs.y };
}
inline float absC(float2 lhs)
{
    return sqrt(lhs.x * lhs.x + lhs.y * lhs.y);
}