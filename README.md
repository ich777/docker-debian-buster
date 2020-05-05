# Debian Buster with Nvidia Drivers in Docker optimized for Unraid
This Container is a full Debian Buster Xfce4 Desktop environment with Nvidia Drivers installed also it has a noVNC webGUI and all the basic tools pre-installed.

I mainly created it for playing Steam games with In Home Streaming to my Raspberry Pi, an older laptop and my mobile phone (please not that In Home Streaming also works over the internet).
All games including windows games through Proton should just works fine, a few tested games where: Pikuniku, Dirt Rally, Broforce, Astroneer, CS: Source.

If you want to install some other application you can do that by creating a user.sh and mounting it to the container to /opt/scripts/user.sh (a standard bash script should do the trick).

Storage Note: All things that are saved in the container should be in the home or a subdirectory in your homefolder, all files that are store outside your homefolder are not persistant and will be wiped if there is an update of the container or you change something in the template.
You can also mount any directory from your server to /mnt/... (I recommend you to do this if you got a big Steam Library and save everything there).

**CONTROLLER:** Note that the controller works in Big Picture mode but will not work in the games since Unraid doesn't have the kernel modules 'joydev' and 'uinput' loaded/available. If you want to use the controller please map the buttons to key inputs and everything works just fine.

**STEAM PASSWORD:** The container will not store the password from your Steam account since there is a bug if you save it and try to restart Steam it will not show up (if already got this problem simply restart the container and you should be able to log in again).

**NETWORK MODE:** If you want to use the container as a Steam In Home Streaming host device you should set the network type to bridge and assign it it's own IP, if you don't do this the traffic will be routed through the internet since Steam thinks you are on a different network.

**ATTENTION:** This container is not finished yet and currently in alpha state.

**Storage Note:** All things that are saved in the container should be in the home or a subdirectory in your homefolder, all files that are store outside your homefolder are not persistant and will be wiped if there is an update of the container or you change something in the template.

### **ATTENTION:** This container is not finished yet and currently in alpha state.

If you got any questions, suggestions for improvements or can help with the password issue above please feel free to open an issue on my Github or write a forum post.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Home folder | /debian |
| NVIDIA_VISIBLE_DEVICES | Your GPU UUID here. | GPU-xxxx... |
| NVIDIA_DRIVER_CAPABILITIES | Only change if you know what you are doing! | all |
| NVIDIA_BUILD_OPTS | Only change if you know what you are doing! | -a -N -q --instal... |
| NV_DRV_V | Leave empty and the container tries to get your driver version that is installed on the Host. | |
| DISPLAY | Only change if you know what you are doing! | :0 |
| ENABLE_VNC_SRV | Set to 'true' if you want to enable the VNC Server and the WebGUI otherwise leave empty. | true |
| DFP_NR | Change only if you know what you are doing (If the container doesn't start up propperly try a different number 0, 1, 2, 3 - on my GTX1650Ti: '0', on my GTX1050Ti '1', leave empty if you got a monitor attached to the used GPU). | 1 |
| V_TERM_NR | Only change if you know what you are doing! | 1 |
| PCI_ADDR | Leave empty and the container tries to get your PCI Address (works only if you got one GPU installed - if you enter it manually put it in this format 'PCI:01:00:0' or 'PCI:03:00:0'). | |
| USER_LOCALES | Enter your prefered locales, you can find a full list of supported languages in: '/usr/share/i18n/SUPPORTED' (eg: 'en_US.UTF-8 UTF8' or 'de_DE.UTF-8 UTF-8',...) | en_US.UTF-8 UTF8 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | User file permission mask for newly created files | 000 |
| DATA_PERM | Data permissions for main storage folder | 770 |

## Run example
```
docker run --name DebianBuster-Nvidia -d \
    -p 8080:8080 \
    --env 'ROOT_PWD=superstrongpassword' \
    --env 'NVIDIA_VISIBLE_DEVICES=GPU-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' \
    --env 'NVIDIA_DRIVER_CAPABILITIES=all' \
    --env 'NVIDIA_BUILD_OPTS=-a -N -q --install-libglvnd --ui=none --no-kernel-module' \
    --env 'DISPLAY=:0' \
    --env 'ENABLE_VNC_SRV=true' \
    --env 'DFP_NR=1' \
    --env 'V_TERM_NR=1' \
    --env 'USER_LOCALES=en_US.UTF-8 UTF8' \
    --env 'UID=99' \
    --env 'GID=100' \
    --env 'UMASK=000' \
    --env 'DATA_PERM=770' \
    --volume /mnt/user/appdata/debian-buster:/debian \
    --restart=unless-stopped \
    --shm-size=2G \
    --runtime=nvidia \
    --device=/dev/tty35:/dev/tty0 \
    --device=/dev/tty36:/dev/tty1 \
    --device=/dev/input:/dev/input \
    ich777/debian-buster:nvidia-steam
```

### Webgui address: http://[SERVERIP]:[PORT]/vnc.html?autoconnect=true


This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/