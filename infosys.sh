#!/bin/bash
MSEL="";
INPT="";
SROOT=0;
G='\033[0;37m'
H='\033[1;32m'
R='\033[1;31m' 
NC='\033[0m' 
Menu(){
# -t : untuk title
# -m : untuk manual
local OPTIND 
local mnl=0
local slct

	while getopts ":t:m:" opt
	do
		case $opt in
		t) echo -e "\n[== $OPTARG ==]";;
		m) mnl=1
		slct=$OPTARG;; 
		esac
    done
	shift $((OPTIND -1))
	
local arg=("$@")
local carg=${#arg[@]} 
	
	for ((i=0;i<$carg;i++))
	do 	
		echo -e "$(expr $i + 1)) ${arg[$i]}"
	done
	
	if [ $mnl -eq 1 ]
       	then
		echo "$(expr $i + 1)) $slct"
	fi
	
	read -p "select : " MSEL
}
InputManul(){
	echo -e "\n[ $1 ]"
	read -p "Input : " $2
#InputManul "judul input" namavariable
#hasil akan di tampung di variable,sebaiknya variable penampung nya global
}
ErrorSalact(){
	echo -e "$R\nwrong select....\n$NC"
}
SelectLine(){
	echo "$1" | sed -n $2'p'
#SelectLine $list pilihbaris
#memilih baris dari list
}
CheckRoot(){
if [ $EUID -eq 0 ]
	then
		SROOT=1
	else
		SROOT=0
fi
}
SpcCore(){
case $1 in
	1)echo -e [$H cpu $NC]
	 lscpu | grep -e "Model name" -e "Arch" -e "Order" -e "^CPU(s):";;
	2)echo -e [$H ram $NC]
	 lsmem | tail -2 | head -1;;
	3)echo -e [$H vga $NC]
	 lspci | grep VGA;;
	4)echo -e [$H resolusi $NC]
	 xrandr | head -1;;
	5)echo -e [$H swap $NC]
	 free -h;;
 	6)echo -e [$H listdrive $NC]
	 lsblk | tail +2;;
	7)echo -e [$H Detail OS $NC]
	 lsb_release -a
	 uname -a
	 ;;
	8)echo -e [$H list usb $NC]
	 lsusb;;
esac
}

PrcCore(){
case $1 in
	1)#all
	 ps -e;;
	2)#mencari nama  berdasarkan pid 
	 ps aux | awk '{if($2 == 2341)print $0}';;
	3)#mencari pid berdasarkan nama
	 pgrep -i $2;;
esac
}

SrvcCore(){
case $1 in 
	1)#list service
	 systemctl --all --full;;
	2)#cari status
	 systemctl status $2;;
	3)#failed service 
	 systemctl --failed;;
esac
}

NtCore(){
case $1 in 
	1)#ipv4
	 ip -4 addr;;
	2)#route
	 ip route;;
	3)#arp 
	 ip n show;;
	4)#listen port format angka
	 netstat -tln;;
	5)#listen port format nama
	 netstat -tl;;
esac
}

LgCore(){
case $1 in
	1)uptime -p ; uptime -s;; #uptime
	2)sudo cat /var/log/messages;; # system message
	3)sudo cat /var/log/auth.log;; # even authentication
	4)sudo cat /var/log/boot.log;; # catatan ketika boot
	5)sudo cat /var/log/kern.log;; # kernel troubleshooting
	6)sudo cat /var/log/apt/term.log;; # terminal apt log
	7)sudo cat /var/log/apt/history.log;; # history apt 
esac
}

DrvrCore(){
	lsmod | sort
}

SpcTbl(){
	echo -e "\n***[$H SPEC $NC]***"
	Menu -t "Select Info" Cpu Ram Vga Resolusi Swap Drive "Detail OS" Usb All 
	
	if [ $MSEL -lt 9 ] 
       	then
		SpcCore $MSEL
	elif [ $MSEL -eq 9 ]
	then
		for ((i=0;i<9;i++))
		do
			SpcCore $i
		done
	else
		ErrorSalact
	fi
}

PrcTbl(){
	echo -e "\n***[$H PROC $NC]***"
	Menu -t "Select info" "Show All" "Get Name by PID" "Get PID by Name"
	case $MSEL in
		1)PrcCore 1;;
		2)InputManul "Ex: 1234" INPT
		  PrcCore 2 $INPT;;
		3)InputManul "Ex: firefox" INPT
		  PrcCore 3 $INPT;;
		*)ErrorSalact;;
	esac
}
SrvTbl(){
	echo -e "\n***[$H SERVICE $NC]***"
	Menu -t "Select Info" All Status Failed
	case $MSEL in
		1)SrvcCore 1;;
		2)InputManul "Ex: apache2" INPT
		  SrvcCore 2 $INPT;;
		3)SrvcCore 3;;
		*)ErrorSalact;;
	esac
}
NtTbl(){
	echo -e "\n***[$H NET $NC]***"
	Menu -t "Select Info" Ip Route Arp "Listen port" "Get Name by Port"
	case $MSEL in
		1)echo -e "\n$H Ip $NC"
		  NtCore 1;;
		2)echo -e "\n$H Route $NC"
		  NtCore 2;;
		3)echo -e "\n$H Arp $NC"
		  NtCore 3;;
		4)echo -e "\n$H Listen $NC"
		  NtCore 4;;
		5)InputManul "Ex. 80" INPT
		  echo -e "\n$H AppName $NC"
		  for var in $(NtCore 4 | grep -n $INPT | cut -d : -f1)
		 do
			SelectLine "$(NtCore 5)" $var
		 done
		  ;;
		*)ErrorSalact;;
	esac
}
LgTbl(){
	echo -e "\n***[$H LOG $NC]***"
	Menu -t "Select Info" Uptime "System Message [$R ROOT Require $NC]" "Even Authentication [$R ROOT Require $NC]" "Bot Log [$R ROOT Require $NC]" "Kernel Log [$R ROOT Require $NC]" "Apt Log Terminal [$R ROOT Require $NC]" "Apt Log History [$R ROOT Require $NC]"
	case $MSEL in
		1)echo -e "\n$H Uptime $NC"
		  LgCore 1;;
		2)CheckRoot
		  if [ $SROOT -eq 1 ]
		  then
		  	echo -e "\n$H System Message $NC"
		  	LgCore 2
	  	  else
			echo -e "\nYou are$R NOT ROOT $NC"
		  fi
		  ;;
	 	 3) echo -e "\n$H Even Authentication $NC"
		  	LgCore 3;;
		4)CheckRoot
		  if [ $SROOT -eq 1 ]
		  then
			echo -e "\n$H Bot Log $NC"
		  	LgCore 4
	  	  else
			echo -e "\nYou are$R NOT ROOT $NC"
		  fi
		  ;;
		5)CheckRoot
		  if [ $SROOT -eq 1 ]
		  then
			echo -e "\n$H Kernel Log $NC"
		  	LgCore 5
	  	  else
			echo -e "\nYou are$R NOT ROOT $NC"
		  fi
		  ;;
		6)CheckRoot
		  if [ $SROOT -eq 1 ]
		  then
			echo -e "\n$H Apt Log Terminal $NC"
		  	LgCore 6
	  	  else
			echo -e "\nYou are$R NOT ROOT $NC"
		  fi
		  ;;
		7)CheckRoot
		  if [ $SROOT -eq 1 ]
		  then
		  	echo -e "\n$H Apt Log History $NC"
		  	LgCore 7
	  	  else
			echo -e "\nYou are$R NOT ROOT $NC"
		  fi
		  ;;
		*)ErrorSalact;;
	esac
	
}
Menu -t "Main Menu" specification process service network driver log
case $MSEL in 
	1)SpcTbl;;
	2)PrcTbl;;
	3)SrvTbl;;
	4)NtTbl;;
	5)DrvrCore;;
	6)LgTbl;;
	*)ErrorSalact;;
esac
