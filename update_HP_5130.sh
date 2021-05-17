#!/bin/bash

#change this with latest release
new="HPE Comware Software, Version 7.1.070, Release 3506P06"

#addresses list of all switches
for i in `cat list.txt`
do
	ip=$(echo $i | cut -d'_' -f2)
	nom=$(echo $i | cut -d'_' -f1)
	echo $ip
	#change $pass by switch's root password 
	sshpass -p $pass ssh root@$ip 'display version' > version
	version=$(cat version | head -n 2 | tail -n 1 | sed 's/\s\+$//')
	if [[ $version != $new ]]
	then
		sshpass -p $pass ssh root@$ip 'dir' > dir
        cat dir | grep "5130EI-CMW710-R3506P06.ipe"
        if [ $? -eq 1 ]
        then
        	#change $tftp_addr by tftp server address ip
			sshpass -p $pass ssh root@$ip 'tftp $tftp_addr get 5130EI-CMW710-R3506P06.ipe' > /dev/null &
			if [ $? -eq 0 ]
			then
				echo "$nom downloading update"
			else
				echo "$nom didn't download the update"
			fi
		else
			echo "update already download"
		fi

	else
			echo "$nom already update"
	fi
done

sleep 1s

for i in `cat list.txt`
do
	ip=$(echo $i | cut -d'_' -f2)
        nom=$(echo $i | cut -d'_' -f1)
	echo $ip
	sshpass -p $pass ssh root@$ip 'display version' > version
        version=$(cat version | head -n 2 | tail -n 1 | sed 's/\s\+$//')
	echo $version
        if [[ $version != $new ]]
        then
              	sshpass -p $pass ssh root@$ip 'dir' > dir
       		cat dir | grep "5130EI-CMW710-R3506P06.ipe"
        	if [ $? -eq 0 ]
       	 	then
                	#change 
                	sshpass -p $pass ssh root@$tftp_addr 'tftp $tftp_addr put startup.cfg
boot-loader file flash:/5130EI-CMW710-R3506P06.ipe all main
sa sa fo
reboot'
			#change $ftp_addr, $ftp_user and $ftp_pass by ftp server ip address, username and password to log in
			sleep 5s
			ftp -n $ftp_addr << END_SCRIPT
quote USER $ftp_user
quote PASS $ftp_pass
rename startup.cfg startup$nom.cfg
quit
END_SCRIPT
			echo "$nom update is running" 
        	else
                	echo "update isn't running on $nom"
        	fi
	fi
done

sleep 5m
for i in `cat list.txt`
do
        ip=$(echo $i | cut -d'_' -f2)
        echo $ip
        sshpass -p $pass ssh root@$ip 'display version' > version
        version=$(cat version | head -n 2 | tail -n 1 | sed 's/\s\+$//')
        echo $version
        nom=$(echo $i | cut -d'_' -f1)
        if [[ $version != $new ]]
        then
		echo $nom" : not up to date"
	else
		echo $nom" : up to date"
	fi
done

echo "end"





