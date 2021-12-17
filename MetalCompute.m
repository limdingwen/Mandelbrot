#import <Foundation/Foundation.h>
#import "BigFloat.h"
@import Metal;
@import MetalKit;

id<MTLDevice> g_device;
id<MTLComputePipelineState> g_process_pixel_pso;
id<MTLBuffer> g_buffer_pixels;
id<MTLComputeCommandEncoder> g_compute_encoder;
id<MTLCommandBuffer> g_command_buffer;

bool init_metal_compute(int pixels_size)
{
    NSError *error = nil;
    
    g_device = MTLCreateSystemDefaultDevice();
    id<MTLLibrary> default_library = [g_device newDefaultLibrary];
    if (default_library == nil)
        return false;
    id<MTLFunction> process_pixel = [default_library newFunctionWithName:@"process_pixel"];
    if (process_pixel == nil)
        return false;
    g_process_pixel_pso = [g_device newComputePipelineStateWithFunction:process_pixel error:&error];
    if (error != nil)
        return false;
    id<MTLCommandQueue> command_queue = [g_device newCommandQueue];
    g_buffer_pixels = [g_device newBufferWithLength:pixels_size options:MTLResourceStorageModeShared];
    g_command_buffer = [command_queue commandBuffer];
    g_compute_encoder = [g_command_buffer computeCommandEncoder];
    
    return true;
}

bool metal_compute_pixels(int width,
                          int height,
                          struct fp256 width_reciprocal,
                          struct fp256 height_reciprocal,
                          struct fp256 size,
                          struct fp256 size_x,
                          struct fp256 center_x,
                          struct fp256 center_y,
                          uint64_t iterations,
                          uint8_t *pixels,
                          int offset,
                          int interval)
{
    if (g_process_pixel_pso == nil)
        return false;
    [g_compute_encoder setComputePipelineState:g_process_pixel_pso];
    [g_compute_encoder setBytes:&width length:sizeof(int) atIndex:0];
    [g_compute_encoder setBytes:&height length:sizeof(int) atIndex:1];
    [g_compute_encoder setBytes:&width_reciprocal length:sizeof(struct fp256) atIndex:2];
    [g_compute_encoder setBytes:&height_reciprocal length:sizeof(struct fp256) atIndex:3];
    [g_compute_encoder setBytes:&size length:sizeof(struct fp256) atIndex:4];
    [g_compute_encoder setBytes:&size_x length:sizeof(struct fp256) atIndex:5];
    [g_compute_encoder setBytes:&center_x length:sizeof(struct fp256) atIndex:6];
    [g_compute_encoder setBytes:&center_y length:sizeof(struct fp256) atIndex:7];
    [g_compute_encoder setBytes:&iterations length:sizeof(uint64_t) atIndex:8];
    [g_compute_encoder setBuffer:g_buffer_pixels offset:0 atIndex:9];
    [g_compute_encoder setBytes:&offset length:sizeof(int) atIndex:10];
    MTLSize grid_size = MTLSizeMake(interval, 1, 1);
    NSUInteger thread_group_size_1d = g_process_pixel_pso.maxTotalThreadsPerThreadgroup;
    if (thread_group_size_1d > interval)
        thread_group_size_1d = interval;
    MTLSize thread_group_size = MTLSizeMake(thread_group_size_1d, 1, 1);
    [g_compute_encoder dispatchThreads:grid_size threadsPerThreadgroup:thread_group_size];
    [g_command_buffer commit];
    [g_command_buffer waitUntilCompleted];
    
    memcpy(pixels, g_buffer_pixels.contents, g_buffer_pixels.length);
    return true;
}
