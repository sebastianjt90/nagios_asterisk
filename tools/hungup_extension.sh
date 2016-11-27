#!/bin/bash
#Creado por Sebastian Jimenez Trujillo
#MAAKAL SYSTEMS SA

#Script de prueba para colgar una linea por consola
read -p 'Inserte la extension que desea colgar:  ' extension
while true; do
    read -p "Esta seguro que quiere colgar la extension $extension S/N ? " yesno
    case $yesno in
        [Ss]* )	 colgar=$(asterisk -rx 'core show channels' | grep $extension | awk 'NR==1{print $1}');
		if [ -z "$colgar" ]; then
			echo No hay ninguna llamada asociada a la extension
		else
			asterisk -rx "channel request hangup $colgar"
			echo La extension $extension con identificador $colgar, se ha colgado exitosamente
		fi
		break;;
        [Nn]* ) exit;;
        * ) echo "Por favor ingrese S/N ";;
    esac
done
