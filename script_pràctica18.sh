#!/bin/bash

#https://github.com/a18pauenjsum/projecte-03

usage(){
cat <<EOF
Usage: ./disable-local-user.sh [-dra] USER [USERN]
Instruccions per fer servir aquest script.
  -d Elimina els usuaris en comptes de desabilitar-los.
  -r Elimina el directori associat al usuari/usuaris.
  -a Crea un arxiu en la carpeta home del usuari que s'esta fent servir.
EOF
exit 1
}

while getopts :dra o
do
        case $o in
                d)
                        delete=true ;;
                r)
			rd=true ;;
				a)
	                archive=true ;;
                \?)
			echo "ERROR: Opció no és vàlida. -$OPTARG"
                        usage ;;
				:)
		        echo "ERROR: -$OPTARG necessita algo més." ;;
				*)
			echo "Error desconegut."
			usage ;;
        esac
done

shift $((OPTIND - 1))

if [ $(id -u) -eq 0 ]; then
	if [ $# -ne 0 ]; then
		for user in $@; do
			echo "Processant usuari: $user"
			if id -u "$user" > /dev/null 2>&1 ; then		
				if [  $(id -u $user) -gt 999 ]; then
					if [ $archive ]; then
						if [ ! -d /archive/ ]; then
							mkdir /archive/
							echo "Creant l'arxiu directori /archive ."
						fi
						echo "Comprimint /home/$user en /archive/$user.tgz"
						tar czvf /archive/$user.tgz /home/$user > /dev/null 2>&1
					fi
					if [ $rd ]; then
						rm -rf /home/$user
						if [ $? -eq 0 ]; then echo "La carpeta /home/$user ha estat eliminada correctament."; else echo "The directory /home/$user could not be deleted"; fi
					fi
					if [ $delete ]; then
						userdel $user
						if [ $? -eq 0 ]; then echo "L'usuari $user ha estat eliminat."; 
						else echo "L'usuari $user no ha pogut ser eliminat."; 
						fi
					fi
					if [ ! $archive ] && [ ! $rd ] && [ ! $delete ]; then
						usermod -L $user
						echo "L'usuari $user ha estat desabilitat."
					fi
				else
					echo "S'ha denegat l'eliminació de l'usuari $user amb l'UID $(id -u $user)."
				fi
			else
				echo "L'usuari $user no existeix."
			fi 
		done	
	else
		usage
	fi
else
        echo 'Si us plau, executa el fitxer com a super usuari o root.'; exit 1
fi
