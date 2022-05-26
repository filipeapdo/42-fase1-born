# CentOS

"The CentOS Linux distribution is a stable, predictable, manageable and reproducible platform derived from the sources of Red Hat Enterprise Linux (RHEL)." (https://www.centos.org/)

When this project (born2beroot) were developed, there was two variants on official CentOS website (https://www.centos.org/):

- CentOS Linux : "Consistent, manageable platform that suits a wide variety of deployments. For some open source communities, it is a solid, predictable base to build upon."

- CentOS Stream : "Continuously delivered distro that tracks just ahead of Red Hat Enterprise Linux (RHEL) development, positioned as a midstream between Fedora Linux and RHEL. For anyone interested in participating and collaborating in the RHEL ecosystem, CentOS Stream is your reliable platform for innovation."

As the project subject asked the "latest stable version" I've chosen the "CentOS Linux" on it's version 7 due to version 8 "became" the "CentOS Stream" and reach the EOL (end of life) in 31/12/2021: https://blog.centos.org/2020/12/future-is-centos-stream/. The version 7 will me mantained 'till 30/06/2024.

---

## 01 - Installation

### step 01

![installation_01](images/b2br_01_installation_01.png "installation step 01")

### step 02

![installation_02](images/b2br_01_installation_02.png "installation step 02")

...

---

## 02 - Boot

### step 01

![boot_01](images/b2br_02_boot_01.png "boot step 01")

### step 02

![boot_02](images/b2br_02_boot_02.png "boot step 02")

---

## 03 - Network Config

### step 01: Checking the network configuration:

1. `ip addrress` or `ip a` will show the basic network configuration;
2. `inet ...` line will show the *ip address* (192.168.15.3), the *network mask* (/24) and other general config from the network adapter (enp0s3);
3. `... dynamic ...` in the same line, indicates that the address attribution is been done dynamically through the dhcp server.

![netconf_01](images/b2br_03_netconf_01.png "netconf step 01")

### step 02: Changing the network configuration:

It's a good practice to attribute a static address to the network adapter on servers.
The network configuration will be done by changing the adapter config file, it's also possible to change it through the NetworkManager.

1. `cd /etc/sysconfig/network-scrypts/` to change into network scripts file;
2. `ls -l | grep cfg` will list all config scripts;
3. `vi ifcfg-enp0s3` to edit the script;
4. This is the script generated from the installation process.

![netconf_02-1](images/b2br_03_netconf_02-1.png "netconf step 02-1")

5. `BOOTPROTO="static"` defines the address as static of the adapter (enp0s3);
6. `IPADRR=<ip-address>` defines the ip address of the adapter (enp0s3);
7. `NETMASK=<netmask>` defines the network mask of the adapter (enp0s3);
8. `GATEWAY=<gateway-ip>` defines the gateway of the adapter (enp0s3);
9. `DNS1=<dns-ip>` defines the prefered DNS address of the adapter (enp0s3);
10. `NM_CONTROLLED=no` tells the network service explicit to do not use the NetworkManager;
11. `ONBOOT=yes` brings up the interface on boot.

![netconf_02-2](images/b2br_03_netconf_02-2.png "netconf step 02-1")

### step 03: Checking the reachness of the server:

1. `ping -c 3 google.com` to check if the server reaches the internet;
2. `ping -c 3 192.168.15.1` to check if the server reaches the local network gateway;
3. from the local computer, `ping -c 3 192.168.15.31` to check if a local computer reaches the server.

![netconf_03](images/b2br_03_netconf_03.png "netconf step 03")

From this point, I've decided to use the local computer to access the server through a ssh tunnel and do the rest of the configuration. The detailed configuration of the ssh will be shown on section xxx

---

## 04 - Package Manager

### step 01

"CentOS uses prebuilt packages for the installation of programs. The package format used by CentOS is rpm, the RedHat Package Manager. RPM is the container for software packages, installation of packages on CentOS normally is done with `yum`, which can automatically calculate and resolve dependencies for a package which is going to be installed. The dependencies are then pulled in also." (https://wiki.centos.org/PackageManagement).

Dispite the newer versions of CentOS uses dnf, I've decided to use yum, as the official wiki recomends - or, at least says, "normally is done with `yum`".

"Yum is an automatic updater and package installer/remover for rpm systems. It automatically computes dependencies and figures out what things should occur to install packages. It makes it easier to maintain groups of machines without having to manually update each one using rpm. Yum has a plugin interface for adding simple features. Yum can also be used from other python programs via its module inteface." (http://yum.baseurl.org/).

Why use YUM (https://phoenixnap.com/kb/rpm-vs-yum).

1. `yum --help | less` or `man yum` to check the general usage;
2. `yum history` shows that the system was never changed (updated) since the installation;
3. `yum check-update` shows the packges that has a updated version available;
4. `yum update` will update all packges currently installed - ensuring all dependencies are satisfied;

![packmanager_01-1](images/b2br_04_packmanager_01-1.png "packmanager step 01-1")

5. shows the download progress.

![packmanager_01-2](images/b2br_04_packmanager_01-2.png "packmanager step 01-2")

6. checking the key: it's possible to cross check the key's fingerprint using the `gpg` tool > `gpg --with-fingerprint RPM-GPG-KEY-CentOS-7`

![packmanager_01-3](images/b2br_04_packmanager_01-3.png "packmanager step 01-3")

![packmanager_01-4](images/b2br_04_packmanager_01-4.png "packmanager step 01-4")

7. updating packages.

![packmanager_01-5](images/b2br_04_packmanager_01-5.png "packmanager step 01-5")

---

## 05 - SELinux

### step 01: About SELinux

"Security-Enhanced Linux (SELinux) is a security architecture for Linux® systems that allows administrators to have more control over who can access the system. It was originally developed by the United States National Security Agency (NSA) as a series of patches to the Linux kernel using Linux Security Modules (LSM).  

SELinux was released to the open source community in 2000, and was integrated into the upstream Linux kernel in 2003." (https://www.redhat.com/en/topics/linux/what-is-selinux)

"Discretionary access control (DAC) vs. mandatory access control (MAC)

Traditionally, Linux and UNIX systems have used DAC. SELinux is an example of a MAC system for Linux. 

With DAC, files and processes have owners. You can have the user own a file, a group own a file, or other, which can be anyone else. Users have the ability to change permissions on their own files.

The root user has full access control with a DAC system. If you have root access, then you can access any other user’s files or do whatever you want on the system. 

But on MAC systems like SELinux, there is administratively set policy around access. Even if the DAC settings on your home directory are changed, an SELinux policy in place to prevent another user or process from accessing the directory will keep the system safe. 

SELinux policies let you be specific and cover a large number of processes. You can make changes with SELinux to limit access between users, files, directories, and more." (https://www.redhat.com/en/topics/linux/what-is-selinux).

1. Changing to permissive mode, to do not have any trouble during the rest of the server setup
   1. `vi /etc/selinux/config`
   2. set `SELINUX=permissive`


![selinux_01](images/b2br_05_selinux_01.png "selinux step 01")

During the setup, couple of changes must be done into SELinux, so that we can "enforce" the control over the installed packages/tools.

---

## 06 - LVM

### step 01: Definition of LVM:

"Logical Volume Manager is a system of mapping and managing hard disk memory used on Linux-kernel's based systems. Instead of the old method of partitioning disks on a single filesystem, and having it be limited to only 4 partitions, LVM allows you to work with "Logical Volumes", a more dinamically and flexible way to deal with your hardware.

There are three major concepts you must understand to fully grasp the behaviour of LVM:

Volume Group: It is a named collection of physical and logical volumes. Typical systems only need one Volume Group to contain all of the physical and logical volumes on the system;
Physical Volumes: They correspond to disks; they are block devices that provide the space to store logical volumes;
Logical Volumes: They correspond to partitions: they hold a filesystem. Unlike partitions though, logical volumes get names rather than numbers, they can span across multiple disks, and do not have to be physically contiguous.
The idea sounds simple enough: You take a disk, declare it as a Physical Volume, then you take that volume and append it to the Volume Group of your choice (usually only one per computer). At last, you may "partition" that volume into small Logical Volumes that can correspond to 1 or multiple disks, and can be reallocated in memory even if they are already in use.

LVM is a great utility to have on servers and systems that demand usage stability and great necessity of quick management of the available physical devices (it makes it way easier to add or remove memory, for instance)." (https://github.com/caroldaniel/42sp-cursus-born2beroot/blob/master/guides/CentOS-en.md).

I've decided to create only 2 encrypted partitions on installation, and them, "expand" it afterwards.

![lvm_01](images/b2br_06_lvm_01.png "lvm step 01")

### step 02: Enabling unlock through ssh:

1. To unlock the encrypted lvm partition, I've installed the crypt-ssh dracut module. From man: "dracut creates an initial image used by the kernel for preloading the block device modules (such as IDE, SCSI or RAID) which are needed to access the root filesystem." (https://linux.die.net/man/8/dracut).
2. To install, I've follow this tutorial to the letter: https://github.com/dracut-crypt-ssh/dracut-crypt-ssh.
3. After install:
   1. `dracut --list-modules | grep crypt-ssh` to check if the module were installed
   2. `dracut -f -v` to rebuild the `initramfs`. "The contents of initramfs are loaded as the initial root file system by the kernel before the main root is loaded. The initial root contains the files that are required to mount the “real” root file system and initialize our system. The files mostly contain kernel modules." (https://www.baeldung.com/linux/initrd-vs-initramfs).
   3. `vi /etc/dracut.conf.d/crypt-ssh.conf` and changes the following lines
   ```sh
   8c8
   < dropbear_port="5222"
   ---
   > # dropbear_port="222"
   26,28d25
   < dropbear_rsa_key="/root/dracut-keys/ssh_dracut_rsa_key"
   < dropbear_ecdsa_key="/root/dracut-keys/ssh_dracut_ecdsa_key"
   < dropbear_ed25519_key="/root/dracut-keys/ssh_dracut_ed25519_key"
   37c34
   < dropbear_acl="/root/dracut-keys/authorized_keys"
   ---
   > # dropbear_acl="/root/.ssh/authorized_keys"
   ```
   4. `mkdir /root/dracut-keys` to create a folder to storage the ssh_keys
   5. `ssh-keygen -t rsa -m PEM -f /root/dracut-keys/ssh_dracut_rsa_key` to generate the `rsa` pair of keys
   6. `ssh-keygen -t ecdsa -m PEM -f /root/dracut-keys/ssh_dracut_ecdsa_key` to generate the `ecdsa` pair of keys
   7. `ssh-keygen -t ed25519 -m PEM -f /root/dracut-keys/ssh_dracut_ed25519_key` to generate the `ed25519` pair of keys
   8. `cat /root/dracut-keys/ssh_dracut_rsa_key.pub >> /root/dracut-keys/authorized_keys` to add the public `rsa` key on the authorized list
   9. `cat /root/dracut-keys/ssh_dracut_ecdsa_key.pub >> /root/dracut-keys/authorized_keys` to add the public `ecdsa` key on the authorized list
   10. `cat /root/dracut-keys/ssh_dracut_ed25519_key.pub >> /root/dracut-keys/authorized_keys` to add the public `ed25519` key on the authorized list
   11. from "local" computer `scp root@192.168.15.31:/root/dracut-keys/ssh_dracut_rsa_key ~/.ssh` to copy the `rsa` private key
   12. from "local" computer `scp root@192.168.15.31:/root/dracut-keys/ssh_dracut_ecdsa_key ~/.ssh` to copy the `ecdsa` private key
   13. from "local" computer `scp root@192.168.15.31:/root/dracut-keys/ssh_dracut_ed25519_key ~/.ssh` to copy the `ed25519` private key
   14. `vi /etc/default/grub` and changes the following line to enable the network configuration (rd.neednet=1 ip192.168.15.31::192.168.15.1:255.255.255.0::enp0s3:off) in the initial root file system
   ```sh
   6c6
   < GRUB_CMDLINE_LINUX="rd.neednet=1 ip=192.168.15.31::192.168.15.1:255.255.255.0::enp0s3:off rd.luks.uuid=luks-4f3689db-b121-4d26-a110-ec198094d02d rd.lvm.lv=lvm_group/root rd.lvm.lv=lvm_group/swap rhgb quiet"
   ---
   > GRUB_CMDLINE_LINUX="rd.luks.uuid=luks-4f3689db-b121-4d26-a110-ec198094d02d rd.lvm.lv=lvm_group/root rd.lvm.lv=lvm_group/swap rhgb quiet"
   ```
   15. `grub2-mkconfig --output /etc/grub2.cfg` to regenerate the grub config
   16. `dracut -f -v` to rebuild the `initramfs`. After the change on `/etc/dracut.conf.d/crypt-ssh.conf` config file and `/etc/default/grub` config file
   17. `reboot` ;)
4. To test/use after the configuration, from the local machine:
   1. `ssh -p 5222 -i ~/.ssh/ssh_dracut_ecdsa_key root@192.168.15.31` to open a ssh session over the initramfs. A shell will be presented
   2.  `console_peek` will show the same current state of the server
   
   ![lvm_02](images/b2br_06_lvm_02.png "lvm step 01")

   3. `console_auth` will allow the unlock (decrypt) the lvm partition
5. Done! Now, it's possible to unlock the crypt partition through ssh! Easy ahn?

### step 03: Changing the name of the "crypt" partition:

1. `lsblk` to check
2. `vi /etc/crypttab` and changes the "name" of the device name
```sh
1c1
< sda2_lvm_crypt UUID=4f3689db-b121-4d26-a110-ec198094d02d none
---
> luks-4f3689db-b121-4d26-a110-ec198094d02d UUID=4f3689db-b121-4d26-a110-ec198094d02d none
```
3. `vi /etc/default/grub` and changes the "name" of the device on boot control "grub"
```sh
6c6
< GRUB_CMDLINE_LINUX="rd.neednet=1 ip=192.168.15.31::192.168.15.1:255.255.255.0::enp0s3:off rd.luks.uuid=sda2_lvm_crypt rd.lvm.lv=lvm_group/root rd.lvm.lv=lvm_group/swap rhgb quiet"
---
> GRUB_CMDLINE_LINUX="rd.neednet=1 ip=192.168.15.31::192.168.15.1:255.255.255.0::enp0s3:off rd.luks.uuid=luks-4f3689db-b121-4d26-a110-ec198094d02d rd.lvm.lv=lvm_group/root rd.lvm.lv=lvm_group/swap rhgb quiet"
```
4. `dmsetup rename luks-4f3689db-b121-4d26-a110-ec198094d02d sda2_lvm_crypt` to rename it to a more "semantic" name
5. `grub2-mkconfig` to regenerate the grub config
6. `dracut -f -v` to rebuild the `initramfs`. After the change on `/etc/default/grub` config file
7. `reboot` ;)
8. `lsblk` to check the "renaming" operation result

### step 04: Resizing partitions and creating new logical volumes:

1. `yum install cloud-utils-growpart`
2. `growpart /dev/sda 2`
3. `reboot` ;)
4. `vgs && pvs && lvs` to check the current sizes and status of the lvm elements
5. `pv && pvresize /dev/mapper/sda2_lvm_crypt && pv` to resize the physical volume
6. `lvcreate -n home -L 5G lvm_group`
7. `lsblk -f` to check the creation and no file system associate to `home` volume
8. `mkfs.ext4 /dev/mapper/lvm_group-home` to format into ext4 format
9. `mount /dev/mapper/lvm_group-home /home` to mount the volume to `/home`
10. `vi /etc/fstab` and insert
```sh
10d9
< /dev/mapper/lvm_group-home /home                   ext4    defaults,x-systemd.device-timeout=0 1 1
```
11. `vgs && pvs && lvs` to check the current sizes and status of the lvm elements
12. `lvcreate -n var -L 3G lvm_group`
13. `lsblk -f` to check the creation and no file system associate to `var` volume
14. `mkfs.ext4 /dev/mapper/lvm_group-var`
15. `echo "/dev/mapper/lvm_group-home /home                   ext4    defaults,x-systemd.device-timeout=0 1 1" >> /etc/fstab`

(PRECISEI FAZER UMA COPIA DO DIRETORIO `/var` e depois de montado, sobrescrever o que diretorio do root `/`... talvez não faça sentido montar os diretorios "pós instalação") 

:(

---

## 07 - SSH Service

### step 01: About SSH Service

"Secure Socket Shell is a network protocol that gives users, particularly system administrators, a secure way to access a computer over an unsecured network. It provides users with a strong password authentication as well as a public key authentication. It attempts to safely communicate encrypted data over two computers using an open network." (https://github.com/caroldaniel/42sp-cursus-born2beroot/blob/master/guides/CentOS-en.md).

### step 02: SSH Configuration

1. `systemctl status sshd` will show the current status. It's important to check if the service is `enabled`, so that it starts on boot
2. `vi /etc/ssh/sshd_config` to perform the changes:
```sh
17c17
< Port 4242
---
> #Port 22
38c38
< PermitRootLogin no
---
> #PermitRootLogin yes
```
> in the sshd config file, there's a note about SELinux
> ```sh
> # If you want to change the port on a SELinux system, you have to tell
> # SELinux about this change.
> # semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
> ```

### step 03: SSH Configuration, SELinux

1. `yum install policycoreutils-python` to install semage
2. `yum install -y policycoreutils-python-utils`
3. `semanage por -l | grep ssh_port_t -p tcp 4242` to open the port on SELINUX
4. `semanage por -a -l ssh`
5. `yum install -y ufw` to install the "required" (by the project subject) firewall tool

### step 04: SSH Configuration, UFW

1. `ufw enable`
2. `ufw status vebose` to check status
3. `ufw delete 1` until delete all rules
4. `ufw allow 4242` to open the port
5. `service restart ufw`
6. `service enable ufw`

## 08 - Sudo and Password Policy

### step 01: Sudo

1. `man sudo`
2. `visudo`
```sh
88,119c88
< ### to be added on `Born2BeRoot 42 Project` configs
< # Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin
<
< #####################################################################################################
< ### Born2BeRoot 42 Project `strong configurations`
< ###
<
< ### Authentication using sudo has to be limited to 3 attempts in the event of an
< ### incorrect password:
<
< Defaults    passwd_tries=3
<
< ### A custom message of your choice has to be displayed if an error due to a wrong
< ### password occurs when using sudo:
<
< Defaults    badpass_message="Hummm... you miss it! Try again, young padawan!"
<
< ### Each action using sudo has to be archived, both inputs and outputs. The log file
< ### has to be saved in the /var/log/sudo/ folder:
<
< Defaults    logfile=/var/log/sudo/sudo_log
<
< ### The TTY mode has to be enabled for security reasons:
<
< Defaults    requiretty
<
< ### For security reasons too, the paths that can be used by sudo must be restricted:
<
< Defaults    secure_path=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
<
< ###
< #####################################################################################################
---
> Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin
```

### step 02: Password Policy

1. `vi /etc/login.defs`
```sh
25,32c25,27
<
< #####################################################################################################
< ### Born2BeRoot 42 Project `strong configurations`
< ###
<
< PASS_MAX_DAYS 30
< PASS_MIN_DAYS 2
< PASS_MIN_LEN  10
---
> PASS_MAX_DAYS 99999
> PASS_MIN_DAYS 0
> PASS_MIN_LEN  5
34,36d28
<
< ###
< #####################################################################################################
```
2. to apply the rules on existing users:
   1. `chage -M 30 root` == PASS_MAX_DAYS 30
   2. `chage -m 2 root` == PASS_MIN_DAYS 2
   3. `chage -W 7 root` == PASS_WARN_DAYS 7
3. `vi /etc/security/pwquality.conf`
```sh
6c6
< difok = 7
---
> # difok = 5
11c11
< minlen = 10
---
> # minlen = 9
15c15
< dcredit = -1
---
> # dcredit = 1
20c20
< ucredit = -1
---
> # ucredit = 1
38c38
< maxrepeat = 3
---
> # maxrepeat = 0
51,61d50
< #
< # Whether to check it it contains the user name in some form.
< # The check is disabled if the value is 0.
< usercheck = 1
< #
< # Prompt user at most N times before returning with error. The default is 1.
< retry = 3
< #
< # Enforces pwquality checks on the root user password.
< # Enabled if the option is present.
< enforce_for_root
```
4. to apply the rules on existing users:
   1. `passwd root`


## 08 - Users, Groups and Hostname

### step 01: Users

1. `awk -F: '{ print $1 }' /etc/passwd | less` to check all users
2. `useradd` to create a new user


## Passwords

1. sda5_crypt : Part5678**
2. root       : Ruthlangmore0987
3. fiaparec   : Martybyrde1234

Bonus WP configs
1. root@mariadb  : Wendybyrde5678
2. mariadb_user1 : admin
3. mariadb_pass1 : Adm1n
4. wp_dbname     : wp01
5. wp_admin_user : wp_admin
6. wp_admin_pass : 123


111Filipus