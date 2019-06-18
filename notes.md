# rhcsa-notes
My notes from the Linux Academy RHCSA course

## Objective 1: Understand and Use Essential Tools

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
