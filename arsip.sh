#!/bin/bash

# INSTALL tar,rar,unrar,zip,unzip,p7zip sebelum menggunakan

l=0;
a=0;
e=0;

list(){
case $1 in
	1)tar -tvf $2;; #tar
	2)unzip -l $2;; #zip
	3)unrar l $2;; #rar
	4)7z l $2;;#7zip
esac
}

arsip(){
case $1 in
	1)tar -cvf $2 $3;; #tar
	2)tar -cvzf $2 $3;; #tar.gz
	3)tar -cvjf $2 $3;; #tar.bz2
	4)zip -r $2 $3;; #zip
	5)rar a $2 $3;; #rar
	6)7z a $2 $3;;#7zip
esac
}

ekstrak(){
case $1 in
	1)tar -xvf $2;; #tar
	2)unzip $2;; #zip
	3)rar x $2;; #rar
	4)7z x $2;; #7zip
esac
}

while getopts ":lae" opt
do
	case $opt in
		l) l=1;;
		a) a=1;;
		e) e=1;;
	esac
done
shift $((OPTIND-1));

if [ $l -eq 1 ]
then
	if [ -f $1  ]
	then
		if [ "${1: -4}" == ".tar" ] || [ "${1: -8}" == ".tar.bz2" ] || [ "${1: -7}" == ".tar.gz" ]
			then 
				list 1 $1
			elif [ "${1: -4}" == ".zip" ]
			then
				list 2 $1
			elif [ "${1: -4}" == ".rar" ]
			then
				list 3 $1
			elif [ "${1: -5}" == ".7zip" ]
			then
				list 4 $1
			else
				echo "file $1 tidak support"
		fi
	else
		echo "file tidak di temukan"
	fi
elif [ $a -eq 1 ]
then
	if [ -d $3 ] || [ -f $3 ]
	then
		if [ "${1: -4}" == ".tar" ]
		then
			arsip 1 $1 $2
		elif [ "${1: -7}" == ".tar.gz" ]
		then
			arsip 2 $1 $2
		elif [ "${1: -8}" == ".tar.bz2" ] 
		then
			arsip 3 $1 $2
		elif [ "${1: -4}" == ".zip" ]
		then
			arsip 4 $1 $2
		elif [ "${1: -4}" == ".rar" ]
		then
			arsip 5 $1 $2
		elif [ "${1: -5}" == ".7zip" ]
		then
			arsip 6 $1 $2
		else
			echo "format $1 tidak support."
		fi
	
	else
		echo "file/directory $3 tidak di temukan"	
	fi
elif [ $e -eq 1 ]
then
	if [ -f $1 ]
	then
		if [ "${1: -4}" == ".tar" ] || [ "${1: -8}" == ".tar.bz2" ] || [ "${1: -7}" == ".tar.gz" ]
			then 
				ekstrak 1 $1
			elif [ "${1: -4}" == ".zip" ]
			then
				ekstrak 2 $1
			elif [ "${1: -4}" == ".rar" ]
			then
				ekstrak 3 $1
			elif [ "${1: -5}" == ".7zip" ]
			then
				ekstrak 4 $1
			else 
				echo "file $1 tidak support "
		fi
	else
		echo "file $1 tidak di temukan"
	fi
else
	echo "---------------------"
	echo "##==ASISTEN ARSIP==##"
	echo "---------------------"
	echo "support format : tar, tar.gz, tar.bz2, zip, rar, 7zip"
	echo "-l : list ( arsip -l file_arsip )"
	echo "-a : buat arsip ( arsip -a file_arsip sumber )"
	echo "-e : extract berkas ( arsip -e file_arsip )"
	
fi
