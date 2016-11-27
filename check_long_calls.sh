#!/bin/bash
#Creado por Sebastian Jimenez Trujillo
#MAAKAL SYSTEMS SA

#Direccion IP de la troncal
troncal=172.17.179.166

#Construimos el array "tiempo" en el cual estará almacenado las horas de duración de llamadas
declare -a tiempo=($(asterisk -rx 'sip show channelstats' | grep 00 | grep -v $troncal | awk '{print $2":"$3}' | grep : | cut -d ':' -f 2 | awk '{print substr($0,0,2)}'))

#Construimos otro array 'id_llamada' esta vez almacenando el código de la llamada correspondiente a la duración
declare -a id_llamada=($(asterisk -rx 'sip show channelstats' | grep 00 | grep -v $troncal | awk '{print $2":"$3}' | grep : | cut -d ':' -f 1))

#Se crea condicional se recorre el primer arreglo según los siguientes valores salen alertas
  #Si todos los valores estan en 0 se hace exit 0 con servicio OK
  #Si alguno de los valores está entre 1 y 2 hacemos un exit 1 con advertencia por llamada larga
  #Si alguno de los valores está en 3 o más hacemos un exit en 2 con estado crítico y mensaje de canal pegado

#Almaceno en una variable la cantidad de elementos que tiene el array tiempo
posiciones=${#tiempo[@]}
posiciones=$((posiciones-1))

for i in $(seq 0 $posiciones);
  do
    tiempo_valor=${tiempo[i]}
    if (( $tiempo_valor > 2 )); then
      id=${id_llamada[i]}
      extension_problema=$(asterisk -rx 'sip show channels' | grep $id | awk '{print $2}')
      echo CRITICAL Llamada posiblemente pegada en extension $extension_problema REVISAR
      exit 2
    fi
done

for i in $(seq 0 $posiciones);
  do
    tiempo_valor=${tiempo[i]}
    if (( $tiempo_valor == 1 || $tiempo_valor == 2  )); then
      id=${id_llamada[i]}
      extension_problema=$(asterisk -rx 'sip show channels' | grep $id | awk '{print $2}')
      echo WARNING Llamada larga en extension $extension_problema REVISAR
      exit 1
    fi
done

echo Tiempo de Llamadas OK
exit 0
