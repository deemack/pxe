# pxe server - VM or physical server

Tested on Raspberry Pi
- Flash Pi OS to your raspberry pi
- Run the following commands
```
git clone https://github.com/deemack/pxe.git && cd pxe && sudo chmod +x setup_pxe_server.sh && bash setup_pxe_server.sh
```

Tested on Virtual Box VM running Ubuntu Desktop 22.04.3
- Install Ubuntu onto the VM with a hard disk space of at least 50G
- Mount the ISOs to the VM as CD-ROM devices via the VirtualBox GUI
- Controller: AHCI  
  - debian-12.1.0-amd64-netinst.iso
  - Ubuntu-Desktop.vdi
  - ubuntu-22.04.3-desktop-amd64.iso
  - ubuntu-22.04.3-live-server-amd64.iso
- Turn the VM on and log into it. This will auto-mount the ISOs
- Run the command **lsblk** to check if they are mounted.
````
sr0     11:0    1   627M  0 rom  /media/dave/Debian 12.1.0 amd64 n
sr1     11:1    1   4.7G  0 rom  /media/dave/Ubuntu 22.04.3 LTS amd64
sr2     11:2    1     2G  0 rom  /media/dave/Ubuntu-Server 22.04.3 LTS amd64
````
