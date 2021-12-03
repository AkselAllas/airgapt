# Airgapt - airgapped apt 

Script for setup of Proxy for package management of airgapped Ubuntu (apt) via socks5 & ssh proxy.

## Usage
Use either: 

--) Docker image & use `runDocker.sh`

--) Bash script & use `airgapt.sh`

### Docker usage 

Make sure you have docker installed

0) `wget https://raw.githubusercontent.com/AkselAllas/airgapt/master/runDocker.sh`

1) Edit `runDocker.sh` input variables
```
LOCAL_SOCKS_PORT=44444
LOCAL_USER="kali" #This user must match your LOCAL_SSH_KEY's owner
LOCAL_USER_ID=1000
TARGET="example.domain"
TARGET_USER="ubuntu"
TARGET_FORWARDED_PORT="6666"
LOCAL_SSH_KEY_PATH="/home/${LOCAL_USER}/.ssh/id_rsa"
REMOTE_SSH_KEY_PATH="/home/${LOCAL_USER}/.ssh/custom_key"
```
2) Run `./runDocker.sh`

### Bash script

0) `wget https://raw.githubusercontent.com/AkselAllas/airgapt/master/airgapt.sh`

1) Edit `airgapt.sh` input variables
```
LOCAL_SOCKS_PORT=44444
LOCAL_USER="kali"
TARGET="example.domain"
TARGET_USER="ubuntu"
TARGET_FORWARDED_PORT="6666"
LOCAL_SSH_KEY_PATH="/home/${LOCAL_USER}/.ssh/id_rsa"
REMOTE_SSH_KEY_PATH="/home/${LOCAL_USER}/.ssh/custom_key"
```
2) Run `.airgapth.sh`

## Custom proxy queries
In your target machine you can use proxy to request arbitrary URLs. For that run
```
curl -L --socks5 localhost:6666 google.com
