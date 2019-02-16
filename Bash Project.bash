#! /usr/bin/bash
while [ 1 ]
do
echo ""
echo ""
echo "1) Create a New Database"
echo "2) Use an Existing Database"
echo "3) Delete an Existing Database"
echo "4) Exit"
read choice
clear
case $choice in
	1)echo "Enter your New Database Name"
	  read name
	  echo "Creating a New Database...."
      	  sleep 2
	  mkdir ${name}.db
	  sleep 2
	  echo "Created Successfully!"
	;;
	2)n=1
	 ls -d *.db/ | sed 's/.$//' > db_names
	 sed -i '/^$/d' db_names
	 for i in `cat db_names`; do
	 echo "Gathering Info...."
	 sleep 1
	 echo "Gathering Info........."
	 sleep 1
	 echo "Gathering Info.............."
	 sleep 1
	 echo "$n)$i"
	 sleep 1 
	 ((n=n+1))
	 done
	 sleep 1 
	 echo "Gathering Done!"
	 echo ""
	 sleep 1
	 echo "Enter Your Database Number"
	 read number
	 limit="$(wc -l db_names)"
	 if ( [ "$number" -gt "$limit" ] ) 2>/dev/null
	 then
	 	echo "Invalid Selection"
	 	sleep 1
	 	echo ""
	 	echo "Enter a valid selection"
	 else
	 	cd `awk "NR==$number" db_names`
	 	echo "******You are now connected!********"
	 fi
	 while [ 1 ]
	 do 
	 sleep 1
	 echo "Enter the number of your operation:"
	 sleep 1
	 echo ""
	 echo "1) View all tables"
	 echo "2) View a table"
	 echo "3) Create a new table"
	 echo "4) Delete an existing table"
	 echo "5) Insert a new row in a table"
	 echo "6) Update a row in a table"
	 echo "7) Delete a row in a table"
	 echo "8) Exit"
	 read operation_no
	 clear 
	 case $operation_no in 
		1)ls -I "*.datatype" > table.datatype
		  cat table.datatype
		;;
		2)echo "Enter the table name to view"
			read table_name
			cat $table_name
		;;
		3)echo "Enter the table name"
			read table_name
			touch $table_name
			touch ${table_name}.datatype
			echo "Enter the number of columns"
			read no_of_columns
			for i in $( eval echo {1..$no_of_columns});do
			echo "Enter the column name"
			read column
			echo "Enter the Datatype"
			echo ""
			echo "1) Number"
			echo "2) String"
			echo "3) Mixed"
			read dt
			case $dt in
				1)dt="Number"
				;;
				2)dt="String"
				;;
				3)dt="Mixed"
				;;
				*)echo "Invalid Selection"
				;;
			esac
				echo "$column|$dt" >> ${table_name}.datatype
				header[i]=$column
				
			done
				header="${header[@]}"
				echo ${header// /|} > $table_name
				clear
				echo "Table has been created successfully!"
		;;
		4)echo "Enter a table name to delete"
			ls -I "*.datatype" > table.datatype
			read table_name
			if grep -Fxq "$table_name" table.datatype
			then
			rm -f $table_name
			rm -f ${table_name}.datatype
			echo "Table deleted successfully"
			else
			echo "This table does not exist"
			sleep 1
			echo "*********Try again*********"
			fi
		;;
		5)echo "Enter the table name"
			ls -I "*.datatype" > table.datatype
			read table_name
			if grep -Fxq "$table_name" table.datatype
			then 
				hd=`head -1 $table_name`
				h=1
				IFS='|'
				for i in $hd; do
					echo "Enter the value of $i"
					read value
					dt=`grep $i ${table_name}.datatype | cut -d '|' -f 2`
					if [ $dt = "Number" ] && [ -z $(echo $value | sed -e 's/[0-9]//g') ]
					then 
						insert[$h]=$value
						sed '1d' $table_name | cut -d '|' -f 1 > primary.datatype;
						if grep -Fxq $value primary.datatype && [ $h = 1 ]
						then
							echo "You are violating a primary key contraint"
							sleep 1
							echo "********Try again*********"
							sleep 1
							((h=h-1))
							break
						fi
					elif [ $dt = "String" ] && [ -z $(echo $value | sed -e 's/[a-Z]//g') ]
					then 
						insert[$h]=$value
					elif [ $dt = "Mixed" ] && [ -z $(echo $value | sed -e 's/[a-Z0-9]//g') ]
					then 
						insert[$h]=$value
					else
						echo "Invalid Datatype"
						sleep 1
						echo "*****Try again*****"
						sleep 1
						((h=h-1))
						break
					fi
					((h=h+1))
				done
					((ch=$h-1))
					if [ ${#insert[@]} == $ch ]
					then
					echo ${insert[*]} | sed -e "s/ /|/g" >> $table_name
					clear
					echo "The record has been added successfully!"
					fi
			else 
				echo "The table you entered does not exist"
			fi
		;;
		6)echo "Enter the table name you want to update"
		  ls -I "*.datatype" > table.datatype
		  read table_name
		  if grep -Fxq "$table_name" table.datatype
		  then
		  echo "Enter the ID of the record you want to update"
		  read primary_key
		  search=` grep -c -i "$primary_key" $table_name `
		  if [ $search -eq 0 ]
		  then
          	  echo " This row does not exist! "
		  sleep 1
	  	  echo "********Try again*******"
          	  else
			echo "Enter the values of the new record "
				hd=`head -1 $table_name`
				h=1
				IFS='|'
				for i in $hd; do
					echo "Enter the value of $i"
					read value
					dt=`grep $i ${table_name}.datatype | cut -d '|' -f 2`
					if [ $dt = "Number" ] && [ -z $(echo $value | sed -e 's/[0-9]//g') ]
					then 
						insert[$h]=$value
					elif [ $dt = "String" ] && [ -z $(echo $value | sed -e 's/[a-Z]//g') ]
					then 
						insert[$h]=$value
					elif [ $dt = "Mixed" ] && [ -z $(echo $value | sed -e 's/[a-Z0-9]//g') ]
					then 
						insert[$h]=$value
					else
						echo "Invalid Datatype"
						sleep 1
						echo "*****Try again*****"
						sleep 1
						((h=h-1))
						break
					fi
					((h=h+1))
				done
					((ch=$h-1))
					if [ ${#insert[@]} == $ch ]
					then
					  grep -vwE "($primary_key)" $table_name > temp.datatype
					  cat temp.datatype > $table_name
					echo ${insert[*]} | sed -e "s/ /|/g" >> $table_name
					clear
					echo "The record has been updated successfully!"
					fi

		  fi
		  else
					echo "This table does not exist"
					sleep 1
					echo "*******Try again********"
			fi
			;;
		7)echo "Enter the table name you want to delete from"
		  ls -I "*.datatype" > table.datatype
		  read table_name
		  if grep -Fxq "$table_name" table.datatype
		  then
		  echo "Enter a row ID to delete "
          	  read primary_key
          	  search=` grep -c -i "$primary_key" $table_name `
          	  if [ $search -eq 0 ]
          	  then
          	  echo "This row does not exist"
		  sleep 1
		  echo "*********Try again**********"
          	  else
          	  grep -v "$primary_key" $table_name > temp.datatype
          	  mv temp.datatype $table_name
          	  echo "The data has been deleted "
          	  fi
		  else 
		  echo "The table does not exist"
		  sleep 1
		  echo "*******Try again********"
		  fi
		;;
		8)exit
		;;
		*)echo "Invalid Selection"
	esac
	  done
	;;
	3)echo "Enter the Database name"
		read db_name
	 	ls -d *.db/ | sed 's/.$//' > db_names
	 	sed -i '/^$/d' db_names
		if grep -Fxq ${db_name}.db db_names;
			then
			echo "********Warning********"
			echo "The delete action cannot be reversed"
			sleep 1
			echo ""
			echo "**Are you want to proceed?**"
			echo "1) Yes"
			echo "2) No"
		read choice 
		case $choice in 
			1)echo "Deleting........"
				rm -rf ${db_name}.db
			 	sleep 1
				echo "Database deleted sucessfully"
			;;
			2)echo "**Action not confirmed**"
	
			;;
			*)echo "Invalid Selection"
			;;
		esac
			else 
			echo "This Database doesnot exist"
			echo "***Check your choice and try again***"
		fi
	;;
	4)exit
	;;
	*)echo "Invalid Choice"
          echo "*****************"
	  echo ""
	  sleep 2
	  echo "Try to choose again!"
esac
done