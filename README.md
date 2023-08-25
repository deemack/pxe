# pxe
Pi PXE Server
- Flash Pi OS to your raspberry pi
- Run the following commands
```
sudo apt-get update && sudo apt-get install dnsmasq pxelinux syslinux-efi
mkdir /mnt/data/isos
cd /mnt/data/isos
sudo wget https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso
cd ~
sudo mkdir /mnt/data/netboot
sudo mkdir /mnt/data/netboot/bios
sudo mkdir /mnt/data/netboot/efi64
sudo mkdir /mnt/data/netboot/boot
sudo mkdir /mnt/data/netboot/boot/amd64/ubuntu
sudo mkdir /mnt/data/netboot/boot/amd64/ubuntu/22.04
sudo mkdir /mnt/data/netboot/pxelinux.cfg
sudo cp \
  /usr/lib/syslinux/modules/bios/{ldlinux,vesamenu,libcom32,libutil}.c32 \
  /usr/lib/PXELINUX/pxelinux.0 \
  /mnt/data/netboot/bios
sudo cp \
  /usr/lib/syslinux/modules/efi64/ldlinux.e64 \
  /usr/lib/syslinux/modules/efi64/{vesamenu,libcom32,libutil}.c32 \
  /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi \
  /mnt/data/netboot/efi64
sudo mkdir -p /mnt/data/netboot/boot/amd64/ubuntu/22.04
sudo mount -o loop -t iso9660 /mnt/data/isos/ubuntu-22.04.3-live-server-amd64.iso /media
sudo rsync -av /media/ /mnt/data/netboot/boot/amd64/ubuntu/22.04
sudo umount /media
