#!/bin/bash

trap 'echo Per sortir de programa has de posar el numero 7' SIGINT

function menu(){
	echo "--------------------"
        echo "| Escull opcio:    |"
        echo "--------------------"
        echo "| 1.lshw -short    |"
        echo "| 2.lscpu          |"
        echo "| 3.nmap           |"
        echo "| 4.netstat        |"
        echo "| 5.Serveis actius |"
        echo "| 6.free           |"
        echo "| 7.Sortir         |"
        echo "--------------------"
        read -p "" opcio
}


until ping -c 5 '192.168.1.1';
do
  echo "ERROR DE CONEXIO"
  sleep 5
done

sortir=0

while [ $sortir != 1  ]
do
	menu

	case $opcio in
		'1')
			ssh -T root@192.168.1.1 <<- EOF
			lshw -short>lshw.txt;
			cat lshw.txt
			scp lshw.txt david@192.168.1.10:/home/david/resultats.txt
			EOF
		;;
		'2')
			ssh -T root@192.168.1.1 <<- EOF
			lscpu>lscpu.txt
			cat lscpu.txt
			scp lscpu.txt david@192.168.1.10:/home/david/resultats.txt
			EOF
		;;
		'3')
			ssh -T root@192.168.1.1 <<- EOF
			apt install nmap
			nmap -all 192.168.1.1>nmap.txt
			cat nmap.txt
			scp nmap.txt david@192.168.1.10:/home/david/resultats.txt
			EOF
		;;
		'4')
			ssh -T root@192.168.1.1 <<- EOF
			apt install net-tools
			netstat>netstat.txt
			cat netstat.txt
			scp netstat.txt david@192.168.1.10:/home/david/resultats.txt
			EOF
		;;
		'5')
			ssh -T root@192.168.1.1 <<- EOF
			systemctl list-units --type service --all | grep running>services.txt
			cat services.txt
			scp services.txt david@192.168.1.10:/home/david/resultats.txt
			EOF
		;;
		'6')
                        ssh -T root@192.168.1.1 <<- EOF
                        free>free.txt
                        cat free.txt
                        scp free.txt david@192.168.1.10:/home/david/resultats.txt
			EOF
                ;;
		'7')
			sortir=1
		;;
	esac
	if [ $opcio != '7' ];then
		data=`date +%F`
		cat <<- FITXER > index.html
		<html>
			<head><title>Resultats</title></head>
			<body>
				<h1>Resultats:</h1>
				<h3>$data</h3>
				<pre>
		FITXER
		cat /home/david/resultats.txt >> index.html
		echo "</pre>" >> index.html
		echo "</body>" >> index.html
		echo "</html>" >> index.html
		firefox index.html
	fi
done
