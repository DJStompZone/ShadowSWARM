#!/usr/bin/env bash

YLW="\x1b[33m"
YLWB="\x1b[33;1m"
RED="\x1b[31m"
REDB="\x1b[31;1m"
GRN="\x1b[32m"
GRNB="\x1b[32;1m"
BLU="\x1b[34m"
BLUB="\x1b[34;1m"
PPL="\x1b[35m"
PPLB="\x1b[35;1m"
RESET="\x1b[0m"
REPO="djstomp/shadowswarm-app"
SERVICE_NAME="shadowswarm"

clear

bash banner.sh
sleep 2
echo -e "                   [ ${PPLB}Shadow${YLWB}SWARM${RESET} ]"
sleep 1
echo -e "                    ${GRN}Launch Script${RESET}"
sleep 1
echo -e "                    ${REDB}DJ Stomp 2025${RESET}\n\n\n"
sleep 3
echo -e "              ${YLW}Initializing, please wait...${RESET}"
sleep 4

clear

echo -e "${GRN}[1/4] ${PPL}Fetching latest image for ${YLWB}${REPO}${PPL} from ${YLWB}Docker Hub${PPL}...${RESET}"
sleep 1
docker pull "${REPO}:latest"
sleep 1
echo -e "${GRN}[2/4] ${PPL}Invoking ${YLWB}Bootstrap Utility${PPL}...${RESET}"
sleep 1
chmod +x bootstrap.sh
./bootstrap.sh
sleep 1
echo -e "${GRN}[3/4] ${PPL}Removing any ${PPLB}stale instances${PPL} of ${YLWB}${SERVICE_NAME}${PPL} service...${RESET}"
sleep 1
docker stack rm $SERVICE_NAME
sleep 1
echo -e "${GRN}[3/4] ${PPL}Deploying ${YLWB}${SERVICE_NAME}${PPL} service to the ${PPLB}Docker stack${PPL}...${RESET}"
sleep 1
docker stack deploy --compose-file docker-compose.yml shadowswarm
sleep 1
echo -e "[${REDB}---${YLW}---${GRN}---${RESET}]${BLU} (0%) ${PPL}Waiting for ${YLWB}${SERVICE_NAME}${PPL} deployment to initialize...${RESET}"

sleep 9

echo -e "[${REDB}|||${YLW}---${GRN}---${RESET}]${BLU} (33%) ${PPL}Waiting for ${YLWB}${SERVICE_NAME}${PPL} deployment to initialize...${RESET}"

sleep 7

echo -e "[${REDB}|||${YLW}|||${GRN}---${RESET}]${BLU} (66%) ${PPL}Waiting for ${YLWB}${SERVICE_NAME}${PPL} deployment to initialize...${RESET}"

sleep 5

echo -e "[${REDB}|||${YLW}|||${GRN}||-${RESET}]${BLU} (95%) ${PPL}Waiting for ${YLWB}${SERVICE_NAME}${PPL} deployment to initialize...${RESET}"

sleep 3

echo -e "[${REDB}|||${YLW}|||${GRN}|||${RESET}]${BLU} (100%) ${PPL}That's probably long enough! ${YLW}(${YLWB}shrug${YLW})${RESET}"

sleep 2

echo -e "${GRN} [4/4] ${PPL}Checking logs for ${YLWB}master${PPL} service node...${RESET}"

sleep 1
docker service logs shadowswarm_master --since 2m -t
sleep 1

echo -e "${GRN} [4/4] ${PPL}Checking logs for ${YLWB}worker1${PPL} service node...${RESET}"

sleep 1
docker service logs shadowswarm_worker1 --since 2m -t
sleep 1

echo -e "${GRN} [4/4] ${PPL}Checking logs for ${YLWB}worker2${PPL} service node...${RESET}"

sleep 1
docker service logs shadowswarm_worker2 --since 2m -t

# echo -e "${PPL}Launch routine ${GRNB}completed${PPL}, ${PPLB}please review the above logs${PPL} to confirm success.${RESET}"
sleep 1
echo -e "${GRN} [4/4] ${PPL}Validating ${YLWB}${SERVICE_NAME}${PPL} deployment status...${RESET}"
sleep 1
SERVICE_STATUS=$(docker stack services "$SERVICE_NAME" --format '{{.Name}}:{{.Replicas}}')

SUCCESS_COUNT=0
FAILURE_COUNT=0

while IFS= read -r line; do
    NAME=$(echo "$line" | cut -d':' -f1)
    REPLICAS=$(echo "$line" | cut -d':' -f2)
    RUNNING=$(echo "$REPLICAS" | cut -d'/' -f1)
    DESIRED=$(echo "$REPLICAS" | cut -d'/' -f2)

    if [[ "$RUNNING" == "$DESIRED" ]]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    elif [[ "$RUNNING" -gt 0 ]]; then
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
    fi
done <<< "$SERVICE_STATUS"

if [[ "$SUCCESS_COUNT" -eq 0 && "$FAILURE_COUNT" -eq 0 ]]; then
    echo -e "${REDB}TOTAL FAILURE: No services are running properly in the stack.${RESET}"
    exit 1
elif [[ "$FAILURE_COUNT" -gt 0 ]]; then
    echo -e "${YLWB}PARTIAL SUCCESS: Some services are running, but others are not fully initialized.${RESET}"
else
    echo -e "${GRNB}SUCCESS: All services are running with the desired number of replicas.${RESET}"
fi
