#!/bin/bash

# Usage:
#  $ "./win8.sh" --default
#  $ "./win8.sh" --path="$HOME/VirtualBox VMs" --name="win8" --disk="32768" --cpu="2" --ram="2048" --vram="128" --share="$HOME/share"

for i in "$@"
do
case $i in
    -p=*|--path=*)
        Machine_Folder="${i#*=}"
        shift
        ;;
    -n=*|--name=*)
        Machine_name="${i#*=}"
        shift
        ;;
    -d=*|--disk=*)
        HardDisk_size="${i#*=}"
        shift
        ;;
    -c=*|--cpu=*)
        CPU_count="${i#*=}"
        shift
        ;;
    -r=*|--ram=*)
        Memory_RAMSize="${i#*=}"
        shift
        ;;
    -v=*|--vram=*)
        Display_VRAMSize="${i#*=}"
        shift
        ;;
    -s=*|--share=*)
        SharedFolder_hostPath="${i#*=}"
        shift
        ;;
    --default)
        Machine_Folder="$HOME/VirtualBox VMs"
        Machine_name="win8"
        HardDisk_size=32768
        CPU_count=2
        Memory_RAMSize=2048
        Display_VRAMSize=128
        SharedFolder_hostPath="$HOME/share"
        shift
        ;;
esac
done

Default_Machine_Folder=$(VBoxManage list systemproperties | sed -n 's/Default machine folder: *//p')

VBoxManage setproperty machinefolder "$Machine_Folder"

mkdir -p "$Machine_Folder/$Machine_name"
cd "$Machine_Folder/$Machine_name"

VBoxManage createvm --name "$Machine_name" --ostype "Windows81_64" --register

HardDisk_location="$Machine_name.vdi"
VBoxManage createhd --filename "$HardDisk_location" --size $HardDisk_size

VBoxManage modifyvm "$Machine_name" \
    --audiocontroller hda \
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
    --pae on \
    --usb off \
    --usbxhci on \
    --vram $Display_VRAMSize

VBoxManage storagectl "$Machine_name" --name "SATA" --add sata --controller IntelAHCI --portcount 2
VBoxManage storageattach "$Machine_name" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$HardDisk_location"
VBoxManage storageattach "$Machine_name" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "emptydrive"

VBoxManage sharedfolder add "$Machine_name" --name share --hostpath "$SharedFolder_hostPath" --automount

VBoxManage setextradata "$Machine_name" "GUI/FirstRun" yes

VBoxManage setproperty machinefolder "$Default_Machine_Folder"

