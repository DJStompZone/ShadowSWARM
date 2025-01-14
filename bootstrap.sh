#!/usr/bin/env bash
bash banner.sh

##############################################################
#                                                            #
#               ShadowSWARM Bootstrap Utility                #
#                       DJ Stomp 2025                        #
#                   "No Rights Reserved"                     #
#                                                            #
##############################################################

# I. Configuration
if [ -f .env ]; then
  export $(cat .env | xargs)
else
  echo "Error: .env file not found."
  echo "Please run the config.py script first."
  exit 1
fi
WORKER_NODES=(${WORKER_HOSTNAMES//,/ })
declare -A HOSTNAME_TO_IP
HOSTNAME_TO_IP["Tesla-Server"]=192.168.17.121
HOSTNAME_TO_IP["hidden-server"]=192.168.17.235

# II. Initialization
MASTER_IP=$(hostname -I | awk '{print $1}')
echo "Initializing Docker Swarm on master node ($MASTER_IP)..."

if docker info | grep -q "Swarm: active"; then
  echo "Master node is already part of a swarm. Skipping initialization."
else
  docker swarm init --advertise-addr "$MASTER_IP"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to initialize Docker Swarm on master node."
    exit 1
  fi
fi

# III. Authorization
WORKER_JOIN_TOKEN=$(docker swarm join-token worker -q)
if [ -z "$WORKER_JOIN_TOKEN" ]; then
  echo "Error: Failed to retrieve worker join token."
  exit 1
fi
echo "Worker join token: $WORKER_JOIN_TOKEN"

# IV. Instantiation
for WORKER_HOSTNAME in "${WORKER_NODES[@]}"; do
  WORKER_IP=${HOSTNAME_TO_IP[$WORKER_HOSTNAME]}
  
  if [ -z "$WORKER_IP" ]; then
    echo "Error: No IP address found for worker hostname $WORKER_HOSTNAME. Skipping."
    continue
  fi
  
  echo "Triggering worker node ($WORKER_HOSTNAME - $WORKER_IP) to join the swarm..."
  ssh "$WORKER_IP" "docker swarm join --token $WORKER_JOIN_TOKEN $MASTER_IP:2377"
  
  if [ $? -ne 0 ]; then
    echo "Error: Worker node $WORKER_HOSTNAME failed to join the swarm."
  else
    echo "Worker node $WORKER_HOSTNAME successfully joined the swarm."
  fi
done

# V. Confirmation
echo "Swarm setup complete. Nodes in the Swarm:"
docker node ls
