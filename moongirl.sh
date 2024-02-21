#!/bin/bash

#Trampa de crl+C, cada cop que el usuari faci un crl+C el programa indicara que per sorti necesites introduir el numero 7. 
trap 'echo Per sortir de programa has de posar el numero 7' SIGINT

#Funció de menu
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

#Fins que no hi hagi conectivitat el codi mostrara error de conexió
until ping -c 5 '192.168.1.1';
do
  echo "ERROR DE CONEXIO"
  sleep 5
done

#variable per sortir del bucle
sortir=0


while [ $sortir != 1  ]
do
#crido la funció del menu cada volta
 	menu

#faig un case de totes les opcions de menu
	case $opcio in
		'1')
  			#em conecto mitjançant un ssh
			ssh -T root@192.168.1.1 <<- EOF
   			#redirigeixo la comanda a un fitxer
			lshw -short>lshw.txt;
   			#mostro el fitxer amb un cat
			cat lshw.txt
   			#finalment faig un scp del fitxer i m'ho paso a la maquina local
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
   			#instalo el net-tools en cas de que no esitgues instalat
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
  			#igualo la variable de sortida a 1 i el bucle acaba
			sortir=1
		;;
	esac
 	#faig un if per que no entri en cas de finalització del programa
	if [ $opcio != '7' ];then
 		#creo una variable de data
		data=`date +%F`
  		#creo el index.html
		cat <<- FITXER > index.html
		#creo el HTML per mostra-lo en el navegador
  		<html>
			<head><title>Resultats</title></head>
			<body>
				<h1>Resultats:</h1>
    				#introdueixo la variable data en un h3
				<h3>$data</h3>
				<pre>
		FITXER
  		#faig un cat del fitxer on he guardat els resultats de la comanda 
		cat /home/david/resultats.txt >> index.html
		echo "</pre>" >> index.html
		echo "</body>" >> index.html
		echo "</html>" >> index.html
  		#finalment mostro el resultat del index.html en el navegador
		firefox index.html
	fi
done
