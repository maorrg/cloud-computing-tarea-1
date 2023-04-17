#!/bin/bash

# Set the maximum CPU usage and memory usage thresholds
cpu_threshold=80
memory_threshold=75

# Set the destination host for the live migration
destination_host=192.168.1.100
port=3000
password=12345

# Set the name of the virtual machine to monitor and migrate
vm_host_name=ubuntu2
vm_name=ubuntu

while true
do
  # Get the current CPU usage percentage for the VM
  cpu_usage=$(VBoxManage metrics $vm_name get CPU/Load/User|awk '{print $NF}'|cut -d'.' -f1)
  
  # Get the current memory usage percentage for the VM
  memory_usage=$(VBoxManage metrics $vm_name get Memory/Usage/Used|awk '{print $NF}'|cut -d'.' -f1)
  
  # Check if the CPU usage or memory usage exceeds the threshold
  if [ "$cpu_usage" -gt "$cpu_threshold" ] && [ "$memory_usage" -gt "$memory_threshold" ]
  then
    echo "CPU usage for $vm_name is above the threshold of $cpu_threshold% and memory usage is above the threshold of $memory_threshold% - triggering live migration..."
    #Prepare the host vm machine
    VBoxManage modifyvm $vm_host_name --teleporter on --teleporterport $port --teleporterpassword $password
    
    # Initiate a live migration to the specified host
    VBoxManage controlvm $vm_name teleport --host $destination_host --port $port --password $password
    
    echo "Live migration completed."
  fi
  
  # Sleep for 10 seconds before checking again
  sleep 10
done &
