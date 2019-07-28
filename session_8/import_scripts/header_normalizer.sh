#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: ./normalizer.sh <registration_data_file> <survey_data_file>"
    exit
fi

registration_header="Course Title	Course Code	Event Description	Business Type	Delivery Type	Offering ID	Start Date	End Date	Month	Week	Duration	Offering Status	Offering Language	Offering Region	Offering Province	Offering City	Instructor Name	Client	Reg ID	Scope	Reg Status	No Show	Reg Date	Reg Gap	Learner ID	Learner Region	Learner Province	Learner City	Learner Classif Group	Learner Classif	Billing Dept Code	Billing Dept Name"
survey_header="Course Code	Course Title	Offering ID	Offering Delivery Type	Offering Start Date	Offering Province	Offering City	Survey ID	Short Question	Survey Answer	Survey Respondent Classification	Survey Respondent Department"

case "$(uname -s)" in
	Darwin)
		gsed -i "1s/.*/$registration_header/" $1
		gsed -i '1s/[A-Z]/\L&/g;1s/[^\ta-z0-9]/_/g' $1

		gsed -i "1s/.*/$survey_header/" $2
		gsed -i '1s/[A-Z]/\L&/g;1s/[^\ta-z0-9]/_/g' $2
		;;

	*)
		sed -i "1s/.*/$registration_header/" $1
		sed -i '1s/[A-Z]/\L&/g;1s/[^\ta-z0-9]/_/g' $1

		sed -i "1s/.*/$survey_header/" $2
		sed -i '1s/[A-Z]/\L&/g;1s/[^\ta-z0-9]/_/g' $2
		;;

esac

