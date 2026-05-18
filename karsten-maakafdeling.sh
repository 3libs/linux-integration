
#!/bin/bash
#


# variables
afdeling="$1"
groepsnaam="${afdeling}-gr"
voornaam="karsten"
basisdir="/$voornaam"
admin="${afdeling}-admin"
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
#
#
# ---------------------- START block met de daadwerkelijke uitvoering van het script --------------------------
# 


echo -e "het volgende zal worden uitgevoerd:${NC}"
echo -e "1. Er zal een groep worden aangemaakt met de naam ${YELLOW}$groepsnaam${NC}.${NC}"
echo -e "2. Er zal een directory worden aangemaakt in de root directory met de naam ${YELLOW}$basisdir${NC}.${NC}"
echo -e "3. Er zullen twee subdirectories worden aangemaakt in ${YELLOW}$basisdir${NC}, genaamd ${YELLOW}${afdeling}-RWdocs${NC} en ${YELLOW}${afdeling}-ROdocs${NC}.${NC}"
echo -e "4. Er zal een admin gebruiker worden aangemaakt met de naam ${YELLOW}$admin${NC}.${NC}"
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


# maakt de admin gebruiker aan met een uid tussen 5500 en 5600
if id "$admin" &>/dev/null; then
    echo "gebruiker $admin bestaat al."
else
    uid=5500
    while getent passwd "$uid" >/dev/null; do
        uid=$((uid + 1))
        if [ "$uid" -gt 5600 ]; then
            echo "Fout: geen vrije uid gevonden tussen 5500 en 5600."
            exit 1
        fi
    done

    useradd -u "$uid" -g "$groepsnaam" -s /bin/sh -m "$admin"
    if [ $? -eq 0 ]; then
        echo "gebruiker $admin aangemaakt met uid $uid."
    else
        echo "Fout: gebruiker $admin kon niet worden aangemaakt."
        exit 1
    fi
fi

# stel het paswoord in voor de admin, dit moet interactief gebeuren
echo "stel een paswoord in voor $admin:"
passwd "$admin"

# gebruiker moet paswoord wijzigen bij eerste login en paswoord verloopt na 40 dagen
chage -d 0 "$admin"
chage -M 40 "$admin"
echo "paswoordbeleid ingesteld voor $admin."


# voeg de admin toe aan de groep
usermod -aG "$groepsnaam" "$admin"
echo "gebruiker $admin is lid van groep $groepsnaam."


# stel eigenaarschap in van de twee directories
chown "$admin":"$groepsnaam" "$basisdir/${afdeling}-RWdocs"
chown "$admin":"$groepsnaam" "$basisdir/${afdeling}-ROdocs"
echo "eigenaarschap van de directories ingesteld op $admin:$groepsnaam."

# stel rechten in op de RWdocs directory
# 1664: sticky bit zodat enkel de eigenaar bestanden kan wissen, eigenaar rw, groep rw, anderen r
chmod 1664 "$basisdir/${afdeling}-RWdocs"
echo "rechten op ${afdeling}-RWdocs ingesteld op 1664."

# stel rechten in op de ROdocs directory
# 1640: sticky bit zodat enkel de eigenaar bestanden kan wissen, eigenaar rw, groep r, anderen geen rechten
chmod 1640 "$basisdir/${afdeling}-ROdocs"
echo "rechten op ${afdeling}-ROdocs ingesteld op 1640."


# maakt een bestand aan in de hoofddirectory met de vereiste inhoud
echo "This file is created by the script" > "$basisdir/demodoc"
echo "bestand $basisdir/demodoc aangemaakt."


sleep 0.5
echo "Alle directories en gebruikers zijn succesvol aangemaakt."


# toont de eerste 5 groepen uit het groepenbestand in alfabetische volgorde
echo
echo "de eerste 5 groepen uit het groepenbestand in alfabetische volgorde:"
sort /etc/group | head -5


# toont de laatste 4 gebruikers uit het gebruikersbestand in omgekeerde alfabetische volgorde
echo
echo "de laatste 4 gebruikers uit het gebruikersbestand in omgekeerde alfabetische volgorde:"
sort -r /etc/passwd | head -4


# toont alle gebruikers waarvan de naam begint met sys
echo
echo "alle gebruikers waarvan de naam begint met 'sys':"
grep "^sys" /etc/passwd


# toont de lange directory inhoud van de hoofddirectory inclusief verborgen bestanden
echo
echo "directory inhoud van $basisdir (inclusief verborgen bestanden, rechten en eigenaarschap):"
ls -la "$basisdir"


echo
echo "script beeindigd."


# INSTRUCTIES HOE TE GEBRUIKEN
# 1. sla het script op als karsten-maakafdeling.sh
# 2. open een terminal en navigeer naar de locatie van het script
# 3. voer het script uit met root rechten en geef de naam van de afdeling als argument mee, bijvoorbeeld: sudo bash karsten-maakafdeling.sh sales
# 4. het script zal controleren of het correct word uitgevoerd en zal vervolgens de groep en directories aanmaken zoals beschreven

# GEBRUIK VAN AI
# line 125 tot 144 heb ik AI gebruikt omdat ik niet goed wist hoe te formatten en de volgorde van de functions.
# de kleuren heb ik gevonden op fora. AI heeft een suggestie gegeven omdat ik ${NC} was vergeten.

karsten-maakafdeling.sh wordt weergegeven.
