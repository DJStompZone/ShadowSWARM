#!/usr/bin/env python3

##############################################################
#                                                            #
#  .::::::. ::                       ::                      #  
# ;;;`    ` ;;;                      ;;;                     #
# '[==/[[[[,[[[[cc,,.  ,ccc,    ,c[[[cc, ,ccc,'[[, [[, [['   #
#   '''    $$$$"""$$$ $$$cc$$$ $$""""Y$$$$$"c$$$Y$ $$$ $P    #
#  88b    dP888   "88o888   88888o,,od8P888   88 "88"888     #
#   "YMmMY" MMM    YMM "YUM" MP"YUMMMP"  "YUMMP   "M "M"     #                                               
#                                                            #
#  .::::::..::    .   .::::::.     :::::::..   .        :    #
# ;;;`    `';;,  ;;  ;;;' ;;`;;    ;;;;``;;;;  ;;,.    ;;;   #
# '[==/[[[[,'[[, [[, [[' ,[[ '[[,   [[[,/[[['  [[[[, ,[[[[,  #
#   '''    $  Y$c$$$c$P c$$$cc$$$c  $$$$$$c    $$$$$$$$"$$$  #
#  88b    dP   "88"888   888   888  888b "88bo,888 Y88" 888o #
#   "YMmMY"     "M "M"   YMM   \"\"`MMMM   "W" MMM  M'  "MMM #
#                                                            #
#                 ShadowSWARM Setup Utility                  #
#                       DJ Stomp 2025                        #
#                   "No Rights Reserved"                     #
#                                                            #
##############################################################
                                                                

import os
import subprocess
from pathlib import Path

def prompt_user_input(prompt, default=None):
    """Prompt the user for input with an optional default."""
    if default:
        user_input = input(f"{prompt} [{default}]: ")
        return user_input.strip() if user_input.strip() else default
    else:
        return input(f"{prompt}: ").strip()

def gather_configuration():
    """Prompt the user to gather configuration for Swarm setup."""
    print("Welcome to ShadowSWARM.")
    master_hostname = prompt_user_input("Enter the master node hostname", "localhost")
    master_ip = subprocess.check_output(["hostname", "-I"]).decode().strip().split()[0]
    print(f"Detected master node IP: {master_ip}")
    print("Enter the hostnames or IPs of the worker nodes, separated by commas.")
    worker_nodes = prompt_user_input("Worker node hostnames/IPs")
    print("\nConfiguration Summary:")
    print(f"Master Hostname: {master_hostname}")
    print(f"Master IP: {master_ip}")
    print(f"Worker Nodes: {worker_nodes}")
    confirm = prompt_user_input("Is this configuration correct? (y/n)", "y").lower()
    if confirm != "y":
        print("Setup aborted. Please run the script again.")
        exit(1)
    return master_hostname, master_ip, worker_nodes

def write_env_file(master_hostname, master_ip, worker_nodes):
    """Write environment variables to a .env file."""
    env_file = Path(".env")
    worker_hostnames = ",".join(worker_nodes.split(","))
    with open(env_file, "w") as f:
        f.write(f"MASTER_HOSTNAME={master_hostname}\n")
        f.write(f"MASTER_IP={master_ip}\n")
        f.write(f"WORKER_HOSTNAMES={worker_hostnames}\n")
    print(f"Configuration saved to {env_file.absolute()}.")

def run_bootstrap_script():
    """Run the bootstrap utility."""
    try:
        print("Starting ShadowSWARM bootstrap...")
        subprocess.run(["bash", "./bootstrap.sh"], check=True)
        print("Swarm setup complete!")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred during Swarm setup: {e}")
        exit(1)

def main():
    """Main function for the CLI."""
    master_hostname, master_ip, worker_nodes = gather_configuration()
    write_env_file(master_hostname, master_ip, worker_nodes)
    run_bootstrap_script()

if __name__ == "__main__":
    main()