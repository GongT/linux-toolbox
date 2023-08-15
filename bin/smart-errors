#!/bin/bash

for D in /dev/sd* ; do
	echo -e "\e[48;5;10m[DISK] $D\e[0m"
	SMART=$(smartctl -a "$D")
	
	if ! [[ "$SMART" ]]; then
		echo -e "\e[38;5;11m\tNo S.M.A.R.T info\e[0m\n"
		continue
	fi

	CPS=$(echo "$SMART" | grep "Current_Pending_Sector" | awk '{print $NF}')
	if [[ "$CPS" -gt 0 ]]; then
		echo -e "\e[5;38;5;9mCurrent_Pending_Sector = $CPS\e[0m"
	else
		echo "Current_Pending_Sector = $CPS"
	fi

	echo
done

