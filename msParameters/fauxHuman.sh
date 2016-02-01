#!/usr/bin/bash
#This script is the main workhorse for simulating data, running PSMC and then extracting it for use. Change the simulationName and the msHOT-lite line if you want to run a new population demographic
simulationName='fauxHuman'

#timeInterval is a PSMC input parameter about how time should be considered in the program. '10*1' means split time up into 10 lengths of 1, '2*5+1*10' would mean have 2 lengths of 5 and 1 length of 10.
for timeInterval in '10*1' '20*1' '30*1' '40*1'
do
	#bpLength is how many base pairs should be simulated
	for bpLength in '100000' '500000' '1000000' '5000000' '10000000' '20000000'
	do			
		#the first bit of this script generates the simulated data and runs psmc on the initial run
		oldStringName=$simulationName'Bp'$bpLength'Int'$timeInterval'Split1'
		echo $oldStringName'start'
		~/Documents/SummerScholarship/foreign-master/msHOT-lite/msHOT-lite 2 1 -t 65130 -r 10973 $bpLength -eN 0.0055 0.0832 -eN 0.0089 0.0489 -eN 0.0130 0.0607 -eN 0.0177 0.1072 -eN 0.0233 0.2093 -eN 0.0299 0.3630 -eN 0.0375 0.5041 -eN 0.0465 0.5870 -eN 0.0571 0.6343 -eN 0.0695 0.6138 -eN 0.0840 0.5292 -eN 0.1010 0.4409 -eN 0.1210 0.3749 -eN 0.1444 0.3313 -eN 0.1718 0.3066 -eN 0.2040 0.2952 -eN 0.2418 0.2915 -eN 0.2860 0.2950 -eN 0.3379 0.3103 -eN 0.3988 0.3458 -eN 0.4701 0.4109 -eN 0.5538 0.5048 -eN 0.6520 0.5996 -eN 0.7671 0.6440 -eN 0.9020 0.6178 -eN 1.0603 0.5345 -eN 1.4635 1.7931 -l > $oldStringName'.ms'			
		perl ~/Documents/SummerScholarship/psmc-master/utils/ms2psmcfa.pl<$oldStringName'.ms'>$oldStringName'.psmcfa'
        ~/Documents/SummerScholarship/psmc-master/psmc -p $timeInterval $oldStringName'.psmcfa'>$oldStringName'.psmc'
		bash ~/Documents/SummerScholarship/myScripts/removeDataFromPSMC.sh $oldStringName'.psmc'>$oldStringName'.txt'
		msStringName=$oldStringName
		echo $oldStringName'end'
		
		#the split for loop splits the data up into smaller contigs and then runs the analysis
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
		
		#this second for loop just moves every simulation into it's own folder for convenience
		for split in '1' '2' '4' '8' '16' '32' '64' '128' '256' '512' '1024'
		do
			stringName=$simulationName'Bp'$bpLength'Int'$timeInterval'Split'$split
			mkdir $stringName
			mv $stringName'.psmc' $stringName'.psmcfa' $stringName'.txt' $stringName
		done
	done
done