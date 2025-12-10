#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#Find where the end of frequency line should be
natom=$(grep NAtoms $1 |head -1 |awk '{print $2}')
freqline=$(expr $natom + 7)

#Check for imaginary frequencies
if grep -qE 'N\s{0,2}I\s{0,2}m\s{0,2}a\s{0,2}g\s{0,2}\=\s{0,2}1' $1
then
	mkdir firctemp
	cp $1 ./firctemp/
	cd ./firctemp

	#The fun part make imaginary frequency +-xyz
	sed -ne '/normal coordinates:/,+'"$freqline"'p' $1 > tempfastirc.dat
	imfreq=$(awk 'NR==4{print $3}' tempfastirc.dat)
	echo $imfreq > imfreq.dat
	sed -i 1,8d tempfastirc.dat
	awk '{print substr($0, index($0, $3))}' tempfastirc.dat | awk '{print $1, $2, $3}' > imfreq.dat
	rm tempfastirc.dat

	#make xyz from log
	cat $1 | sed -n -E '/\\GINC/,/V\s{0,2}e\s{0,2}r\s{0,2}s\s{0,2}i\s{0,2}o\s{0,2}n/p' | tr -d '[:space:]' | sed 's/\\/\n/g' | sed '1,16d' | head --lines=$natom | awk -F, 'BEGIN{ OFS="\t" } { $1=$1; print }' > firc-coords.xyz
	
	# extract atom index since we will be using the coordinate to do some arithmetic
	awk '{print $1}' firc-coords.xyz > atomindex.dat
	# extract x y and z coordinate
	awk '{print $2}' firc-coords.xyz > xcoords.dat
	awk '{print $3}' firc-coords.xyz > ycoords.dat
	awk '{print $4}' firc-coords.xyz > zcoords.dat
	#extract x y and z freq
	awk '{print $1}' imfreq.dat > xfreq.dat
	awk '{print $2}' imfreq.dat > yfreq.dat
	awk '{print $3}' imfreq.dat > zfreq.dat

	#append coord to freq, space will not work but , will work in the next step idk why
	paste -d"," <(cat xcoords.dat) <(cat xfreq.dat) > xappend.csv
	paste -d"," <(cat ycoords.dat) <(cat yfreq.dat) > yappend.csv
	paste -d"," <(cat zcoords.dat) <(cat zfreq.dat) > zappend.csv

	#add numbers together
	echo | awk -F, -v OFS=',' '{$3=$1+$2}1' xappend.csv | sed -e "s/,/ /g" | awk '{print $3}' > xforward.dat 
	echo | awk -F, -v OFS=',' '{$3=$1+$2}1' yappend.csv | sed -e "s/,/ /g" | awk '{print $3}' > yforward.dat 
	echo | awk -F, -v OFS=',' '{$3=$1+$2}1' zappend.csv | sed -e "s/,/ /g" | awk '{print $3}' > zforward.dat 
	
	echo | awk -F, -v OFS=',' '{$3=$1-$2}1' xappend.csv | sed -e "s/,/ /g" | awk '{print $3}' > xreverse.dat 
	echo | awk -F, -v OFS=',' '{$3=$1-$2}1' yappend.csv | sed -e "s/,/ /g" | awk '{print $3}' > yreverse.dat 
	echo | awk -F, -v OFS=',' '{$3=$1-$2}1' zappend.csv | sed -e "s/,/ /g" | awk '{print $3}' > zreverse.dat 
	#Ideally i want to use space but arithmetic function somehow break if OFS=" "

	#append xyz to make reverse and forward.xyz
	paste -d" " <(cat atomindex.dat) <(cat xforward.dat) <(cat yforward.dat) <(cat zforward.dat) > firc_forward.xyz
	paste -d" " <(cat atomindex.dat) <(cat xreverse.dat) <(cat yreverse.dat) <(cat zreverse.dat) > firc_reverse.xyz

	cd ..
	mkdir firc_inp
	echo "%chk=firc_forward.chk" > ./firc_inp/firc_forward.inp
	sed -n '3,10p' $SCRIPT_DIR/firc_optinp.txt >> ./firc_inp/firc_forward.inp
	cat ./firctemp/firc_forward.xyz >> ./firc_inp/firc_forward.inp
	echo " " >> ./firc_inp/firc_forward.inp
	
	echo "%chk=firc_reverse.chk" > ./firc_inp/firc_reverse.inp
	sed -n '3,10p' $SCRIPT_DIR/firc_optinp.txt >> ./firc_inp/firc_reverse.inp
	cat ./firctemp/firc_reverse.xyz >> ./firc_inp/firc_reverse.inp
	echo " " >> ./firc_inp/firc_reverse.inp

	rm -r ./firctemp
	echo "The first frequency is chosen at $imfreq cm**-1"
else
	echo "Imaginary frequency not found or multiple exist, exiting..."
fi


