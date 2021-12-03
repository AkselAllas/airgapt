#!/usr/bin/env bash
set -e
set -u

#### VARIABLES TO CHANGE ###################################################################
LOCAL_SOCKS_PORT=44444
LOCAL_USER="aksel" #This user must match your LOCAL_SSH_KEY's permissions
LOCAL_USER_ID=1000
TARGET="ec2-54-74-184-145.eu-west-1.compute.amazonaws.com"
TARGET_USER="ubuntu"
TARGET_FORWARDED_PORT="6666"
LOCAL_SSH_KEY_PATH="/home/aksel/.ssh/id_rsa"
REMOTE_SSH_KEY_PATH="/home/aksel/.ssh/awsKaksel.pem"
############################################################################################

LOCAL_SSH_KEY_ARGUMENT="-i ${LOCAL_SSH_KEY_PATH}" 

docker run -it -p 22222:22 -v ${LOCAL_SSH_KEY_PATH}:/${LOCAL_SSH_KEY_PATH}:ro -v ${LOCAL_SSH_KEY_PATH}.pub:/home/${LOCAL_USER}/.ssh/authorized_keys:ro -v ${REMOTE_SSH_KEY_PATH}:/etc/ssh/keys/airgap_key -e SSH_USERS="${LOCAL_USER}:${LOCAL_USER_ID}:${LOCAL_USER_ID}" -e LOCAL_SOCKS_PORT=$LOCAL_SOCKS_PORT -e LOCAL_USER=$LOCAL_USER -e TARGET=${TARGET} -e TARGET_USER=${TARGET_USER} -e TARGET_FORWARDED_PORT=${TARGET_FORWARDED_PORT} -e LOCAL_SSH_KEY_PATH=${LOCAL_SSH_KEY_PATH} -e REMOTE_SSH_KEY_PATH="/etc/ssh/keys/airgap_key" -e REMOTE_SSH_KEY_ARGUMENT="" -e LOCAL_SSH_KEY_ARGUMENT="${LOCAL_SSH_KEY_ARGUMENT}" airgapt
