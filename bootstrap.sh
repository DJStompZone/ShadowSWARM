#!/usr/bin/env bash
bash banner.sh

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
#               ShadowSWARM Bootstrap Utility                #
#                       DJ Stomp 2025                        #
#                   "No Rights Reserved"                     #
#                                                            #
##############################################################                                                              

# I. Configuration
if [ -f .env ]; then
  export $(cat .env | xargs)
else
  echo ".env file not found."
  echo "Please run the config.py script first."
  exit 1
fi
WORKER_NODES=(${WORKER_HOSTNAMES//,/ })

# II. Initialization
MASTER_IP=$(hostname -I | awk '{print $1}')
echo "Initializing Docker Swarm on master node ($MASTER_IP)..."
docker swarm init --advertise-addr "$MASTER_IP"

# III. Authorization
WORKER_JOIN_TOKEN=$(docker swarm join-token worker -q)
echo "Worker join token: $WORKER_JOIN_TOKEN"

# IV. Instantiation
for WORKER_HOSTNAME in "${WORKER_NODES[@]}"; do
    echo "Triggering worker node ($WORKER_HOSTNAME) to join the swarm..."
    ssh "$WORKER_HOSTNAME" "docker swarm join --token $WORKER_JOIN_TOKEN $MASTER_IP:2377"
done

# V. Confirmation
echo "Swarm setup complete. Nodes in the Swarm:"
docker node ls