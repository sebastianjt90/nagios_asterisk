#!/bin/bash
#Creado por Sebastian Jimenez Trujillo
#MAAKAL SYSTEMS SA

#Direccion IP de la troncal
troncal=172.17.179.166

#Construimos un array para guardar la perdida del canal
declare -a perdida=($(asterisk -rx 'sip show channelstats' | grep 00 | grep : | grep -v $troncal | cut -d '(' -f 2 | cut -d ')' -f 1 | tr -d '%' | cut -d '.' -f1))

#Construimos otro array 'id_llamada' esta vez almacenando el código de la llamada correspondiente a la pérdida
declare -a id_llamada=($(asterisk -rx 'sip show channelstats' | grep 00 | grep : | grep -v $troncal | awk '{print $2":"$3}' | cut -d ':' -f 1))

declare -a tiempo_llamada=($(asterisk -rx 'sip show channelstats' | grep 00 | grep : | grep -v $troncal | awk '{print $3}'))


posiciones=${#perdida[@]}
posiciones=$((posiciones-1))

for i in $(seq 0 $posiciones);
  do
    perdida_valor=${perdida[i]}
    tiempo_llamada_valor=${tiempo_llamada[i]}
    if (( $perdida_valor > 20 )); then
      id=${id_llamada[i]}
      extension_problema=$(asterisk -rx 'sip show channels' | grep $id | awk '{print $2}')
      salida+=("Extension:$extension_problema Pérdida:$perdida_valor% Tiempo de llamada:$tiempo_llamada_valor")
    fi
done

for i in $(seq 0 $posiciones);
  do
    perdida_valor=${perdida[i]}
    if (( $perdida_valor > 40 )); then
       printf '%s\n' "${salida[@]}"
       exit 2
    fi
done

for i in $(seq 0 $posiciones);
  do
    perdida_valor=${perdida[i]}
    if (( $perdida_valor > 20 && $perdida_valor < 41 )); then
       printf '%s\n' "${salida[@]}"
       exit 1
    fi
done

echo Calidad de Llamadas OK
exit 0
