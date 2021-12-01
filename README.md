# Airgapt - airgapped apt 

Script for setup of Proxy for package management of airgapped Ubuntu via socks5 & ssh proxy. ᵃˡˡᵉᵍᵉᵈˡʸ

### Usage

1) Clone repository `git clone git@github.com:AkselAllas/airgapt.git`
2) Edit `airgapt.sh` values of:
```
SOCKS_PORT=44444
LOCAL_USER="kali"
SSH_KEY_ARGUMENT=""
TARGET="changeme"
TARGET_USER="ubuntu"
TARGET_PORT="6666"
```
3) `sudo ./airgapt.sh`
