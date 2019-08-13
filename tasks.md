Q: Configure 0.uk.pool.ntp.org and 1.uk.pool.ntp.org as the only NTP servers.
A: ```chronyc sources``` to list current NTP servers, edit ```/etc/chrony.conf``` and specify new server, ```systemctl restart chronyd``` to enforce change.  

Q: Create a new logical volume called testvol1 (size 1GB) that belongs to the volume group VG01. Then mount persistently to /mnt/newdisk. You will probably need to add an extra VirtualBox disk before doing this.
A:```
fdisk -l /dev/sdb (to confirm that disk exists)
pvcreate /dev/sdb
vgcreate VG01 /dev/sdb1
lvcreate -n testvol1 -L 1G VG01
mkfs.xfs /dev/VG01/testvol01
mount /dev/VG01/testvol01 /mnt/newdisk
grep "testvol" /etc/mtab >> /etc/fstab
```

Q: LDAP stuff
A:
yum groupinstall "Directory Client"
authconfig-tui
man need to remove nscd package to force authconfig-tui to update sssd instead of nscd. May need to put "ldap_tls_reqcert" in sssd.conf to stop cert errors (needed to do this for linuxacademy lab).

Q: SELinux
Move index.html to /var/website/ and set SELinux context.
A: Check SELinux context of existing /var/www/ directory ```ls -lZ /var/www```. It should be ```httpd_sys_content_t```, apply this context to /var/website using:
```semanage fcontext -a -t httpd_sys_content_t "/var/website"```
```restorecon /var/website``` to apply change
```ls -lZ /var/website``` to confim it's worked

Q: Start VM.
A: ```virsh list --all``` to show all VMs
```virsh start vmname``` to start VM
```virsh edit vmname``` to show information about VM
```yum install virt-manager``` to install GUI

Q: Add two new disks, one partitioned as mbr, the other gpt.
A: ```lsblk``` to see hard disks
```fdisk``` to format with mbr
```gpart``` to format with gpt gpt

Q: Create a logical volume, mount it, then extend.  
```pvcreate /dev/diskname``` to crete physical volume
```vgcreate VGNAME /dev/diskname``` to create volume group
```lvcreate -L 2GB -n LVOLNAME VGNAME``` to create logical volume as member of volume group
```mkfs.xfs /dev/VOLGROUP/VOLNAME``` format as xfs
```mount /dev/VOLGROUP/VOLNAME mnt/test1``` to mount
Add to /etc/fstab to make persistent
```lvextend -L 200MB VOLGROUP/VOLNAME -r``` to extend and resize
```xfs_growfs /mnt/test1``` to resize if you forgot the ```-r``` option with lvextend.
