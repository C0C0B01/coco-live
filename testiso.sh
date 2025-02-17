#!/bin/bash
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

src_dir=$(pwd)
[[ -r ${src_dir}/util-msg.sh ]] && source ${src_dir}/util-msg.sh
import ${src_dir}/util.sh

# setting of the general parameters
work_dir="${src_dir}/build"
outFolder="${src_dir}/out"

if [ $# -eq 0 ]; then
    msg "No <profile>"
    msg2 "Usage: testiso <profile>"
    exit 1
fi

vdi_size=10240 # 10GB size

#Check if already exist virtual disk and in case create it
if [[ -e ~/VirtualBox\ VMs/cocoLinux/cocoLinux.vbox ]]; then
    msg "coco Virtual Machine Found"
else
    msg "We create a new VirtualBox Machine called cocoLinux"
    msg2 "We create a new Virtual Disk Image ( vdi ) with ${vdi_size}GB"
    VBoxManage createmedium disk --filename ~/VirtualBox\ VMs/cocoLinux/cocoLinux.vdi --size ${vdi_size} --format VDI --variant Fixed

    UUID=$(VBoxManage showhdinfo ~/VirtualBox\ VMs/cocoLinux/cocoLinux.vdi | awk 'NR == 1  {print $2}') #uuid of vdi disk
    gui_lang=$(awk -F'[.=]' '/LANG/ {print $2}' /etc/locale.conf)

    echo '<?xml version="1.0"?>
<!--
** DO NOT EDIT THIS FILE.
** If you make changes to this file while any VirtualBox related application
** is running, your changes will be overwritten later, without taking effect.
** Use VBoxManage or the VirtualBox Manager GUI to make changes.
-->
<VirtualBox xmlns="http://www.virtualbox.org/" version="1.16-linux">
  <Machine uuid="{b146a487-eeff-48d1-a404-b1c15f077feb}" name="cocoLinux" OSType="ArchLinux_64" snapshotFolder="Snapshots" lastStateChange="2022-07-11T14:59:41Z">
    <MediaRegistry>
      <HardDisks>
        <HardDisk uuid="{UUID}" location="cocoLinux.vdi" format="VDI" type="Normal"/>
      </HardDisks>
    </MediaRegistry>
    <Hardware>
      <CPU count="4">
        <PAE enabled="false"/>
        <LongMode enabled="true"/>
        <X2APIC enabled="true"/>
        <HardwareVirtExLargePages enabled="false"/>
      </CPU>
      <Memory RAMSize="7168"/>
      <Firmware type="EFI"/>
      <HID Pointing="USBTablet"/>
      <Display VRAMSize="16" accelerate3D="true"/>
      <VideoCapture file="." fps="25"/>
      <BIOS>
        <IOAPIC enabled="true"/>
        <SmbiosUuidLittleEndian enabled="true"/>
      </BIOS>
      <USB>
        <Controllers>
          <Controller name="OHCI" type="OHCI"/>
        </Controllers>
      </USB>
      <Network>
        <Adapter slot="0" enabled="true" MACAddress="080027967634" type="82540EM">
          <NAT/>
        </Adapter>
      </Network>
      <AudioAdapter codec="AD1980" driver="Pulse" enabled="true" enabledIn="false"/>
      <RTC localOrUTC="UTC"/>
      <GuestProperties>
        <GuestProperty name="/VirtualBox/HostInfo/GUI/LanguageID" value="gui_lang" timestamp="1566055357633717000" flags=""/>
      </GuestProperties>
    </Hardware>
    <StorageControllers>
      <StorageController name="IDE" type="PIIX4" PortCount="2" useHostIOCache="true" Bootable="true">
        <AttachedDevice passthrough="false" type="DVD" hotpluggable="false" port="1" device="0"/>
      </StorageController>
      <StorageController name="SATA" type="AHCI" PortCount="1" useHostIOCache="false" Bootable="true" IDE0MasterEmulationPort="0" IDE0SlaveEmulationPort="1" IDE1MasterEmulationPort="2" IDE1SlaveEmulationPort="3">
        <AttachedDevice type="HardDisk" hotpluggable="false" port="0" device="0">
          <Image uuid="{UUID}"/>
        </AttachedDevice>
      </StorageController>
    </StorageControllers>
  </Machine>
</VirtualBox>' > ~/VirtualBox\ VMs/cocoLinux/cocoLinux.vbox

    sed -i "s/UUID/$UUID/g" ~/VirtualBox\ VMs/cocoLinux/cocoLinux.vbox
    sed -i "s/gui_lang/$gui_lang/g" ~/cocoLinux\ VMs/cocoLinux/cocoLinux.vbox

    VBoxManage registervm ~/VirtualBox\ VMs/cocolinux/cocoLinux.vbox #register the cachyos vbox machine
fi


VBoxManage storageattach cocoLinux --storagectl IDE --port 1 --device 0 --medium emptydrive #empty the dvd drive
sleep 1

iso_dir=$(find ${outFolder} -type d -iname "$1")

iso=${iso_dir}

if [[ -e $(ls ${iso}/*.iso) ]]; then
  iso_name=$(ls ${iso}/*.iso)
else msg "No ISO to load present"
     exit 1
fi

VBoxManage storageattach cocoLinux --storagectl IDE --port 1 --device 0  --type dvddrive --medium $iso_name #attach dvd cachyos iso

sleep 1

msg2 "Run Vbox cocoLinux with ${iso_name}"

sleep 2

VBoxManage startvm cocoLinux #run vbox machine

