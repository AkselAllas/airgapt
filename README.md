# Airgapt - "airgapped" apt 

Script for setup of package management Proxy for situations where you can ssh, but target doesn't have network. 

Uses socks5 & ssh proxy.

<img src="https://user-images.githubusercontent.com/26136082/144587454-c442d3b1-525a-49c9-88cb-07b7742b84d5.png" alt="drawing" width="450"/>

## Usage
Choose **one** of these: 

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

### Bash script usage

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
2) Run `.airgapt.sh`

## Custom proxy queries
In your target machine you can use proxy to request arbitrary URLs. For that run
```
curl -L --socks5 localhost:6666 google.com
```
### Future plans
[ ] add yum, pac, pkg detection & proxy setup to `ensure_remote_server_has_proxy_config()` function
