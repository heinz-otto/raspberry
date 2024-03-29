#!/bin/bash
# Dieses Script installiert FHEM falls es noch nicht vorhanden ist!
# Im FHEM wird ein Installer Device im Developer Modus definiert
# mit Hilfe meines bash FHEM Client wird eine Abfrage der "alten" fhem.cfg durchgeführt und alle benötigten Module ausgegeben
# ein copy & paste für dann zur Installation der fehlenden Perl Module
# am Einfachsten liegt die alte fhem.cfg vor Start des Script im aktuellen Verzeichnis

# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi
# Script Pfad setzen
ref=$1
[ -z "$ref" ] && ref=$(realpath ./fhem.cfg)

# functions
# getFile FileName RepositoryName
get-File() {
  if [ ! -e $1 ]
  then
    echo "$1 is missing"
    wget https://raw.githubusercontent.com/heinz-otto/$2/master/$1
    chmod +x $1
  fi
}
setup-Fhem() {
# get debian version strings with dot sourcing
. /etc/os-release
  if [ $VERSION_ID -ge 10 ] ;then
    apt install gpg
    if wget -qO - https://debian.fhem.de/archive.key | gpg --dearmor > /usr/share/keyrings/debianfhemde-archive-keyring.gpg ;then
      echo "deb [signed-by=/usr/share/keyrings/debianfhemde-archive-keyring.gpg] https://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
      key='ok'
    fi
  else
    if [ "$(wget -qO - http://debian.fhem.de/archive.key | apt-key add -)" = "OK" ] ;then
      echo "deb http://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
      key='ok'
    fi
  fi
  if [ $key = 'ok' ] ;then
    apt update
    apt install fhem
  else
    echo Es gab ein Problem mit dem debian.fhem.de/archive.key
    exit 1
  fi
}
analyze-config() {
  # Abfrage starten
  PerlModul=$(./fhemcl.sh 8083 "get installer checkPrereqs $1"|grep -oE 'installPerl.*&fwcsrf'|grep -oE '\s[a-z,A-Z,:]+\s')
  DebianPaket=$(echo $PerlModul|tr " " "\n"|sed '/^JSON$/d;s/$/./;s/^/\//'|apt-file search -l -f -)
  # auf einem docker container - nur als Notiz
  # DebianPaket=$(echo $PerlModul|tr ' ' "\n"|sed '/^JSON/d;s/$/./;s/^/\//'|docker exec -i <containername> apt-file search -l -f -)
  # Ausgabe
  if [ -z "$PerlModul" ] ;then
    echo 'es fehlen keine Perl Module' 
  else
    echo "es fehlen diese Perl Module"
    echo $PerlModul
  fi
  if [ -z "$DebianPaket" ] ;then
    echo 'kein fehlendes debian Paket ermittelt' 
  else
    echo "mit folgenden debian Paketen könnten die oben genannten Perl Module installiert werden"
    echo $DebianPaket
  fi
    echo "Nach einer Installation und vor erneuten Test: sudo systemctl restart fhem"
}
# Hauptprogramm
# System aufrüsten
PKG="libperl-prereqscanner-notquitelite-perl"
if dpkg-query -l $PKG > /dev/null
  then
      echo "System schon aufgerüstet"
  else
      apt update
      apt install apt-file libperl-prereqscanner-notquitelite-perl
      apt-file update
fi
# fhem installieren
PKG="fhem"
dpkg-query -l $PKG > /dev/null || setup-Fhem

# get the HTTP Client
get-File fhemcl.sh fhemcl

# Definition zum Testen erstellen
if [[ "$(./fhemcl.sh 8083 "list installer installerMode")" =~ "developer" ]]
  then
    echo "Installermodul bereits eingerichtet"
  else
cat <<EOF | ./fhemcl.sh 8083
attr initialUsbCheck disable 1
defmod installer Installer
attr installer installerMode developer
save
EOF
fi
# Analyse starten
if [ -z "$ref" ]
  then
  read -p "Dateiname eingeben:"ref
fi
# Test if File exist and ist not empty
if [ -s "$ref" ]
then
  printf "\nAnalyse mit Datei $ref wird gestartet\n"
  analyze-config $ref
  echo $PerlModul > PerlModul
  echo $DebianPaket > DebianPaket
fi
