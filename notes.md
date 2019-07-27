# rhcsa-notes
My notes from the Linux Academy RHCSA course

## Understand and Use Essential Tools

### Output redirection
stderr only ```myscript.sh 2> errors```  
stdout only ```myscript.sh > out```  
stderr into stdout ```myscript.sh > out 2>&1```

### Grep with regular expressions
```^``` match expression at start of line  
```$``` match expression at end of line  
```\``` escape special character  
```[]``` match any of the enclosed characters, use hyphen for range, eg [1-5]  
```[^ ]``` match any character except the enclosed ones, eg [^lo] will match anything without 'lo'  
```.``` match single character except at end of file

#### Examples
```grep '^lin' examplefile.txt``` search file for lines that start with 'lin'  
```grep '$lin' examplefile.txt``` search for lines that end in 'lin'  
```grep '^$' examplefile.txt``` search for blank lines  
```grep -v -e '^ *#' -e '^$' httpd.conf``` outputs all lines that don't start with whitespace, # or blank lines. Useful for viewing config files.

### SSH
#### Common flags  
```-l``` specify login user  
```-i``` specify private key  
```-F``` specify ssh config file

#### Private keys
```ssh-keygen``` generates public/private key pair  
```ssh-copy-id``` copies public key to target server

### Logging in and switching users
Interactive shell vs login shell.  
.bash_profile is loaded for login shell only, .bashrc is loaded for interactive shell.  
```su -``` uses login shell and root user environment  
```su``` uses interactive shell and remains in the environment for the previous user.  
run single command with ```su -c```. For example, ```su -c "fdisk -l"```

### Compressing and decompressing files
#### Archive
```tar cvf archive.tar source```  
```tar xvf archive.tar```
#### Compress
```gzip testfile```  
```gzip -d testfile.gz``` or ```gunzip testfile.gz```
#### Archive and compress
```tar cvzf compressedarchive.tar.gz source```

### Creating and manipulating files
```ls -i``` shows inode of file

#### Find
``` find /etc -name httpd.conf```  

By type:  
files only ```find / -type f -name testfile.txt```
directories only ```find / -type d -name testdir```
symbolic links only ```find / -type l -name filename```

By user:  
find files owned by steve ```find /home/steve/files -user steve```

#### Locate
Faster than find command, uses a database.  
```locate httpd.conf```

### Linking files
File name just points to an inode on disk
#### Hard link
Points to the same inode, cannot cross filesystems, editing one of the linked files will edit the other, removing a hard link will not remove any data on disk because there is still one entry pointing at the inode.
```ln testfile testhardlink```
#### Soft link (symbolic link)
Can be thought of as a redirect, if the original file is deleted the soft link will still exist by point to nothing.
```ln -s testfile1 testsoftlink```

### File permissions
#### SUID and SGID
The 's' in the file permissions below means the SUID (set user id) has been configured, this means that the effective UID of that process will be the owner of the file (root in this example).  
```-rwsr-xr-x 1 root root 59640 Mar 22 19:05 /usr/bin/passwd```  
To set SUID ```chmod u+s filename```

The 's' in the file below means that the SGID has been set, so the effective group id of the process with be that of the group owner.  
```-rwxr-sr-x 1 root ssh 362640 Mar  4 12:17 /usr/bin/ssh-agent```  
To set SGID ```chmod g+s filename```

If the sticky bit is set, it means that anyone can write files to the directory, but only the file owner can delete files (even if permissions are 777).  
```drwxrwxrwt 20 root root 4096 Jun 18 11:30 /tmp/```  
To set sticky bit ```chmod +t directorypath```

#### Umask
Default permissions on a newly created files are 666 by default, setting the mask to 022 will change this to 644.  
Set umask ```umask 222```. This will change the permissions of newly created files to 444 (read only for user, group, other).  
Umask isn't persistent, it will revert back to 022 at next login. System wide config is stored in /etc/profile.

## Operate running systems
### Managing the boot process

#### Systemd boot targets
```rd.break``` breaks to interactive shell still in initrd, allows interaction with the filesystem before it is mounted (can be used for resetting root )  
```emergency``` similar to rd.break but mounts the system disk (root password is required)  
```rescue``` similar to emergency but starts some services (similar to old single user mode)

#### Resetting root password
Find ```linux16``` and add ```rd.break``` to the end of the line, then boot kernel
```mount -o rw,remount /systoot/``` mount sysroot as read/write  
```chroot /sysroot``` chroot to sysroot  
```passwd``` reset root password  
```touch /.autorelabel``` to force SELinux to relabel filesystem  
```exit``` exit chroot  
```mount -o ro,remount /sysroot/``` mount as read only  
```reboot``` reboot

### Managing individual processes
#### Tools
```top```
```ps```
```pgrep``` combination of ps and grep

#### Kill signals
```kill -l``` lists all kill signals  
```SIGTERM (15)``` asks process to exit cleanly  
```SIGKILL (9)``` stops process immediately    
```SIGHUP``` stops process in shell environment  
```SIGINT``` same as CTRL+C  
```SIGSTOP``` pause a processes  
```SIGCONT``` starts a process that was stopped with SIGSTOP or SIGTSTP  
```SIGTSTP``` terminal stop, similar to CTRL+z

#### Nice levels
-20(highest priority) to 19(lowest priority)  
```renice -n -20 pidnumber```

### Logging
```systemctl status rsyslog```  
config in /etc/rsyslog.conf  
logrotate config in /etc/logrotate.conf  

#### Journal examples
Journal is binary and can be difficult to interact with, but it's powerful. Some examples below:  
```journalctl -p err``` search for all errors  
```journalctl -p err -since yesterday``` all errors since yesterday  
```journalctl _UID=1000``` all errors associated with UID 1000  

### Virtual machines
```virsh list --all``` lists all vms (running and not running)  
```virsh edit vmname``` view/edit xml config for vm

### Service manipulation
```systemctl start servicename``` start service  
```systemctl stop servicename``` stop service
```systemctl enable servicename``` enable at boot  

### Transferring files
```scp```  
```sftp```

## Configure local storage
### LVM
1. ```pvcreate``` create physical volume. Example ```pvcreate volgroup```  
2. ```vgcreate``` create volume group. Example, ```vgcreate volgroup1 /dev/sdb1```  
3. ```lvcreate``` create logical volume. Example, ```lvcreate -L 100m volgroup1 -n dbvolume```  

```pvdisplay```, ```vgdisplay```, ```lvdisplay``` to view physical, logical and volume groups.  

After creating a logical volume, it can be mounted as normal.   
```mkfs.xfs /dev/volgroup1/dbvolume```   
```mkdir /mnt/db_data```  
```mount /dev/volgroup1/dbvolume /mnt/dbdata```  

```mount -a``` mounts all filesystems mentioned in fstab (good for testing that without reboot)  

```lvextend``` to extend logical volume. Example, ```lvextend -L +200MB /dev/volgroup1/dbvolume```  
Use lvextend with ```-r``` flag to resize the filesystem othwise will need to run ```xfs_growfs``` (for xfs) or ```resize2fs``` (for ext4).

### Manipulating partitions
MBR (master boot record), create/delete/edit with ```fdisk```  
GPT (GUID partition table). Supports UEFI, allows more than 4 partitions per disk, required for disks over 2TB. Create/delete/edit with ```gdisk```  
```partprobe``` informs kernel of partition table changes without rebooting

### Managing mounted disks
```xfs_admin```
```tune2fs```

## Create and configure file systems

### Network file systems
nfs, smb/cifs

### File permissions: ACLs
ACL files have a '+' in the file permissions, non-ACL files have a '.'
example ...
getfacl
setfacl
'-d' for directory
'-m' to modify
```getfacl file1 | setfacl --set-file=- file2``` copies ACL permissions from file1 to file2.

#### Setup a Samba share
```yum install samba```  
edit ```/etc/samba/smb.conf``` and create a new share.
```
[smbshare]
path = /smb
browsable = yes
writable = yes
```  
run ```testparm``` to check syntax of smb.conf file  
create an smb user.
```useradd smbuser```
```smbpasswd -a smbuser```
create the directory ```mkdir /smb```
start samba service ```systemctl start smb```
```smbstatus``` shows status  
on the client:
```yum install cifs-utils```
```mount -t cifs //ipofserver/sharename /mnt/smb -o username=smbuser,password=password```  

#### Setup a NFS share
```yum install nfs-utils -y```
```mkdir /nfs```
edit /etc/exports and add ```/nfs *(rw)```
```chmod 777 /nfs```
```exportfs -a``` to implement config in /etc/exportfs  
```systemctl start nfs```  
```showmount -e localhost```  
on client
```yum install nfs-utils -y```
```showmount -e ipofserver```-
```mkdir /mnt/nfs```
```mount -t nfs //ipofserver:/nfs /mnt/nfs```
## Deploy, configure and maintain systems
### Network configuration
```nmcli``` command line tool for controlling NetworkManager  
```bash-completion``` is handy for auto-completing nmcli commands  
```nmcli connection show``` shows network connections
```ip addr show``` similar to above

### Network time protocol
```chronyc tracking``` shows ntp status  
```chronyc sources``` shows ntp sources  
```/etc/chrony.conf```
restart chronyd for any changes made to chrony.conf to take affect ```systemctl restart chronyd```  
### Scheduling tasks
#### at
Install at ```yum install at```  
example:    
```
at now +1 minute  
reboot  
^d
```
```systemctl status atd``` verify at service is running  
```atq``` shows scheduled commands
#### cron
cron examples...

### Modifying the system bootloader
```yum list kernels```
```rpm -qa | grep kernel-[0-9]```
```grubby --info=ALL``` shows installed kernels and their index numbers
```grubby --default-index``` shows which kernel being used (default is 0)
```grubby --set-default-index 1``` sets grub to use kernel with index 1
```grub2-set-default 1` same as above
```uname -a``` kernel currently in use
### Updating and installing packages
####rpm
```rpm``` common flags
```i``` install  
```v``` verbose  SSH
```h``` shows progress info  
```U``` upgrade package  
```e``` erase/remove package  
####yum
```yum repolist``` shows configured repositories  
```yum install packagename.rpm``` will install rpm file and resolve dependencies  
```install``` ```remove``` ```search```  
```/etc/yum.repos.d/``` contains repositories  
```/etc/yum.conf``` yum configuration file  
### Using LDAP for authentication
install ldap client
use authconfig-gtk to configure
realmd can be used to join Active Directoy domain
```realm discover ad_servername```
```realm join ad_servername```
Install required packages:
```yum install nss-pam-ldapd pam_krb5 autofs nfs-utils openldap-clients```
Configure ldap client:
```
authconfig --enableldap --enableldapauth --enablemkhomedir --enableldaptls \
--ldaploadcacert=http://ldap.linuxacademy.com/pub/cert.pem --ldapserver=ldap.linuxacademy.com \
--ldapbasedn="dc=linuxacademy,dc=com" --update
```
## Manage users and groups
### Manipulating user accounts
```id```, ```getent``` gets information from /etc/passwd or /etc/shadow, ```/etc/passwd```, ```/etc/shadow```  
usermod common flags:  
```c``` modifies comment  
```d``` modifies home directory location  
```G``` changes supplimental group membership, ```-g``` for initial login group   
```L```, ```U``` lock/unlock account
### Password management and aging
```chage``` options:  
```l``` list  
```M``` minimum days a password is valid for  
```d``` days since password was set, 0 forces password reset  
```I``` days inactive before account is locked  
useradd default settings are here, ```/etc/default/useradd```  
default values for account parameters ```/etc/login.defs```
### Managing groups
```groupmod``` options:  
```g``` change group id  
```n``` change name of group  
```gpasswd -M user1,user2,user3 groupname``` add multiple users to a group
## Manage security
### Configuring the firewall
```firewall-cmd --add-service http``` adds http service to default (public) zone. Not persistent so will revert on reload/restart  
```firewall-cmd --permanent --add-service http``` adds persistent service  
```firewall-cmd --reload```  
```firewall-cmd --runtime-to-permanent``` makes running config persistent  
### SELinux
3 modes: enforcing, permissive, disabled  
```getenforce```  
```setenforce 1``` sets to enforcing mode (0 for permissive)  
```getsebool -a``` shows all booleans  
```setsebool boolname off/on``` use -P to make persistent  
```semanage fcontext -l``` lists all security contexts  
```ls -lZ``` shows security context of a file/directory  
```semanage fcontext -a -t httpd_sys_content_t /var/www/html``` sets context for html directoty  
```sealert -a /var/log/audit/audit.log``` helpful for troubleshooting  
```touch /.autorelabel``` forces context relabel on reboot  
