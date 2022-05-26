#!/bin/bash

### BEGIN

# Display "The architecture of your operating system and its kernel version."

UNAME=$(uname -snrvmo)
printf "#Architecture    : ${UNAME}\n"

# Display "The number of physical processors."

CPUINFO_QTY_PHYSICAL_PROCESSORS=$(cat /proc/cpuinfo | grep 'physical id' | uniq | wc -l)
printf "#CPU physical    : ${CPUINFO_QTY_PHYSICAL_PROCESSORS}\n"

# Display "The number of virtual processors."

CPUINFO_QTY_VIRTUAL_PROCESSORS=$(cat /proc/cpuinfo | grep 'processor' | uniq | wc -l)
printf "#vCPU            : ${CPUINFO_QTY_VIRTUAL_PROCESSORS}\n"

# Display "The current available RAM on your server and its utilization rate as a percetage."

MEMINFO_AVAILABLE=$(free -m | grep 'Mem.' | awk '{print $2}')
MEMINFO_USEDMEMOR=$(free -m | grep 'Mem.' | awk '{print $3}')
MEMINFO_UTILIRATE=$(free -m | grep 'Mem.' | awk '{printf("%.2f"), ($3/$2) * 100}')
printf "#Memory Usage    : ${MEMINFO_USEDMEMOR} / ${MEMINFO_AVAILABLE} MB (${MEMINFO_UTILIRATE} %%)\n"

# Display "The current available memory on your server and its utilization rate as a percentage."

DISKINFO_AVAILABLE=$(df -Bg | grep '/dev' | awk '{avai += $2} END {print avai}')
DISKINFO_USEDMEMOR=$(df -Bm | grep '/dev' | awk '{used += $3} END {print used}')
DISKINFO_UTILIRATE=$(df -Bm | grep '/dev' | awk '{used += $3} {avai += $2} END {printf("%.2f"), (used/avai) * 100}')
printf "#Disk Usage      : ${DISKINFO_USEDMEMOR} / ${DISKINFO_AVAILABLE} Gb (${DISKINFO_UTILIRATE} %%)\n"

# Display "The current utilization rate of your processors as a percentage."
#"top -bn1" generates: %Cpu(s):  0,0 us,  3,3 sy,  0,0 ni, 96,7 id,  0,0 wa,  0,0 hi,  0,0 si,  0,0 st
#considered user usage = us[$2] + ni[$6]
#considered system usage = sy[$4] + hi[$12] + si[$14]
#considered "not" usage = id, wa

#CPUINFO_PERCENTAGE_USAGE=$(top -bn1 | grep '%Cpu' | awk '{printf("%.2f"), $2 + $6 + $4 + $12 + $14}')
CPUINFO_PERCENTAGE_USAGE=$(top -bn1 | awk 'NR > 7 {cpu += $9} END {printf("%.0f"), cpu}')
printf "#CPU Load        : ${CPUINFO_PERCENTAGE_USAGE} %%\n"

# Display "The date and time of the last reboot."

REBOOT_LAST_TIME=$(who -b | awk '{printf("%s %s"), $4, $5}')
printf "#Last boot       : ${REBOOT_LAST_TIME}\n"

# Display "Wheter LVM is active or not."

#LVMINFO=$(if [ $(lvs | wc -l) -gt 1 ]; then echo 'yes'; else echo 'no'; fi)

LVMINFO=$(if [ $(lsblk | grep 'lvm' | wc -l) -gt 0 ]; then echo 'yes'; else echo 'no'; fi)

printf "#LVM use         : ${LVMINFO}\n"

# Display "The number of active connections."

TCPINFO_ESTAB_CONN_QTY=$(ss -to state established | wc -l)
TCPINFO_ESTAB_CONN=$(if [ $((TCPINFO_ESTAB_CONN_QTY -1)) -gt 0 ]; then echo $((TCPINFO_ESTAB_CONN_QTY - 1)); else echo 'NONE'; fi)

printf "#Connections TCP : ${TCPINFO_ESTAB_CONN} ESTABLISHED\n"

# Display "The number of users using the server."

USERINFO_LOGGED=$(users | wc -w)

printf "#User log        : ${USERINFO_LOGGED}\n"

# Display "The IPv4 address of your server and its MAC (Media Access Control address."

IPV4INFO=$(hostname -I | awk '{print $1}')
MACINFO=$(ip link | grep 'link/ether' | awk '{print $2}')

printf "#Network         : IP ${IPV4INFO} (${MACINFO})\n"

# Display "The number of commands executed with the sudo program."

SUDOINFO_COMMANDS_QTY=$(journalctl | grep 'sudo' | grep 'COMMAND' | wc -l)

printf "#Sudo            : ${SUDOINFO_COMMANDS_QTY} cmd\n"

### END
