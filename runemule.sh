#!/bin/bash

# renice 19 $$

unshare () {
    orig="$1"
    dest="$2"
    if [ -d "$orig" ] && [ -d "$dest" ]; then
        find "$1" -follow -mindepth 1 -maxdepth 1 | while read arq; do
            base="`basename \"$arq\"`"
            baseorig="$base"
            if [ -e "$dest/$base" ]; then
                conta='0'
                while true; do
                    conta=$((conta+1))
                    base="$baseorig.$conta"
                    echo "$base"
                    [ -e "$dest/$base" ] || break
                done
            fi
            mv -fv "$orig/$baseorig" "$dest/$base"
        done
        return 0
    else
        kdialog --title 'Erro!' --error 'Erro: crie manualmente a pasta de downloads do eMule e a pasta privada de downloads!'
        return 1
    fi
}

while true; do
    WINEPREFIX=/home/amg1127/.wine-emule wine c:\\emule-latest\\emule.exe & pid=$!
    sleep 1m
    while [ -e /proc/$pid ]; do
        sleep 30
        if ! unshare "/home/amg1127/aMule/completed" "/home/amg1127/aMule/private"; then
            kill $pid
        fi
    done
    unshare "/home/amg1127/aMule/completed" "/home/amg1127/aMule/private"
    tempfile="`false`"
    if [ -f "$tempfile" ]; then
        ( kdialog --yesno 'Deseja manter o eMule fechado?' --title 'Fechar o eMule' ; echo $? > "$tempfile" ) & pid=$!
    else
        kdialog --msgbox 'Pressione OK para manter o eMule fechado.' --title 'Fechar o eMule' & pid=$!
    fi
    sleep 5
    for i in `seq 1 60`; do
        sleep 1
        if ! [ -e /proc/$pid ]; then
            if [ -f "$tempfile" ]; then
                if [ "`cat \"$tempfile\"`" -eq 0 ]; then
                    rm -f "$tempfile"
                    echo ' **** Saindo... ****'
                    exit 0
                fi
                rm -f "$tempfile"
                break
            else
                exit 0
            fi
        fi
    done
    [ -e /proc/$pid ] && kill -KILL $pid
    [ -f "$tempfile" ] && rm -f "$tempfile"
done
