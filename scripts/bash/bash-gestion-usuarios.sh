#!/bin/bash

function importar(){
    if [ -s $1 ]; then
        total=$(awk 'NR>1 && NF {count++} END {print count}' $1)
        cat $1 | tail -$total | while read line; do
            nome=`echo $line | cut -d, -f1 | tr -d '"'`
            pass=`echo $line | cut -d, -f2 | tr -d '"'`
            desc=`echo $line | cut -d, -f3 | tr -d '"'`
            carpeta=`echo $line | cut -d, -f4 | tr -d '"'`
            shell=`echo $line | cut -d, -f5 | tr -d '"'`
            echo $nome $pass $desc $carpeta $shell
            #Comprobar que el usuario no exista
            getent passwd | grep "^$nome:" *> /dev/null
            if [ $? -eq 0 ]; then
                echo El usuario $nome YA existe
            else
                useradd -d $carpeta -m -s $shell -c "$desc" $nome 2> /dev/null
                echo "$nome:$pass" | chpasswd
            fi
            
        done
    else
        echo El fichero indicado no existe o está vacío.
    fi
}

function exportar(){
    echo '"LOGIN","PASSWORD","NOMBRE","HOME_DIR","SHELL"' > $1
    awk -v q='"' 'BEGIN{FS=":"; OFS=";"} {print q$1q,q"?"q,q$5q,q$6q,q$7q}' /etc/passwd >>$1
}


if [ $# -ne 2 ]; then

    echo Uso del script "./bash-gestion-usuarios.sh (-i/-e) fichero.csv"

else
    case "$1" in
        -i) importar $2;;
        -e) exportar $2;;
        *) echo "El parámetro indicado no es correcto.";;
    esac
fi