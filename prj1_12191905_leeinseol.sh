#! /bin/bash

if [ $# -ne 3 ] ; then
	echo "usage: $0 u.item u.data u.user"
	exit 1
fi

echo "--------------------------"
echo "User Name: leeinseol"
echo "Student Number: 12191905"
echo "[ MENU ]
1. Get the data of the movie identified by a specific 'movie id' from 'u.item'
2. Get the data of action genre movies from 'u.tiem'
3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'
4. Delete the 'IMDb URL' from 'u.item'
5. Get the data about users from 'u.user'
6. Modify the format of 'release data' in 'u.item'
7. Get the data of movies rated by a specific 'user id' from 'u.data'
8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'
9. Exit"
echo "--------------------------"


# change the line
# usage : new_line 
new_line() {
	echo -e "\n"
}

# check the right number for movie_id and user_id  
# usage : check_number information start_number end_number
check_number() {
	local result
	while true
	do
		read -p "$1" result
		new_line
		if [ "$result" -ge "$2" ] && [ "$result" -le "$3" ] 
		then break
		else echo -e "Please enter the number between $2 and $3\n"
		fi
	done
	return "$result"
}

# check the right answer for question answered with y/n 
# usage : check_answer information 
check_answer() {
	local answer 
	while true
	do
		read -p "$1" answer
		new_line
		if [ "$answer" == "y" ]; then return 0
		elif [ "$answer" == "n" ]; then return 1 
		else echo -e "Please enter 'y' or 'n' only \n"
		fi
	done
}

# command used in case 5 that change the gender format in u.user
# from M to male and from F to female 
# usage : change_gender_format u.user 
change_gender_format() { 
	sed -e 's/M/male/g' -e 's/F/female/g' < "$1"
}

# command used in case 5 that change the u.user data format
# usage : change_gender_format u.user | change_user_format  (no paramter)
change_user_format() { 
	sed -E 's/([0-9]+)\|([0-9]+)\|([a-z]+)\|([a-z]+)\|([0-9]+)/user \1 is \2 years old \3 \4/g'
}

# command used in case 6 that change the month format in u.item
# from string month to int month
# It use regular expression because String month can also be included in movie title
# usage : change_month u.item 
change_month() {	
	sed -E 's/(.*\|)(.*\|)(.*)(-Jan-)(.+)/\1\2\3-01-\5/g' < "$1" | 
	sed -E 's/(.*\|)(.*\|)(.*)(-Feb-)(.+)/\1\2\3-02-\5/g' |
	sed -E 's/(.*\|)(.*\|)(.*)(-Mar-)(.+)/\1\2\3-03-\5/g' |
	sed -E 's/(.*\|)(.*\|)(.*)(-Apr-)(.+)/\1\2\3-04-\5/g' |
	sed -E 's/(.*\|)(.*\|)(.*)(-May-)(.+)/\1\2\3-05-\5/g' |
	sed -E 's/(.*\|)(.*\|)(.*)(-Jun-)(.+)/\1\2\3-06-\5/g' |
	sed -E 's/(.*\|)(.*\|)(.*)(-Jul-)(.+)/\1\2\3-07-\5/g' |
	sed -E 's/(.*\|)(.*\|)(.*)(-Aug-)(.+)/\1\2\3-08-\5/g' |
	sed -E 's/(.*\|)(.*\|)(.*)(-Sep-)(.+)/\1\2\3-09-\5/g' |
	sed -E 's/(.*\|)(.*\|)(.*)(-Oct-)(.+)/\1\2\3-10-\5/g' |
	sed -E 's/(.*\|)(.*\|)(.*)(-Nov-)(.+)/\1\2\3-11-\5/g' |
	sed -E 's/(.*\|)(.*\|)(.*)(-Dec-)(.+)/\1\2\3-12-\5/g' 
}

# command used in case 7 that find movies rated by the user and sort ascending by movie_id
# this command print 1 column for movie id
# usage : find_movie_ids u.data user_id 
find_movie_ids() {
	awk -v user_id="$2" '$1==user_id {printf("%d\n", $2)}' "$1" | sort -n
}

# command used in case 8 that find 20s programmers user id
# this command print user id based whitespace 
# usage : get_20sProgrammer_ids u.user
get_20sProgrammer_ids() {
	awk -F\| '$4=="programmer" && $2>=20 && $2<=29 {printf("%d ", $1)}' "$1"
}

# command used in case 8 that find movie id rated by 20s programmers
# this command print movie id based '\n' and save the file
# usage : get_and_makefile_movie_id_rated_by_20sProgrammer u.data 20s_programmer_ids
get_and_makefile_movie_id_rated_by_20sProgrammer() {
	local movie_ids=""
	local file=""
	for user_id in $2
	do
		user_movie_id=$(awk -v id="$user_id" '$1==id {print $2}' "$1" )
		movie_ids=$(echo "$movie_ids"; echo "$user_movie_id")

		add_file=$(awk -v id="$user_id" '$1==id {print $2, $3}' "$1")
		file=$(echo "$file"; echo "$add_file")
	done
	
	echo "$file" > result

	movie_ids=$(echo "$movie_ids" | sort -n | uniq)
	echo "$movie_ids"
}

start_movie_id=1
end_movie_id=1682
start_user_id=1
end_user_id=943
stop="N"

until [ "$stop" == "Y" ]
do
	read -p "Enter your choice [ 1-9 ] " n
	new_line

	case $n in
	1)
		information="Please enter 'movie id' (1~1682) : "
		check_number "$information" $start_movie_id $end_movie_id
		movie_id=$?
		awk -F\| -v id=$movie_id '$1==id {print $0}' "$1"
		new_line
		;;	
	2) 
		information="Do you want to get the data of 'action' genre movies from 'u.item'?(y/n) : "
		if check_answer "$information"
		then
			awk -F\| '$7==1 {print $1, $2}' "$1" | head -n 10
			new_line
       	fi 
		;;
	3) 
		information="Please enter the 'movie id' (1~1682) : "
		check_number "$information" $start_movie_id $end_movie_id
		movie_id=$?
		awk -v id=$movie_id '$2==id { sum+=$3; count+=1 } 
		 END { if (count>0) 
	       	{printf("average rating of %d : %.5f\n", id, sum/count)} }' "$2" |
		 sed -E 's/\.?0*$//'
		new_line
		;;	
	4)
		information="Do you want to delete the 'IMDb URL' from 'u.item'?(y/n) : "
		if check_answer "$information"
		then
			sed -E 's/(http)+([^\|]*)\|/|/g' < "$1" | head -n 10	
			new_line
		fi
		;;
	5)
		information="Do you want to get the data about users from 'u.user'?(y/n) : "
		if check_answer "$information"
		then
			change_gender_format "$3" | change_user_format | head -n 10
			new_line
		fi
		;;
	6) 
		information="Do you want to Modify the format of 'release data' in 'u.item'?(y/n) : "
		if check_answer "$information"
		then
			change_month "$1" | sed -Ee 's/(.*)([0-9]{2})\-([0-9]{2})\-([0-9]{4})(.*)/\1\4\3\2\5/g' | tail -n 10
			new_line
		fi
		;;
	7)
		information="Please enter the 'user id'(1~942) : "
		check_number "$information" $start_user_id $end_user_id
		user_id=$?
		want_movie_ids=$(find_movie_ids "$2" "$user_id")
		
		echo "$want_movie_ids" | tr '\n' '|' | sed -E 's/\|$//g'
		new_line

		for i in $(seq 1 10)
		do
			want_id=$(echo "$want_movie_ids" | awk -v i="$i" 'NR==i {print $1}')
			awk -F\| -v want_id="$want_id" '$1==want_id {printf("%d|%s\n", $1, $2)}' "$1"
		done
		new_line
		;;
	8)
		information="Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 'occupation' as 'programmer'?(y/n) : "
		if check_answer "$information"
		then
			programmer_ids=$(get_20sProgrammer_ids "$3")
			movie_id_rated_by_20sProgrammer=$(get_and_makefile_movie_id_rated_by_20sProgrammer "$2" "$programmer_ids" )
		
			for movie_id in $movie_id_rated_by_20sProgrammer
			do
				awk -v id="$movie_id" '$1==id { sum+=$2; count+=1 }
			 	 END { if (count>0) printf("%d : %.5f\n", id, sum/count)}' result |
			 	 sed -E 's/\.?0*$//'
			done
			rm result
			new_line
		fi
		;;
	9)
		echo "Bye!"
		stop="Y"
		;;
	*)
		echo "Please enter the number between 1 and 9"
		new_line
		;;
	esac
done
