#import <Foundation/Foundation.h>
@import Metal;
@import MetalKit;

id<MTLDevice> g_device;
id<MTLComputePipelineState> g_process_pixel_pso;
id<MTLBuffer> g_buffer_results;
id<MTLCommandQueue> g_command_queue;

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
    g_command_queue = [g_device newCommandQueue];
    g_buffer_results = [g_device newBufferWithLength:pixels_size options:MTLResourceStorageModeShared];
    
    return true;
}

struct fp256
{
    int sign;
    uint32_t man[8];
};

struct fp512
{
    int sign;
    uint32_t man[16];
};

uint64_t *metal_compute_pixels(int width,
                          int height,
                          struct fp256 width_reciprocal,
                          struct fp256 height_reciprocal,
                          struct fp256 size,
                          struct fp256 size_x,
                          struct fp256 center_x,
                          struct fp256 center_y,
                          uint64_t iterations,
                          uint64_t offset,
                          int interval)
{
    id<MTLCommandBuffer> command_buffer = [g_command_queue commandBuffer];
    id<MTLComputeCommandEncoder> compute_encoder = [command_buffer computeCommandEncoder];
    [compute_encoder setComputePipelineState:g_process_pixel_pso];
    [compute_encoder setBytes:&width length:sizeof(int) atIndex:0];
    [compute_encoder setBytes:&height length:sizeof(int) atIndex:1];
    [compute_encoder setBytes:&width_reciprocal length:sizeof(struct fp256) atIndex:2];
    [compute_encoder setBytes:&height_reciprocal length:sizeof(struct fp256) atIndex:3];
    [compute_encoder setBytes:&size length:sizeof(struct fp256) atIndex:4];
    [compute_encoder setBytes:&size_x length:sizeof(struct fp256) atIndex:5];
    [compute_encoder setBytes:&center_x length:sizeof(struct fp256) atIndex:6];
    [compute_encoder setBytes:&center_y length:sizeof(struct fp256) atIndex:7];
    [compute_encoder setBytes:&iterations length:sizeof(uint64_t) atIndex:8];
    [compute_encoder setBuffer:g_buffer_results offset:0 atIndex:9];
    [compute_encoder setBytes:&offset length:sizeof(uint64_t) atIndex:10];
    MTLSize grid_size = MTLSizeMake(interval, 1, 1);
    NSUInteger thread_group_size_1d = g_process_pixel_pso.maxTotalThreadsPerThreadgroup;
    if (thread_group_size_1d > interval)
        thread_group_size_1d = interval;
    MTLSize thread_group_size = MTLSizeMake(thread_group_size_1d, 1, 1);
    [compute_encoder dispatchThreads:grid_size threadsPerThreadgroup:thread_group_size];
    [compute_encoder endEncoding];
    [command_buffer commit];
    [command_buffer waitUntilCompleted];
    
    return g_buffer_results.contents;
}
