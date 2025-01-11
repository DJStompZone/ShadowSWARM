<div align="center"><h1>ShadowSwarm</h1><br><img src="https://github.com/user-attachments/assets/621f87fc-f841-44b4-a6b7-7c23f9530860" width="90%"></div><hr>


A streamlined framework for setting up a multi-node, GPU-accelerated, distributed system for PyTorch workloads using Docker Swarm. With **ShadowSWARM**, you can quickly configure and deploy a scalable environment for machine learning inference or training across multiple machines.

## **Features**
- Automated Docker Swarm initialization and worker node setup.
- Flexible configuration using interactive CLI (`config.py`).
- Dynamic IP and hostname detection for seamless multi-node deployment.
- Streamlined distributed PyTorch workloads with Fully Sharded Data Parallel (FSDP).
- Integrated **Streamlit** interface for easy interaction with your system.

## **Quickstart Guide**

### **Prerequisites**
1. **Docker and NVIDIA Drivers**:
   - Install Docker and NVIDIA drivers on all machines.
   - Install the NVIDIA Container Toolkit:
     ```bash
     sudo apt-get install -y nvidia-container-toolkit
     sudo systemctl restart docker
     ```
   - Verify Docker GPU support:
     ```bash
     docker run --rm --gpus all nvidia/cuda:12.1.1-base-ubuntu20.04 nvidia-smi
     ```

2. **Python 3.8+**:
   - Install Python on the master machine if you haven't already:
     ```bash
     sudo apt-get install python3 python3-pip
     ```

3. **Passwordless SSH**:
   - Configure passwordless SSH from the master to all worker nodes:
     ```bash
     ssh-keygen -t rsa -b 2048
     ssh-copy-id user@worker-ip-here
     ```

### **Installation**

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/DJStompZone/shadowswarm.git
   cd shadowswarm
   ```

2. **Build the Docker Image**:
   Build the image for the system:
   ```bash
   docker build -t shadowswarm-app .
   ```

### **Setup and Deployment**

1. **Run the Configuration Script**:
   Use the interactive CLI to gather and validate the necessary configuration:
   ```bash
   python3 config.py
   ```
   This script will:
   - Prompt for the master and worker node details.
   - Save the configuration to a `.env` file.
   - Start the `bootstrap.sh` script to initialize Docker Swarm and add workers.

2. **Verify Swarm Setup**:
   Check the Swarm status after the bootstrap:
   ```bash
   docker node ls
   ```

3. **Deploy the Docker Stack**:
   Once the Swarm is ready, deploy the application:
   ```bash
   docker stack deploy --compose-file docker-compose.yml shadowswarm
   ```

### **Access the Streamlit App**

1. Open a browser and navigate to the **master node IP**:
   ```
   http://<master-node-ip>:8501
   ```

2. Use the **Streamlit interface** to interact with your distributed PyTorch system.

## **File Structure**

```
shadowswarm/
├── config.py            # CLI script for gathering configuration
├── bootstrap.sh         # Script for initializing Docker Swarm and adding workers
├── docker-compose.yml   # Docker Swarm stack configuration
├── Dockerfile           # Docker image definition
├── .env                 # Environment variables for the deployment
├── app/                 # Application directory
│   ├── main.py          # PyTorch and Streamlit code
│   └── utils.py         # Utility functions
```

## **How It Works**

1. **Configuration**:
   - `config.py` prompts for master and worker node details, saves them to `.env`, and triggers `bootstrap.sh`.

2. **Swarm Initialization**:
   - `bootstrap.sh` initializes Docker Swarm on the master node and connects workers via SSH.

3. **Stack Deployment**:
   - `docker-compose.yml` orchestrates the master and worker containers, assigning roles using environment variables.

4. **Distributed Workload**:
   - The master node manages the distributed PyTorch workload across all nodes using Fully Sharded Data Parallel (FSDP).

## **Environment Variables**

| Variable           | Description                                |
|--|--|
| `MASTER_HOSTNAME`  | Hostname of the master node.               |
| `MASTER_IP`        | IP address of the master node.             |
| `WORKER_HOSTNAMES` | Comma-separated list of worker hostnames.  |
| `NODE_RANK`        | Rank of the node in the distributed setup. |
| `WORLD_SIZE`       | Total number of nodes in the cluster.      |
| `MASTER_PORT`      | Port for master-worker communication.      |

## **Troubleshooting**

1. **Docker Swarm Issues**:
   - Check if Swarm is initialized:
     ```bash
     docker info
     ```
   - Verify worker nodes are connected:
     ```bash
     docker node ls
     ```

2. **SSH Issues**:
   - Test passwordless SSH from the master:
     ```bash
     ssh <worker-ip>
     ```

3. **Container Logs**:
   - Check the logs for the master or workers:
     ```bash
     docker service logs shadowswarm_master
     docker service logs shadowswarm_worker1
     ```

4. **GPU Issues**:
   - Ensure GPUs are accessible:
     ```bash
     docker run --rm --gpus all nvidia/cuda:12.1.1-base-ubuntu20.04 nvidia-smi
     ```

## **Scaling**

1. Add a new worker node to the swarm:
   ```bash
   docker swarm join --token <worker-join-token> <master-ip>:2377
   ```

2. Update the `WORKER_HOSTNAMES` in the `.env` file to include the new worker.

3. Re-deploy the stack:
   ```bash
   docker stack deploy --compose-file docker-compose.yml shadowswarm
   ```

## **Contributing**

Contributions are welcome! Please open an issue or submit a pull request if you have problems, suggestions, or improvements.

## **License**

This project is licensed under the [MIT License](LICENSE).
