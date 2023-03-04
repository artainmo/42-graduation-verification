read -p 'Do you already have a 42 API for us to use? (y/n): ' input
if [ $input = 'y' ]; then
	open 'https://profile.intra.42.fr/oauth/applications'
	sleep 5
else
	printf " We will redirect you to create an API app for us to access your information safely.\n"
	printf "  App Name: 42-graduation-verification\n"
	printf "  App Redirect URI: https://profile.intra.42.fr\n"
	printf "  All the rest can be left as it is.\n"
	for i in {10..0}; do
    	 printf " In: \033[0;31m%d\033[0m \r" $i #An empty space must sit before \r else prior longer string end will be displayed
  		sleep 1
	done
	printf '\n'
	open "https://profile.intra.42.fr/oauth/applications/new"
	sleep 20
fi

printf "Give us the following information of your 42 API app: \n"
printf "  UID: "
read CLIENT_ID
printf "  SECRET: "
read CLIENT_SECRET

ACCESS_TOKEN=$(curl -sX POST --data "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET" https://api.intra.42.fr/oauth/token | jq .access_token | tr -d '"')

if [ $ACCESS_TOKEN = null ]; then
	echo "Error: You gave invalid API app credentials"
else
	echo "API app access SUCCESS"
	echo "ACCESS_TOKEN: $ACCESS_TOKEN"
fi

clear
read -p 'Login: ' LOGIN

./scripts/graduation_verification.sh $ACCESS_TOKEN $LOGIN
