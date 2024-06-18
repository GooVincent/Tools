def test_speep_host_to_gpu():
    def calculate_memory_size(tensor):
        num_elements = tensor.numel()
        element_size = tensor.element_size()
        total_memory_size = num_elements * element_size
        total_memory_size_mb = total_memory_size / (1024 ** 2)
        return total_memory_size, total_memory_size_mb

    import torch

    # Generate a large tensor
    tensor_size = (10000, 10000)
    host_tensor = torch.randn(tensor_size)
    total_mem_size, total_mem_size_mb = calculate_memory_size(host_tensor)

    print(f'total_mem_size:{total_mem_size} B, total_mem_size_mb:{total_mem_size_mb:.3f} MB')

    # Measure time to copy data to the GPU
    if torch.cuda.is_available():
        start_event = torch.cuda.Event(enable_timing=True)
        end_event = torch.cuda.Event(enable_timing=True)

        start_event.record()
        gpu_tensor = host_tensor.cuda()
        end_event.record()

        # Waits for everything to finish running
        torch.cuda.synchronize()
        time_to_gpu = start_event.elapsed_time(end_event) / 1000.0  # Convert milliseconds to seconds
        print(f"Time to copy data to GPU: {time_to_gpu:.6f} seconds, speed:{total_mem_size_mb/time_to_gpu:.6f} MB/s")

        # Measure time to copy data from the GPU to the host
        start_event.record()
        host_tensor_back = gpu_tensor.cpu()
        end_event.record()

        # Waits for everything to finish running
        torch.cuda.synchronize()
        time_to_host = start_event.elapsed_time(end_event) / 1000.0  # Convert milliseconds to seconds
        print(f"Time to copy data to host: {time_to_host:.6f} seconds, speed:{total_mem_size_mb/time_to_gpu:.6f} MB/s")
    else:
        print("CUDA is not available.")


if __name__ == '__main__':
    test_speep_host_to_gpu()
