https://drive.google.com/file/d/1Xxz-Ea2LEV9esEIV0Tc6E7hDzME3FKEm/view?usp=drivesdk#!/bin/bash
#


# variables
afdeling="$1"
groepsnaam="${afdeling}-gr"
voornaam="karsten"
basisdir="/$voornaam"
# variables


# kleuren voor de output
# source: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# source: https://askubuntu.com/questions/517677/how-do-i-get-a-colored-bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
# kleuren voor de output


# ------------ START block met checks om te controleren of het script correct word uitgevoerd ----------------
# _____________________________________________________________________________________________________________
#
# check of script als root word uitgevoerd


if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Fout: script moet als root worden uitgevoerd.${NC}"
    exit 1
fi
# check of script word uitgevoerd op een linux systeem
if [ "$(uname -s)" != "Linux" ]; then
    echo -e "${RED}Fout: script is alleen bedoeld voor Linux systemen.${NC}"
    exit 1
fi
# controleer of een afdelingsnaam wel als argument is meegegeven
if [ $# -eq 0 ]; then
    echo -e "${RED}Fout: er is geen afdelingsnaam opgegeven.${NC}"
    sleep 0.5
    echo
    echo "Gebruik: $0 <afdelingsnaam>"
    echo
    
    # loading animation om het wachten wat minder saai te maken
    # source: https://stackoverflow.com/questions/12498304/creating-a-simple-loading-animation-in-bash

    for i in {1..3}; do
        echo -n "."
        sleep 0.3
    done
    echo
    exit 1
fi

# ------------  EINDE block met checks om te controleren of het script correct word uitgevoerd ----------------
# _____________________________________________________________________________________________________________
#
# ---------------------- START block met de daadwerkelijke uitvoering van het script --------------------------
# _____________________________________________________________________________________________________________


echo -e "het volgende zal worden uitgevoerd:${NC}"
echo -e "1. Er zal een groep worden aangemaakt met de naam ${YELLOW}$groepsnaam${NC}.${NC}"
echo -e "2. Er zal een directory worden aangemaakt in de root directory met de naam ${YELLOW}$basisdir${NC}.${NC}"
echo -e "3. Er zullen twee subdirectories worden aangemaakt in ${YELLOW}$basisdir${NC}, genaamd ${YELLOW}${afdeling}-RWdocs${NC} en ${YELLOW}${afdeling}-ROdocs${NC}.${NC}"
echo -e "Voer het script opnieuw uit als u deze acties wilt uitvoeren.${NC}"
echo
sleep 0.5
read -p "Wilt u doorgaan? (y/n) " antwoord
if [[ "$antwoord" != "y" ]]; then
    echo "Script wordt afgebroken."
    exit 0
fi



# maakt een groep aan vanaf gid 3000
if getent group "$groepsnaam" >/dev/null; then
    echo "groep $groepsnaam bestaat al."
else
    gid=3000
    while getent group "$gid" >/dev/null; do
        gid=$((gid + 1))
    done

    groupadd -g "$gid" "$groepsnaam"
    if [ $? -eq 0 ]; then
        echo "groep $groepsnaam aangemaakt met gid $gid."
    else
        echo "Fout: groep $groepsnaam kon niet worden aangemaakt."
        exit 1
    fi
fi


# maakt de hoofddirectory voor de naam aan in de root directory
if [ ! -d "$basisdir" ]; then # de ! staat voor 'niet' dus als de directory niet bestaat dan word deze gemaakt
    mkdir "$basisdir"
    echo "directory $basisdir aangemaakt."
else
    echo "directory $basisdir bestaat al."
fi


# maakt subdirectories voor de afdeling aan
if [ -d "$basisdir/${afdeling}-RWdocs" ]; then
    echo "directory $basisdir/${afdeling}-RWdocs bestaat al."
else
    mkdir "$basisdir/${afdeling}-RWdocs"
    echo "directory $basisdir/${afdeling}-RWdocs aangemaakt."
fi

if [ -d "$basisdir/${afdeling}-ROdocs" ]; then
    echo "directory $basisdir/${afdeling}-ROdocs bestaat al."
else
    mkdir "$basisdir/${afdeling}-ROdocs"
    echo "directory $basisdir/${afdeling}-ROdocs aangemaakt."
fi

sleep 0.5
echo "Alle directories zijn succesvol aangemaakt."






# INSTRUCTIES HOE TE GEBRUIKEN
# 1. sla het script op als karsten-maakafdeling.sh
# 2. open een terminal en navigeer naar de locatie van het script
# 3. voer het script uit met root rechten en geef de naam van de afdeling als argument mee, bijvoorbeeld: sudo bash karsten-maakafdeling.sh sales
# 4. het script zal controleren of het correct word uitgevoerd en zal vervolgens de groep en directories aanmaken zoals beschreven

