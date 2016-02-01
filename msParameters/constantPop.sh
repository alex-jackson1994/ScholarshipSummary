#!/usr/bin/bash

simulationName='constantPop'
for timeInterval in '10*1' '20*1' '30*1' '40*1'
do
	for bpLength in '100000' '500000' '1000000' '5000000' '10000000' '20000000'
	do			
		oldStringName=$simulationName'Bp'$bpLength'Int'$timeInterval'Split1'
		echo $oldStringName'start'
		~/Documents/SummerScholarship/foreign-master/msHOT-lite/msHOT-lite 2 1 -t 65130 -r 10973 $bpLength -l > $oldStringName'.ms'			
		perl ~/Documents/SummerScholarship/psmc-master/utils/ms2psmcfa.pl<$oldStringName'.ms'>$oldStringName'.psmcfa'
        ~/Documents/SummerScholarship/psmc-master/psmc -p $timeInterval $oldStringName'.psmcfa'>$oldStringName'.psmc'
		bash ~/Documents/SummerScholarship/myScripts/removeDataFromPSMC.sh $oldStringName'.psmc'>$oldStringName'.txt'
		msStringName=$oldStringName
		echo $oldStringName'end'
		for split in '2' '4' '8' '16' '32' '64' '128' '256' '512' '1024'
		do
			stringName=$simulationName'Bp'$bpLength'Int'$timeInterval'Split'$split
			echo $stringName'start'
			python ~/Documents/SummerScholarship/myScripts/binarySplitPsmcfaPrint.py $oldStringName'.psmcfa' > $stringName'.psmcfa'
        	~/Documents/SummerScholarship/psmc-master/psmc -p $timeInterval $stringName'.psmcfa'>$stringName'.psmc'
			bash ~/Documents/SummerScholarship/myScripts/removeDataFromPSMC.sh $stringName'.psmc'>$stringName'.txt'
			oldStringName=$stringName
			echo $stringName'end'
		done
		for split in '1' '2' '4' '8' '16' '32' '64' '128' '256' '512' '1024'
		do
			stringName=$simulationName'Bp'$bpLength'Int'$timeInterval'Split'$split
			mkdir $stringName
			mv $stringName'.psmc' $stringName'.psmcfa' $stringName'.txt' $stringName
		done
	done
done
mkdir $simulationName
mv $simulationName* *.ms $simulationName
7z a $simulationName