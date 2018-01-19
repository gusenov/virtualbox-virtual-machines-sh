#!/bin/bash

Machine_name="devel"
HardDisk_location="devel.vdi"
CPU_count=2
Memory_RAMSize=2048
Display_VRAMSize=128

mkdir -p "$HOME/VirtualBox VMs/$Machine_name"
cd "$HOME/VirtualBox VMs/$Machine_name"

VBoxManage createvm --name $Machine_name --ostype "Ubuntu_64" --register
VBoxManage createhd --filename $HardDisk_location --size 32768

VBoxManage modifyvm $Machine_name \
    --audiocodec ad1980 \
    --boot1 dvd \
    --boot2 disk \
    --boot3 none \
    --boot4 none \
    --clipboard bidirectional \
    --cpus $CPU_count \
    --hwvirtex on \
    --ioapic on \
    --memory $Memory_RAMSize \
    --mouse usbtablet \
    --nestedpaging on \
    --nic1 nat \
    --pae off \
    --rtcuseutc on \
    --usb on \
    --usbehci on \
    --vram $Display_VRAMSize

VBoxManage storagectl $Machine_name --name "SATA" --add sata --controller IntelAHCI
VBoxManage storageattach $Machine_name --storagectl "SATA" --port 0 --device 0 --type hdd --medium $HardDisk_location

VBoxManage storagectl $Machine_name --name "IDE" --add ide
VBoxManage storageattach $Machine_name --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "$HOME/Downloads/kubuntu-16.04.3-desktop-amd64.iso"

VBoxManage sharedfolder add $Machine_name --name share --hostpath $HOME/share --automount
