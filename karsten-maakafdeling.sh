#!/bin/bash

start() {
    clear

    read -p "enter directory naam: " dirnaam

    if [ -d "/$dirnaam" ]; then
        echo "directory /$dirnaam bestaat al."
    else
        clear
        mkdir "/$dirnaam"
        echo "directory /$dirnaam aangemaakt."
    fi
}

clear

# controleer of een afdelingsnaam wel als argument is meegegeven
if [ $# -eq 0 ]; then
    echo "Fout: er is geen afdelingsnaam opgegeven."
    sleep 0.5
    echo
    echo "Gebruik: $0 <afdelingsnaam>"
    exit 1
fi

afdeling="$1"
voornaam="karsten"
basisdir="/$voornaam"

# maak de hoofddirectory voor de naam aan in de root directory
if [ ! -d "$basisdir" ]; then # de ! staat voor "niet" dus als de directory niet bestaat, dan word deze gemaakt
    mkdir "$basisdir"
    echo "directory $basisdir aangemaakt."
else
    echo "directory $basisdir bestaat al."
fi

# maak subdirectories voor de afdeling aan
mkdir -p "$basisdir/${afdeling}-RWdocs" "$basisdir/${afdeling}-ROdocs"
echo "directory $basisdir/${afdeling}-RWdocs aangemaakt."
echo "directory $basisdir/${afdeling}-ROdocs aangemaakt."
