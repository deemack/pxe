#!/bin/sh
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

printf "${GREEN}Update Linux and install${NC}\n"
sudo sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
sudo apt-get update && sudo apt-get upgrade -y

printf "${GREEN}Install packages${NC}\n"
printf "${YELLOW}pxelinux${NC}\n"
sudo apt-get install pxelinux -y

printf "${YELLOW}syslinux-efi${NC}\n"
sudo apt-get install syslinux-efi -y

printf "${YELLOW}dnsmasq${NC}\n"
sudo apt-get install  dnsmasq -y

printf "${GREEN}Modify dnsmasq.conf${NC}\n"
cat dnsmasq.conf | sudo tee -a /etc/dnsmasq.conf

printf "${GREEN}Create all required folders${NC}\n"
sudo mkdir -p /mnt/data/isos
sudo mkdir -p /mnt/data/netboot/bios
sudo mkdir -p /mnt/data/netboot/efi64
sudo mkdir -p /mnt/data/netboot/boot
sudo mkdir -p /mnt/data/netboot/pxelinux.cfg
sudo mkdir -p /mnt/data/netboot/boot/amd64/ubuntu_server/22.04
sudo mkdir -p /mnt/data/netboot/boot/amd64/ubuntu_desktop/22.04
sudo mkdir -p /mnt/data/netboot/boot/amd64/debian/12.1

printf "${GREEN}Download ISOs:${NC}\n"
cd /mnt/data/isos
printf "${YELLOW}Ubuntu Server${NC}\n"
sudo wget -N https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso
printf "${YELLOW}Ubuntu Desktop${NC}\n"
sudo wget -N https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-desktop-amd64.iso
printf "${YELLOW}Debian${NC}\n"
sudo wget -N https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.1.0-amd64-netinst.iso
cd ~/pxe

printf "${GREEN}Copy BIOS modules to netboot/bios folder${NC}\n"
sudo cp \
  /usr/lib/syslinux/modules/bios/{ldlinux,vesamenu,libcom32,libutil}.c32 \
  /usr/lib/PXELINUX/pxelinux.0 \
  /mnt/data/netboot/bios
printf "${GREEN}Copy EFI modules to netboot/efi64 folder${NC}\n"
sudo cp \
  /usr/lib/syslinux/modules/efi64/ldlinux.e64 \
  /usr/lib/syslinux/modules/efi64/{vesamenu,libcom32,libutil}.c32 \
  /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi \
  /mnt/data/netboot/efi64

printf "${GREEN}Mount ISO and copy to /media directories: Try Physical${NC}\n"
printf "${YELLOW}Ubuntu Server - Physical Machine${NC}\n"
sudo umount /media
sudo mount -o loop -t iso9660 /mnt/data/isos/ubuntu-22.04.3-live-server-amd64.iso /media
sudo rsync -av /media/ /mnt/data/netboot/boot/amd64/ubuntu_server/22.04
sudo umount /media

printf "${YELLOW}Ubuntu Desktop - Physical Machine${NC}\n"
sudo mount -o loop -t iso9660 /mnt/data/isos/ubuntu-22.04.3-desktop-amd64.iso /media
sudo rsync -av /media/ /mnt/data/netboot/boot/amd64/ubuntu_desktop/22.04
sudo umount /media

printf "${YELLOW}Debian - Physical Machine${NC}\n"
sudo mount -o loop -t iso9660 /mnt/data/isos/debian-12.1.0-amd64-netinst.iso /media
sudo rsync -av /media/ /mnt/data/netboot/boot/amd64/debian/12.1
sudo umount /media

printf "${GREEN}Mount ISO and copy to /media directories: Try Virtual${NC}\n"
printf "${YELLOW}Ubuntu Server - Virtual Machine${NC}\n"
isopath=$(sudo lsblk | grep Ubuntu-Server | cut -f2- -d/)
sudo rsync -av /"$isopath" /media
sudo umount /media

printf "${YELLOW}Ubuntu Desktop - Virtual Machine${NC}\n"
isopath=$(sudo lsblk | grep 'Ubuntu ' | cut -f2- -d/)
sudo rsync -av /"$isopath" /media
sudo umount /media

printf "${YELLOW}Debian - Virtual Machine${NC}\n"
isopath=$(sudo lsblk | grep Ubuntu-Server | cut -f2- -d/)
sudo rsync -av /"$isopath" /media
sudo umount /media

printf "${GREEN}Copy default pxelinux configuration file${NC}\n"
sudo cp ./default /mnt/data/netboot/pxelinux.cfg/default  

printf "${GREEN}Create symbolic links for pxelinux.cfg${NC}\n"
cd /mnt/data/netboot
sudo ln -rs pxelinux.cfg bios && sudo ln -rs pxelinux.cfg efi64

printf "${GREEN}Restart dnsmasq service${NC}\n"
sudo systemctl restart dnsmasq

printf "${GREEN}Start python webserver to serve ISOs${NC}\n"
python3 -m http.server 8111 -d /mnt/data/isos/ &
