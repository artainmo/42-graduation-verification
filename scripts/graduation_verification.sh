ACCESS_CODE=$1
LOGIN=$2

if [ $# -ne 2 ]; then
    echo "MISSING ARGUMENTS"
    exit
fi

#curl -sH "Authorization: Bearer $ACCESS_CODE" -g "https://api.intra.42.fr/v2/users/$LOGIN/projects_users?page[size]=100"
#exit

COMMON_CORE_FINISHED=$(curl -sH "Authorization: Bearer $ACCESS_CODE" -g "https://api.intra.42.fr/v2/users/$LOGIN/projects_users?page[size]=100" | jq '.[] | select(.project.name=="ft_transcendence")."validated?"' 2>/dev/null)

if [ $? -ne 0 ]; then
	echo "API call failed, maybe the access code is wrong or outdated."
	exit
fi

if [ -z $COMMON_CORE_FINISHED ] || [ $COMMON_CORE_FINISHED != 'true' ]; then
	echo "You have not even validated the common core yet?"
  read -p 'Do you still want to continue? (y/n): ' input
  if [ $input != 'y' ]; then
  	exit 0
  fi
fi

check_category () {
	local TITLE="$1"; shift
	local MINIMUM_XP="$1"; shift
	local MINIMUM_VALIDATED_PROJECTS="$1"; shift
	local PROJECTS=("$@")
	TOTAL_XP=0
	TOTAL_VALIDATED_PROJECTS=0

	printf "\e[33m\e[4m$TITLE\n\e[0m"
	for ((i = 0; i < ${#PROJECTS[@]}; i+=2)); do
    while true; do
		    PROJECT_FINISHED=$(curl -sH "Authorization: Bearer $ACCESS_CODE" -g "https://api.intra.42.fr/v2/users/$LOGIN/projects_users?page[size]=100" | jq --arg PROJECT "${PROJECTS[$i]}" '.[] | select(.project.name==$PROJECT)."validated?"' 2>/dev/null)
        if [ $? -eq 0 ]; then
          break
        fi
        #printf "\e[2mAPI failed, call again...\e[0m\n"
        sleep 1
    done
    PROJECT_XP=${PROJECTS[$i+1]}
		if [ -z $PROJECT_FINISHED ] || [ $PROJECT_FINISHED != 'true' ]; then
			printf " * \e[31m ${PROJECTS[$i]} - 0/${PROJECT_XP}xp \xE2\x9D\x8C  \e[0m \n"
		else
      while true; do
  		    PROJECT_MARK=$(curl -sH "Authorization: Bearer $ACCESS_CODE" -g "https://api.intra.42.fr/v2/users/$LOGIN/projects_users?page[size]=100" | jq --arg PROJECT "${PROJECTS[$i]}" '.[] | select(.project.name==$PROJECT)."final_mark"' 2>/dev/null)
          if [ $? -eq 0 ]; then
            break
          fi
          #printf "\e[2mAPI failed, call again...\e[0m\n"
          sleep 1
      done
			GAINED_XP=$(($PROJECT_XP*$PROJECT_MARK/100))
			printf " * \e[32m ${PROJECTS[$i]} - $GAINED_XP/${PROJECT_XP}xp \xE2\x9C\x94 \e[0m \n"
			TOTAL_XP=$(($TOTAL_XP+$GAINED_XP))
			TOTAL_VALIDATED_PROJECTS=$(($TOTAL_VALIDATED_PROJECTS+1))
		fi
	done

	if [ $MINIMUM_XP -gt $TOTAL_XP ]; then
		printf "=> TOTAL XP is \e[31m$TOTAL_XP\e[0m XP with minimum being \e[31m$MINIMUM_XP\e[0m XP, you are still missing \e[31m$(($MINIMUM_XP-$TOTAL_XP))\e[0m XP \n"
	elif [ $MINIMUM_XP -ne 0 ]; then
		printf "=> TOTAL XP is \e[32m$TOTAL_XP\e[0m XP with minimum being \e[32m$MINIMUM_XP\e[0m XP\n"
	fi

	if [ $MINIMUM_VALIDATED_PROJECTS -gt $TOTAL_VALIDATED_PROJECTS ]; then
		printf "=> TOTAL VALIDATED PROJECTS is \e[31m$TOTAL_VALIDATED_PROJECTS\e[0m with minimum being \e[31m$MINIMUM_VALIDATED_PROJECTS\e[0m, you are still missing \e[31m$(($MINIMUM_VALIDATED_PROJECTS-$TOTAL_VALIDATED_PROJECTS))\e[0m \n"
	elif [ $MINIMUM_VALIDATED_PROJECTS -ne 0 ]; then
		printf "=> TOTAL VALIDATED PROJECTS is \e[32m$TOTAL_VALIDATED_PROJECTS\e[0m with minimum being \e[32m$MINIMUM_VALIDATED_PROJECTS\e[0m \n"
	fi

	if [ $MINIMUM_XP -gt $TOTAL_XP ] || [ $MINIMUM_VALIDATED_PROJECTS -gt $TOTAL_VALIDATED_PROJECTS ]; then
		printf "\e[31mfailed \xE2\x9D\x8C \e[0m \n"
		return 0
	else
		printf " \e[32mvalidated \xE2\x9C\x94 \e[0m \n"
		return 1
	fi
}

printf '\e[35m***BACHELOR CRITERIA: Internships***\e[0m\n'
TITLE='Internships'
MINIMUM_XP=0
MINIMUM_VALIDATED_PROJECTS=2
PROJECTS=('Startup Internship - Tutor Final Evaluation' 42000
'internship I - Company Final Evaluation' 42000
'internship II - Company Final Evaluation' 63000
'Part_Time I Company Final Evaluation' 42000
'Part_Time II - Company Final Evaluation' 63000)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
bachelor_internships_validated=$?

printf "\e[36mInternships \e[0m"
if [ $bachelor_internships_validated -eq "1" ]; then
	printf "=>\e[32mVALIDATED\e[0m\n"
else
	printf "=> \e[31mFAILED\e[0m\n"
fi

printf '\e[35m***BACHELOR OPTION 1: Web and mobile application development***\e[0m\n'
TITLE='Web'
MINIMUM_XP=15000
MINIMUM_VALIDATED_PROJECTS=2
PROJECTS=('camagru' 4200
'matcha' 9450
'hypertube' 15750
'red tetris' 15750
'darkly' 6300
'h42n42' 9450
'piscine php symfony' 9450
'piscine python django' 9450
'piscine ror' 0)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
bachelor_web_validated=$?

TITLE='Mobile'
MINIMUM_XP=10000
MINIMUM_VALIDATED_PROJECTS=2
PROJECTS=('piscine swift ios' 9450
'ft_hangouts' 4200
'swifty-companion' 4200
'swifty-proteins' 15750
'avaj-launcher' 4200
'swingy' 9450
'fix-me' 15750)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
bachelor_mobile_validated=$?

printf "\e[36mWeb and mobile application development \e[0m"
if [ $bachelor_web_validated -eq "1" ] && [ $bachelor_mobile_validated -eq "1" ]; then
	printf "=> \e[32mVALIDATED\e[0m\n"
	bachelor_web_mobile_validated=1
else
	printf "=> \e[31mFAILED\e[0m\n"
	bachelor_web_mobile_validated=0
fi

printf '\e[35m***BACHELOR OPTION 2: Applicative software development***\e[0m\n'
TITLE='Object Oriented Programming'
MINIMUM_XP=10000
MINIMUM_VALIDATED_PROJECTS=2
PROJECTS=('camagru' 4200 #web projects
'matcha' 9450
'hypertube' 15750
'red tetris' 15750
'darkly' 6300
'h42n42' 9450
'piscine php symfony' 9450
'piscine python django' 9450
'piscine ror' 0
'piscine swift ios' 9450 #mobile projects
'ft_hangouts' 4200
'swifty-companion' 4200
'swifty-proteins' 15750
'avaj-launcher' 4200
'swingy' 9450
'fix-me' 15750
'bomberman' 25200 #OOP specific projects
'nibbler' 9450)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
bachelor_oop_validated=$?

TITLE='Functional programming'
MINIMUM_XP=10000
MINIMUM_VALIDATED_PROJECTS=2
PROJECTS=('piscine ocalm' 9450
'ft_turing' 9450
'ft_ality' 4200
'h42n42' 9450)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
bachelor_fp_validated=$?

TITLE='Imperative programming'
MINIMUM_XP=10000
MINIMUM_VALIDATED_PROJECTS=2
PROJECTS=('libasm' 966
'zappy' 25200
'ft_linux' 4200
'little-penguin-1' 9450
'taskmaster' 9450
'strace' 9450
'malloc' 9450
'matt-daemon' 9450
'nm' 9450
'lem-ipc' 9450
'kfs-1' 15750
'kfs-2' 15750
'kfs-3' 35700
'kfs-4' 25200
'kfs-5' 35700
'kfs-6' 25200
'kfs-7' 35700
'kfs-8' 15750
'kfs-9' 15750
'kfs-x' 35700
'ft_malcolm' 6000
'ft_ssl_md5' 9450
'darkly' 6300
'snow-crash' 9450
'rainfall' 25200
'override' 35700
'boot2root' 11500
'woody-woodpacker' 9450
'famine' 9450
'pestilence' 15750)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
bachelor_ip_validated=$?

printf "\e[36mApplicative software development \e[0m"
if [ $bachelor_oop_validated -eq "1" ] && [ $bachelor_fp_validated -eq "1" ] && [ $bachelor_ip_validated -eq "1" ]; then
	printf "=> \e[32mVALIDATED\e[0m\n"
	bachelor_asd_validated=1
else
	printf "=> \e[31mFAILED\e[0m\n"
	bachelor_asd_validated=0
fi

printf '\e[35m***BACHELOR CRITERIA: Suite***\e[0m\n'
TITLE='Suite'
MINIMUM_XP=0
MINIMUM_VALIDATED_PROJECTS=1
PROJECTS=('42sh' 15750
'doom-nukem' 15750
'Inception-of-Things' 25450
'humangl' 4200
'kfs-2' 15750
'override' 35700
'pestilence' 15750
'rt' 20750)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
bachelor_suite_validated=$?

printf "\e[36mSuite \e[0m"
if [ $bachelor_suite_validated -eq "1" ]; then
	printf "=> \e[32mVALIDATED\e[0m\n"
else
	printf "=> \e[31mFAILED\e[0m\n"
fi

printf '\e[35m***BACHELOR SUMMARY***\e[0m\n'
if [ $bachelor_internships_validated -eq "1" ]; then
	printf " * \e[32m Internships \xE2\x9C\x94 \e[0m \n"
else
	printf " * \e[31m Internships \xE2\x9D\x8C \e[0m \n"
fi
if [ $bachelor_web_mobile_validated -eq "1" ] || [ $bachelor_asd_validated -eq "1" ]; then
	printf " * \e[32m One of two options validated \xE2\x9C\x94 \e[0m \n"
	bachelor_option_validated=1
else
	printf " * \e[31m One of two options validated \xE2\x9D\x8C \e[0m \n"
	bachelor_option_validated=0
fi
if [ $bachelor_web_mobile_validated -eq "1" ]; then
	printf "    * \e[32m Option 1: Web and mobile application development \xE2\x9C\x94 \e[0m \n"
else
	printf "    * \e[31m Option 1: Web and mobile application development \xE2\x9D\x8C \e[0m \n"
fi
if [ $bachelor_asd_validated -eq "1" ]; then
	printf "    * \e[32m Option 2: Applicative software development \xE2\x9C\x94 \e[0m \n"
else
	printf "    * \e[31m Option 2: Applicative software development \xE2\x9D\x8C \e[0m \n"
fi
if [ $bachelor_suite_validated -eq "1" ]; then
	printf " * \e[32m Suite \xE2\x9C\x94 \e[0m \n"
else
	printf " * \e[31m Suite \xE2\x9D\x8C \e[0m \n"
fi
printf "\e[36mEligible for bachelor: 'IT Solutions Designer and Developer' \e[0m"
if [ $bachelor_internships_validated -eq "1" ] && [ $bachelor_option_validated -eq "1" ] && [ $bachelor_suite_validated -eq "1" ]; then
	printf "=> \e[32mVALIDATED\e[0m (if you are level 17 and have attended 10 events) \n"
  bachelor_validated=1
else
	printf "=> \e[31mFAILED\e[0m\n"
  bachelor_validated=0
fi

printf "\n\e[2mFor bachelor you need to be present at 10 informative events. If you do not know how to see your attended events. In this mobile app (https://github.com/artainmo/swifty-companion) a listing of attended events is displayed.\e[0m\n\n"

read -p 'Do you want to verify the master too? (y/n): ' input
if [ $input != 'y' ]; then
	exit 0
fi

printf '\e[35m***MASTER OPTION 1: Network Information Systems Architecture***\e[0m\n'
TITLE='Unix/Kernel'
MINIMUM_XP=30000
MINIMUM_VALIDATED_PROJECTS=0
PROJECTS=('libasm' 966
'zappy' 25200
'ft_linux' 4200
'little-penguin-1' 9450
'taskmaster' 9450
'strace' 9450
'malloc' 9450
'matt-daemon' 9450
'nm' 9450
'lem-ipc' 9450
'kfs-1' 15750
'kfs-2' 15750
'kfs-3' 35700
'kfs-4' 25200
'kfs-5' 35700
'kfs-6' 25200
'kfs-7' 35700
'kfs-8' 15750
'kfs-9' 15750
'kfs-x' 35700)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
master_uk_validated=$?

TITLE='System administration'
MINIMUM_XP=50000
MINIMUM_VALIDATED_PROJECTS=0
PROJECTS=('taskmaster' 9450
'Inception-of-Things' 25450
'cloud-1' 9450
'ft_ping' 4200
'ft_traceroute' 4200
'ft_nmap' 15750)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
master_sa_validated=$?

TITLE='Security'
MINIMUM_XP=50000
MINIMUM_VALIDATED_PROJECTS=0
PROJECTS=('ft_malcolm' 6000
'ft_ssl_md5' 9450
'darkly' 6300
'snow-crash' 9450
'rainfall' 25200
'override' 35700
'boot2root' 11500
'woody-woodpacker' 9450
'famine' 9450
'pestilence' 15750)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
master_security_validated=$?

printf "\e[36mNetwork Information Systems Architecture \e[0m"
if [ $master_uk_validated -eq "1" ] && [ $master_sa_validated -eq "1" ] && [ $master_security_validated -eq "1" ]; then
	printf "=> \e[32mVALIDATED\e[0m\n"
	master_nisa_validated=1
else
	printf "=> \e[31mFAILED\e[0m\n"
	master_nisa_validated=0
fi

printf '\e[35m***MASTER OPTION 2: Database architecture and data***\e[0m\n'
TITLE='Web'
MINIMUM_XP=50000
MINIMUM_VALIDATED_PROJECTS=0
PROJECTS=('camagru' 4200 #web projects
'matcha' 9450
'hypertube' 15750
'red tetris' 15750
'darkly' 6300
'h42n42' 9450
'piscine php symfony' 9450
'piscine python django' 9450
'piscine ror' 0)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
master_web_validated=$?

TITLE='Artificial Intelligence'
MINIMUM_XP=70000
MINIMUM_VALIDATED_PROJECTS=0
PROJECTS=('ft_linear_regression' 4200
'dslr' 6000
'multilayer-perceptron' 9450
'gomoku' 25200
'total-perspective-vortex' 9450
'expert-system' 9450
'krpsim' 9450
'matrix' 7000
'ready set boole' 7000)
check_category "$TITLE" "$MINIMUM_XP" "$MINIMUM_VALIDATED_PROJECTS" "${PROJECTS[@]}"
master_ai_validated=$?

printf "\e[36mDatabase architecture and data \e[0m"
if [ $master_web_validated -eq "1" ] && [ $master_ai_validated -eq "1" ]; then
	printf "=> \e[32mVALIDATED\e[0m\n"
	master_data_validated=1
else
	printf "=> \e[31mFAILED\e[0m\n"
	master_data_validated=0
fi

printf '\e[35m***MASTER SUMMARY***\e[0m\n'
if [ $bachelor_validated -eq "1" ]; then
	printf " * \e[32m Bachelor \xE2\x9C\x94 \e[0m \n"
else
	printf " * \e[31m Bachelor \xE2\x9D\x8C \e[0m \n"
fi
if [ $master_nisa_validated -eq "1" ] || [ $master_ai_validated -eq "1" ]; then
	printf " * \e[32m One of two options validated \xE2\x9C\x94 \e[0m \n"
	master_option_validated=1
else
	printf " * \e[31m One of two options validated \xE2\x9D\x8C \e[0m \n"
	master_option_validated=0
fi
if [ $master_nisa_validated -eq "1" ]; then
	printf "    * \e[32m Option 1: Network Information Systems Architecture \xE2\x9C\x94 \e[0m \n"
else
	printf "    * \e[31m Option 1: Network Information Systems Architecture \xE2\x9D\x8C \e[0m \n"
fi
if [ $master_ai_validated -eq "1" ]; then
	printf "    * \e[32m Option 2: Database architecture and data \xE2\x9C\x94 \e[0m \n"
else
	printf "    * \e[31m Option 2: Database architecture and data \xE2\x9D\x8C \e[0m \n"
fi
printf "\e[36mEligible for master: 'Expert in IT Architecture' \e[0m"
if [ $bachelor_validated -eq "1" ] && [ $master_option_validated -eq "1" ]; then
	printf "=> \e[32mVALIDATED\e[0m (if you are level 21 and have attended 15 events) \n"
else
	printf "=> \e[31mFAILED\e[0m\n"
fi

printf "\n\e[2mFor master you need to be present at 15 informative events. If you do not know how to see your attended events. In this mobile app (https://github.com/artainmo/swifty-companion) a listing of attended events is displayed.\e[0m\n\n"
