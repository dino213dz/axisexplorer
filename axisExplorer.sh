#!/bin/bash
######################################################################
# SCRIPT NAME : axisExplorer.sh
######################################################################
#
# CHORFA Alla-eddine a.k.a. Dino
# h4ckr213dz@gmail.com
# https://github.com/dino213dz
#
# Description: Explore AXIS Camera Files frome bash
# Created: 08/18/19
# Updated: 08/18/19
# Version: 0.1 Beta
#		___.___    ~            _____________
#		\  \\  \   ,, ???      |        '\\\\\\
#		 \  \\  \ /<   ?       |        ' ____|_
#		  --\//,- \_.  /_____  |        '||::::::
#		      o- /   \_/    '\ |        '||_____|
#		      | \ '   o       '________|_____|
#		      |  )-   #     <  ___/____|___\___
#		      `_/'------------|    _    '  <<<:|
#	        	  /________\| |_________'___o_o|
#
######################################################################
# VARIABLES:
######################################################################

#SCRIPT VARS:
d213_author="CHORFA Alla-eddine a.k.a. Dino"
d213_email="h4ckr213dz@gmail.com"
d213_website="https://github.com/dino213dz"
d213_version="0.1 Beta"
d213_created="08/18/19"
d213_updated="08/18/19"

#STYLE VARS:
declare -A d213_colors=( ['red']="\033[1;31m" ['yellow']="\033[1;33m" ['green']="\033[1;32m" ['darkgreen']="\033[0;32m" ['cyan']="\033[1;36m" ['blue']="\033[1;34m" ['magenta']="\033[1;35m" ['white']="\033[1;37m" ['black']="\033[1;30m" )
declare -A d213_styles=( ['reset']="\033[0m" ['italic']="\033[3m" ['bold']="\033[1m" ['underlined']="\033[4m" ['blink']="\033[5m" )
declare -A d213_puces=( ['plus']="[+] " ['minus']=" |_[-] " ['error']="[X] " )

#TEXTE STYLES VARS
color_title=${d213_colors["yellow"]}
color_subtitle=${d213_colors["yellow"]}
color_subsubtitle=${d213_colors["yellow"]}
color_text=${d213_colors["cyan"]}
color_script=${d213_colors["darkgreen"]}
color_error=${d213_colors["red"]}
color_prompt=${d213_colors["yellow"]}
color_username=${d213_colors["blue"]}
color_password=${d213_colors["red"]}
color_host=${d213_colors["magenta"]}
color_wd=${d213_colors["green"]}

style_reset=${d213_styles["reset"]}
style_title=$style_reset$color_title""${d213_puces["plus"]}
style_subtitle=$style_reset$color_subtitle""${d213_puces["minus"]}
style_subsubtitle=$style_reset$color_subsubtitle" \02 \02 \02 "${d213_puces["minus"]}
style_text=$style_reset$color_text""
style_script=$color_script""${d213_styles["italic"]}
style_error=$style_reset$color_error""${d213_puces["error"]}
wd='/'
file=''
path=$wd
temp_file='./temp.out'
prompt_format="AXIS CMD [__USER__@__IP__: __WD__] $ "
username_default='root'
password_default='pass'
user="$username_default"
mdp="$password_default"

######################################################################
# FUNCTIONS:
######################################################################
function newScriptTemplate {
	echo "Function template"	
	}
function afficherAide {
	#echo -e ""
	echo -e $style_subtitle"Commandes:"
	echo -e $style_subsubtitle"help:$style_text \t\tAffiche cette aide"
	echo -e $style_subsubtitle"ls PATH:$style_text \t\tListe le contenu du dossier distant PATH"
	echo -e $style_subsubtitle"cat FILE:$style_text \t\tListe le contenu du fichier distant FILE"
	echo -e $style_subsubtitle"lls:$style_text \t\t\tRuns ls on local machine"
	echo -e $style_subsubtitle"cd PATH:$style_text \t\tChange the working directory to PATH"
	echo -e $style_subsubtitle"lcd PATH:$style_text \t\tChange the local working directory to PATH"
	echo -e $style_subsubtitle"pwd:$style_text \t\t\tShows the current working directory"
	echo -e $style_subsubtitle"lpwd:$style_text \t\tRuns pwd on local machine"
	echo -e $style_subsubtitle"upload LOCALFILE REMOTEFILE CHMOD:$style_text uploads the local file LOCALFILE to the host and names it REMOTEFILE with rwx rights (755 for example)"
	echo -e $style_subsubtitle"credentials:$style_text \t\tShows the credentials that are being used to authenticate"
	echo -e $style_subsubtitle"set pass NEWPASSWORD:$style_text Sets the password used for authentication to NEWPASSWORD"
	echo -e $style_subsubtitle"set user NEWUSERNAME:$style_text Sets the username used for authentication to NEWUSERNAME"
	echo -e $style_subsubtitle"cls:$style_text \t\t\tClear Screen. Efface le contenu du terminal."
	echo -e $style_subsubtitle"quit:$style_text \t\tQuitter ce programme"
	echo -e ""
	}
function enDev {
	echo -e $style_error"Commandes <$1> est en cours de developpement encore!"	
	}
function listFolderRequest {
	fl="$1"
	fl=${fl//\//%2F}
	curl -ks "http://$ip/admin-bin/editcgi.cgi?file=$fl" --user "$user:$mdp" --output "$temp_file"	
	}
function catFileRequest {
	fc="$1"
	curl -ks "http://$ip/admin-bin/editcgi.cgi?file=$fc" --user "$user:$mdp" --output "$temp_file"	
	}
function changeDirectory {
	wdp="$1"

	#relative path
	if [ "${wdp:0:1}" = '.' ];then
		wd=$wd'/'$wdp
	#absolute path
	elif [ "${wdp:0:1}" = '/' ];then
		wd=$wdp
	#current wd
	else
		wd=$wd'/'$wdp
	fi
	
	wd=$(filterPath $wd)
	}
function filterPath {
	p="$1"
	pf="$p"
	pf=${pf//\/\//\/}
	echo $pf
	}
function formatterResultat {
	ligne_formattee=$1
	balises_html=("pre" "html" "HTML" "body" "BODY" "form" "FORM" "table" "TABLE" "td" "TD" "tr" "TR" "textarea" "TEXTAREA" "input" "INPUT" )
	balises_html_alt=("a" "A" "td" "TD" "tr" "TR" "input" "INPUT" "form" "FORM" )
	special_tags=("Convert CRLF*" "\[Select*" "Mode*" "Save*" )
	for balise in ${balises_html[@]};do
		ligne_formattee=${ligne_formattee//<$balise>/}
		ligne_formattee=${ligne_formattee//<\/$balise>*/}
	done
	for balise in ${balises_html_alt[@]};do
		ligne_formattee=${ligne_formattee/<\/$balise>/}
		ligne_formattee=${ligne_formattee/\<$balise *\>/}
	done
	for balise in ${special_tags[@]};do
		ligne_formattee=${ligne_formattee//<$balise>/}
		ligne_formattee=${ligne_formattee//$balise/}
	done
	echo $ligne_formattee	
	}
function showCredentials {
	echo -e $style_subtitle"CREDENTIALS:$style_text $ip"
	echo -e $style_subsubtitle"USERNAME:$style_text $user"
	echo -e $style_subsubtitle"PASSWORD:$style_text $mdp"
	echo -e ""	
	}
function showInfos {
	echo -e $style_title"INFORMATION:$style_text $ip"
	echo -e $style_subtitle"IP:$style_text $ip"
	echo -e $style_subtitle"USERNAME:$style_text $user"
	echo -e $style_subtitle"PASSWORD:$style_text $mdp"
	echo -e ""

	}
function setParameters {
	fvar=$1
	fval=$2	
	msg=''
	case "$fvar" in
		"user" | "USER" ) 	
				user="$fval"
				msg=$style_subtitle"Username changed:"
				;;
		"pass" | "PASS" | "password" | "PASSWORD" | "pwd" | "PWD" ) 	
				mdp="$fval"
				msg=$style_subtitle"Passord changed:"
				;;
		*)
				msg=$style_subtitle"ERREUR: "$color_error"Parametre inconnue:"
				;;
	esac
	echo -e "$msg$style_text <$fvar=$fval>"
	}
function formatPromt {
	promptform="$prompt_format"
	promptform=${promptform//__USER__/$color_username$user$color_prompt}
	promptform=${promptform//__IP__/$color_host$ip$color_prompt}
	promptform=${promptform//__WD__/$color_wd$wd$color_prompt}
	promptform=$style_title$color_prompt""$promptform""$style_text
	echo $promptform
	}
######################################################################
# ARGS:
######################################################################
args=("$@")
nb_args=$#
for no_arg in $(seq 0 $nb_args); do
	value=${args[$no_arg]}
	if [ ${#value} -gt 0 ];then
		if [ "$value" = "--help" ] || [ "$value" = "-h" ];then
			afficherAide
			exit
		fi
		if [ "$value" = "--username" ] || [ "$value" = "-u" ];then
			user=${args[$(($no_arg+1))]}
		fi
		if [ "$value" = "--password" ] || [ "$value" = "-p" ];then
			mdp=${args[$(($no_arg+1))]}
		fi
		if [ "$value" = "--target" ] || [ "$value" = "-t" ];then
			target=${args[$(($no_arg+1))]}
			ip=$target
			ip=${ip/*\:\/\//}
			ip=${ip/\/*/}
			port=${ip/*\:/}
			ip=${ip/\:*/}
		fi
		if [ "$value" = "--file" ] || [ "$value" = "-f" ];then
			file=${args[$(($no_arg+1))]}
		fi
	fi
done

if [ ${#target} -eq 0 ];then
	echo -e $style_error"Parametre --target|-t est manquant"${d213_styles["reset"]}
	exit
fi
if [ ${#user} -eq 0 ];then
	echo -e $style_error"Parametre --user|-u est manquant"${d213_styles["reset"]}
	exit
fi
if [ ${#mdp} -eq 0 ];then
	echo -e $style_error"Parametre --password|-p est manquant"${d213_styles["reset"]}
	exit
fi
######################################################################
# MAIN PROGRAM:
######################################################################
showInfos
prompt=$(formatPromt)

# vars: cmd, params, path, file

echo -en "$prompt"
while read commande; do
	if [ "$commande" != "" ];then
	echo -en "$style_script"
	cmd=$(echo "$commande"|cut -d " " -f 1)
	params=$(echo "$commande"|cut -d " " -f 2-)
	if [ "$params" = "$cmd" ] || [ ${#params} -eq 0 ];then
		params=$wd
	fi
	
	#relative path
	if [ "${params:0:1}" = '.' ];then
		path=$wd'/'$params
	#absolute path
	elif [ "${params:0:1}" = '/' ];then
		path=$params
	#current wd
	else
		path=$wd'/'$params
	fi
	path=$(filterPath $path)

		commande_status="BAD"
		case "$cmd" in
			"exit" | "quit" ) 	
					commande_status="OK"
					#echo -e "EXIT $params"
					break
					;;
			"lls" | "localls" | "lslocal" ) 
					commande_status="OK"	
					echo -e "Contenu de: "$(pwd)"" > $temp_file			
					ls $params >> $temp_file
					;;
			"ls" | "dir" ) 	
					commande_status="OK"
					#echo -e "LIST <$path>"
					listFolderRequest "$path"
					;;
			"cat" | "type" ) 	
					commande_status="OK"
					file=$path
					#echo -e "CAT <$path>"
					catFileRequest "$path"
					;;
			"cls" | "clear" ) 	
					clear
					;;
			"upload" ) 	
					commande_status="OK"
					lfile=$(echo $params|cut -d ' ' -f 1)
					rfile=$(echo $params|cut -d ' ' -f 2)
					mode=$(echo $params|cut -d ' ' -f 2)
					echo -e "Local file: $lfile\nRemote file: $rfile\nChmod: $mode"  > $temp_file
					;;
			"lcd" ) 	
					commande_status="OK"
					echo -e "LOCALHOST: CD $params" > $temp_file
					cd $params 2>&1 >> $temp_file
					;;
			"cd" ) 	
					path=$params
					#echo -e "CD <$path>"
					changeDirectory "$path"
					;;
			"pwd" ) 	
					echo -e $style_subtitle"Current working directory:$style_text $wd\n"
					;;
			"lpwd" ) 	
					commande_status="OK"	
					pwd > $temp_file
					;;
			"set" ) 	
					if [[ "$params" =~ '=' ]];then
						var=$(echo $params|cut -d '=' -f 1)
						val=$(echo $params|cut -d '=' -f 2)
					else
						var=$(echo $params|cut -d ' ' -f 1)
						val=$(echo $params|cut -d ' ' -f 2)
					fi				
					
					setParameters "$var" "$val"
					;;
			"credentials" | "cred" | "creds" ) 	
					showCredentials
					;;
			"help" | "aide" ) 	
					afficherAide
					;;
			*)
					echo -e $style_subtitle"ERREUR: "$color_error"Commande inconnue <$commande>"
					afficherAide
		    			;;
		esac

		if [ "$commande_status" = "OK" ];then
			if [ -f $temp_file ];then
				no_ligne=0
				while read ligne;do
					if [ ${#ligne} -gt 0 ];then
						if [[ "$ligne" =~ "Failed " ]];then
							echo -e $style_error"Erreur: $ligne"
						else
							ligne_formattee=$(formatterResultat "$ligne")
							#ligne_formattee="$ligne"
							if [ ${#ligne_formattee} -gt 0 ];then
								no_ligne=$(( $no_ligne+1 ))
								if [ $no_ligne -eq 1 ];then
									if [ "$cmd" = "ls" ];then
										ligne_formattee=$style_subtitle"Contenu du dossier:"$style_text" "$path"\n"$style_script
									fi
									if [ "$cmd" = "cat" ];then
										fichier=$file
										taille=$(echo $ligne|cut -d ' ' -f 4)
										ligne_formattee=$style_subtitle"Contenu du fichier:"$style_text" "$fichier"\n"$style_subtitle"Taille du fichier:"$style_text" "$taille" octets\n"$style_script""
									fi
								fi
								echo -e "$ligne_formattee"
							fi
						fi
					fi
				done < "$temp_file"
				rm -f "$temp_file" 2>&1 >/dev/null
			else
				echo -e $style_error"Pas de réponse du serveur: <réponse nulle ou timeout>"
			fi
			echo ''
		fi
	else
		#commande vide
		echo -e $style_script":p"
	fi
	prompt=$(formatPromt)
	echo -en "$prompt"
done
######################################################################
# END:
######################################################################
if [ -f $temp_file ];then
	rm -f "$temp_file" 2>&1 >/dev/null
fi
echo -e $style_subtitle"Program End:$style_text Bye!"${d213_styles["reset"]}

