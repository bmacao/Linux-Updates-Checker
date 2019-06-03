#!/bin/bash

apt-get update

#Get distro list update packages
fghw="$(apt-get -s upgrade | grep Inst )"
printf "$fghw" > $hostname"_libup.json"

#Get distro list CVE of instaled distro packages - depends of installed package debsacan
debsecan

## UPDATES PARSER

#Empty end files & remove empty lines
echo "" > $hostname"_up.txt"
sed -i '/^$/d' $hostname"_up.txt"

if [ -s $hostname"_libup.txt" ]
then
#Process update file
	while read p; 
	do
		stringarray=($p)

		#Remove special char [,],(
		aux=${stringarray[2]}
		xua=${stringarray[3]}

		Vers=${aux#?}
		Vers=${Vers%?}

		Upvers=${xua#?}
		#End remove special char

		echo ${stringarray[1]}";"$Vers";"$Upvers";1" >> $hostname"_up.txt"


	done < test_libup.txt

else
	#File is empty, no updates available
	echo "0" >> $hostname"_libup.txt"
fi

## END UPDATES PARSER

## CVE PARSER

#Empty end files & remove empty lines
echo "" > $hostname"_cve.json"
sed -i '/^$/d' $hostname"_cve.json"

json_init='['
json_middle=''

#Create dictionary/hashtable
declare -A CVE_List

if [ -s $hostname"_cveup.txt" ]
then
#Process CVE file
	while read -r o; 
	do
		newstringarray=($o)
		#Get all vars from line, CVE - PACKAGE - Exploit Type - SEVERITY
		zua=${newstringarray[2]}
		uza=${newstringarray[3]}
		auz=${newstringarray[4]}
		uaz=${newstringarray[5]}
		
		#Remove special char [,],(
		grt=${zua#?}
		pqw=${uza%?}
		ndh=${uaz%?}
		ndh=${ndh%?}
		#End remove special char

		#Process each line, if exists key/package update key list else create entry for package
		if [[ -v CVE_List[${newstringarray[1]}] ]]; then

			oldval="${CVE_List[${newstringarray[1]}]}"
			kgds=${newstringarray[0]}","$grt" "$pqw","$auz" "$ndh
			
			CVE_List[${newstringarray[1]}]=$oldval";"$kgds
			#echo "${CVE_List[${newstringarray[1]}]}"
		else
			
			opedg=${newstringarray[0]}","$grt" "$pqw","$auz" "$ndh
			CVE_List[${newstringarray[1]}]=$opedg
		fi

	done < $hostname"_cveup.txt"
#END process CVE file

#Start JSON creation process
json_init='['
json_middle=''

#Iterate all key and process its values for JSON file
for i in ${!CVE_List[@]}
do

gfjsf="$(apt-get -V -s install $i | grep -m1 $i)"
olvf="${CVE_List[$i]}"

echo "$i"
echo "${CVE_List[$i]}"
echo "$gfjsf"

json_middle+='{"Lib":"'$i'","data":[{"CVE":"'$olvf'","LibUp":"'$gfjsf'"}]},'

done

lghh=${json_middle%?}

json_end=$json_init$lghh']'


printf "$json_end" > $hostname"_cve.json"
#END JSON creation process

else
	#File is empty, no CVE 
	json_init='['
    json_middle=''
    json_middle+='{"Lib": ,"data":[{"CVE": ,"LibUp": "}]},'
    
	kfvgs=${json_middle%?}
		
	json_end=$json_init$kfvgs']'
	
	printf "$json_end" > $hostname"_cve.json"
fi

