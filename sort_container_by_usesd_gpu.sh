
#!/bin/bash

function get_gpu_mem_by_container_name {
    local container_id=$1
    local container_count=$(echo $container_id|awk '{print NF}')

    if [ "$container_count" -gt 1 ]; then
        echo "More than one container found with name $1. Exiting."
        exit 1
    fi

    # Get PIDs
    local pids=$(docker top $container_id | awk '{if(NR>1) print $2}')
   
    # Get GPU memory usage
    local total_gpu_mem=0
    for pid in $pids; do
        local gpu_mem=$(echo "$NVIDIA_SMI_OUTPUT" | grep -w $pid | awk '{print $8}')
        local gpu_num=$(echo $gpu_mem|awk '{print NF}')
        if [ "$gpu_num" -gt 1 ]; then
            local mems=($gpu_mem)  # make string into array
            for mem in "${mems[@]}"; do
                total_gpu_mem=$((total_gpu_mem + mem))
            done
        else
            total_gpu_mem=$((total_gpu_mem + gpu_mem))
        fi
    done
    echo $total_gpu_mem
}

# Function to list all containers and their GPU memory usage
function list_gpu_usage_by_container {
    local container_ids=$(docker ps --format "{{.Names}}")
    declare -A container_gpu_usage

    for id in $container_ids; do
        # echo "in loop: $id"
        local gpu_mem=$(get_gpu_mem_by_container_name $id)
        if [ "$gpu_mem" -gt 0 ]; then
            container_gpu_usage[$id]=$gpu_mem
        fi
    done

    # Sort and print the results
    for id in "${!container_gpu_usage[@]}"; do
        echo "$id: ${container_gpu_usage[$id]} MiB"
    done | sort -t: -k2 -nr
}

# Main function to encapsulate the script logic
function main {
    echo "GPU Memory Usage by Container:"
    NVIDIA_SMI_OUTPUT=$(nvidia-smi pmon -c 1 -s um)
    list_gpu_usage_by_container
}

# Call the main function to execute the script
main
