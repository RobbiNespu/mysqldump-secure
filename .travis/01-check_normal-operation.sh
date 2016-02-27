#!/bin/bash

ERROR=0


txtgrn=$(tput setaf 2) # Green
txtylw=$(tput setaf 3) # Yellow
txtblu=$(tput setaf 4) # Blue
txtpur=$(tput setaf 5) # Purple
txtcyn=$(tput setaf 6) # Cyan
txtwht=$(tput setaf 7) # White
txtrst=$(tput sgr0) # Text reset.

#
# @param  string  PASS|FAIL what is expected?
# @param  string  Command
# @return integer 0:OK | 1:FAI:
run_test() {
	mod="${1}"
	cmd="${@:2}"

	echo "${txtblu}--> Run test:${txtrst}"
	echo "\$ ${txtblu}${cmd}${txtrst}"
	eval "${cmd}"
	exit="$?"

	# Test must succeed
	if [ "${mod}" = "PASS" ]; then

		if [ "${exit}" != "0" ]; then
			echo "${txtpur}===> [FAIL]${txtrst}"
			echo "${txtpur}===> [FAIL] Unexpected exit code: ${exit}${txtrst}"
			echo "${txtpur}===> [FAIL]${txtrst}"
			echo
			return 1
		else
			echo "${txtgrn}===> [OK]${txtrst}"
			echo "${txtgrn}===> [OK] Success${txtrst}"
			echo "${txtgrn}===> [OK]${txtrst}"
			echo
		echo
			return 0
		fi

	# Test must fail
	elif [ "${mod}" = "FAIL" ]; then

		if [ "${exit}" = "0" ]; then
			echo "${txtpur}===> [FAIL]${txtrst}"
			echo "${txtpur}===> [FAIL] Unexpected OK${txtrst}"
			echo "${txtpur}===> [FAIL]${txtrst}"
			echo
			return 1
		else
			echo "${txtgrn}===> [OK]${txtrst}"
			echo "${txtgrn}===> [OK] Expected Error. Exit code: ${exit}${txtrst}"
			echo "${txtgrn}===> [OK]${txtrst}"
			echo
		echo
			return 0
		fi

	# Something went wrong
	else

		echo "${txtpur}===> [FAIL]${txtrst}"
		echo "${txtgrn}===> [FAIL] Invalid usage of 'run_test'${txtrst}"
		echo "${txtpur}===> [FAIL]${txtrst}"
		return 1

	fi

}

#
## Test against unset variables
# @param  string  Command
# @return integer 0:OK | 1:FAI:
var_test() {
	cmd="$@"

	echo "${txtblu}--> Unbound variable test:${txtrst}"
	echo "\$ ${txtblu}${cmd} | grep 'parameter not set'${txtrst}"
	unbound="$(eval "${cmd} 3>&2 2>&1 1>&3 > /dev/null | grep 'parameter not set'")"

	if [ "${unbound}" != "" ]; then
		echo "${txtpur}===> [FAIL]${txtrst}"
		echo "${txtpur}===> [FAIL] Unbound variable found.${txtrst}"
		echo "${txtpur}===> [FAIL]${txtrst}"
		echo "${txtpur}${unbound}${txtrst}"
		echo
		return 1
	else
		echo "${txtgrn}===> [OK]${txtrst}"
		echo "${txtgrn}===> [OK] No Unbound variables found.${txtrst}"
		echo "${txtgrn}===> [OK]${txtrst}"
		echo
		return 0
	fi
}

#
## Test against syntax errors
# @param  string  Command
# @return integer 0:OK | 1:FAI:
syn_test() {
	cmd="$@"

	echo "${txtblu}--> Syntax error test:${txtrst}"
	echo "\$ ${txtblu}${cmd} | grep -E '.*[0-9]*:.*: not found.*'${txtrst}"
	syntax="$(eval "${cmd} 3>&2 2>&1 1>&3 > /dev/null | grep -E '.*[0-9]*:.*: not found.*'")"

	if [ "${syntax}" != "" ]; then
		echo "${txtpur}===> [FAIL]${txtrst}"
		echo "${txtpur}===> [FAIL] Syntax error found.${txtrst}"
		echo "${txtpur}===> [FAIL]${txtrst}"
		echo "${txtpur}${syntax}${txtrst}"
		echo
		return 1
	else
		echo "${txtgrn}===> [OK]${txtrst}"
		echo "${txtgrn}===> [OK] No Syntax error found.${txtrst}"
		echo "${txtgrn}===> [OK]${txtrst}"
		echo
		return 0
	fi
}





echo "##########################################################################################"
echo "#"
echo "#  1.  C H E C K I N G   N O R M A L   O P E R A T I O N"
echo "#"
echo "##########################################################################################"


echo
echo
echo "--------------------------------------------------------------------------------"
echo "-"
echo "-  1.1 Test mode"
echo "-"
echo "--------------------------------------------------------------------------------"

echo
echo "----------------------------------------"
echo " 1.1.1 Test mode first run"
echo "----------------------------------------"
echo "\$ mysqldump-secure --test --verbose"
sudo mysqldump-secure --test --verbose && echo "${txtgrn}===> [OK] Success${txtrst}" || { echo "${txtpur}===> [FAIL] Unexpected exit code: $?${txtrst}"; ERROR=1; }



echo
echo "----------------------------------------"
echo " 1.1.2 Test mode second run"
echo "----------------------------------------"
echo "\$ mysqldump-secure --test --verbose"
sudo mysqldump-secure --test --verbose && echo "${txtgrn}===> [OK] Success${txtrst}" || { echo "${txtpur}===> [FAIL] Unexpected exit code: $?${txtrst}"; ERROR=1; }


echo
echo "----------------------------------------"
echo " 1.1.3 Test mode Variable test"
echo "----------------------------------------"
echo "Unbound variable test"
unbound="$(sudo mysqldump-secure --test --verbose 3>&2 2>&1 1>&3 > /dev/null | grep 'unbound variable')"
if [ "${unbound}" != "" ]; then echo "${txtpur}===> [FAIL] Unbound variable found.${txtrst}";  echo "${txtpur}${unbound}${txtrst}"; ERROR=1; else  echo "${txtgrn}===> [OK] No Unbound variables found.${txtrst}"; fi




echo
echo
echo "--------------------------------------------------------------------------------"
echo "-"
echo "-  1.2 Normal mode"
echo "-"
echo "--------------------------------------------------------------------------------"

echo
echo "----------------------------------------"
echo " 1.2.1 Normal mode first run"
echo "----------------------------------------"
sudo rm /var/log/mysqldump-secure.log 2>/dev/null
sudo rm /var/log/mysqldump-secure.nagios.log 2>/dev/null
sudo rm -rf /var/mysqldump-secure/ 2>/dev/null
echo "\$ mysqldump-secure --verbose"
sudo mysqldump-secure --verbose && echo "${txtgrn}===> [OK] Success${txtrst}" || { echo "${txtpur}===> [FAIL] Unexpected exit code: $?${txtrst}"; ERROR=1; }

echo
echo "----------------------------------------"
echo " 1.2.2 Normal mode second run"
echo "----------------------------------------"
sudo rm -rf /var/mysqldump-secure/ && sudo mkdir -p /var/mysqldump-secure/ && sudo chmod 0700 /var/mysqldump-secure/
echo "\$ mysqldump-secure --verbose"
sudo mysqldump-secure --verbose && echo "${txtgrn}===> [OK] Success${txtrst}" || { echo "${txtpur}===> [FAIL] Unexpected exit code: $?${txtrst}"; ERROR=1; }

echo
echo "----------------------------------------"
echo " 1.2.3 Normal mode third run (del files)"
echo "----------------------------------------"
sudo rm -rf /var/mysqldump-secure/ && sudo mkdir -p /var/mysqldump-secure/ && sudo chmod 0700 /var/mysqldump-secure/
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-1.txt
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-2.txt
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-3.txt
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-4.txt
echo "\$ mysqldump-secure --verbose"
sudo mysqldump-secure --verbose && echo "${txtgrn}===> [OK] Success${txtrst}" || { echo "${txtpur}===> [FAIL] Unexpected exit code: $?${txtrst}"; ERROR=1; }

echo
echo "----------------------------------------"
echo " 1.2.4 Normal mode unbound variable test"
echo "----------------------------------------"
echo "Unbound variable test"
sudo rm -rf /var/mysqldump-secure/ && sudo mkdir -p /var/mysqldump-secure/ && sudo chmod 0700 /var/mysqldump-secure/
unbound="$(sudo mysqldump-secure --verbose 3>&2 2>&1 1>&3 > /dev/null | grep 'unbound variable')"
if [ "${unbound}" != "" ]; then echo "${txtpur}===> [FAIL] Unbound variable found.${txtrst}";  echo "${txtpur}${unbound}${txtrst}"; ERROR=1; else  echo "${txtgrn}===> [OK] No Unbound variables found.${txtrst}"; fi


echo
echo "----------------------------------------"
echo " 1.2.4 Normal mode (del files) unbound variable test"
echo "----------------------------------------"
echo "Unbound variable test"
sudo rm -rf /var/mysqldump-secure/ && sudo mkdir -p /var/mysqldump-secure/ && sudo chmod 0700 /var/mysqldump-secure/
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-1.txt
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-2.txt
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-3.txt
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-4.txt
unbound="$(sudo mysqldump-secure --verbose 3>&2 2>&1 1>&3 > /dev/null | grep 'unbound variable')"
if [ "${unbound}" != "" ]; then echo "${txtpur}===> [FAIL] Unbound variable found.${txtrst}";  echo "${txtpur}${unbound}${txtrst}"; ERROR=1; else  echo "${txtgrn}===> [OK] No Unbound variables found.${txtrst}"; fi





echo
echo
echo "--------------------------------------------------------------------------------"
echo "-"
echo "-  1.3 Cron mode (--cron)"
echo "-"
echo "--------------------------------------------------------------------------------"

echo
echo "----------------------------------------"
echo " 1.3.1 Cron mode first run"
echo "----------------------------------------"
sudo rm /var/log/mysqldump-secure.log 2>/dev/null
sudo rm /var/log/mysqldump-secure.nagios.log 2>/dev/null
sudo rm -rf /var/mysqldump-secure/ 2>/dev/null
echo "\$ mysqldump-secure --cron"
sudo mysqldump-secure --cron && echo "${txtgrn}===> [OK] Success${txtrst}" || { echo "${txtpur}===> [FAIL] Unexpected exit code: $?${txtrst}"; ERROR=1; }

echo
echo "----------------------------------------"
echo " 1.3.2 Cron mode second run"
echo "----------------------------------------"
sudo rm -rf /var/mysqldump-secure/ && sudo mkdir -p /var/mysqldump-secure/ && sudo chmod 0700 /var/mysqldump-secure/
echo "\$ mysqldump-secure --cron"
sudo mysqldump-secure --cron && echo "${txtgrn}===> [OK] Success${txtrst}" || { echo "${txtpur}===> [FAIL] Unexpected exit code: $?${txtrst}"; ERROR=1; }

echo
echo "----------------------------------------"
echo " 1.3.3 Cron mode third run (del files)"
echo "----------------------------------------"
sudo rm -rf /var/mysqldump-secure/ && sudo mkdir -p /var/mysqldump-secure/ && sudo chmod 0700 /var/mysqldump-secure/
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-1.txt
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-2.txt
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-3.txt
sudo touch -a -m -t 201512180130.09 /var/mysqldump-secure/delete-me-4.txt
echo "\$ mysqldump-secure --cron"
sudo mysqldump-secure --cron && echo "${txtgrn}===> [OK] Success${txtrst}" || { echo "${txtpur}===> [FAIL] Unexpected exit code: $?${txtrst}"; ERROR=1; }

echo
echo "----------------------------------------"
echo " 1.3.4 Cron mode variable test"
echo "----------------------------------------"
echo
echo "Unbound variable test"
unbound="$(sudo mysqldump-secure --cron 3>&2 2>&1 1>&3 > /dev/null | grep 'unbound variable')"
if [ "${unbound}" != "" ]; then echo "${txtpur}===> [FAIL] Unbound variable found.${txtrst}";  echo "${txtpur}${unbound}${txtrst}"; ERROR=1; else  echo "${txtgrn}===> [OK] No Unbound variables found.${txtrst}"; fi





echo
echo
echo "--------------------------------------------------------------------------------"
echo "-"
echo "-  1.4 cmd arguments"
echo "-"
echo "--------------------------------------------------------------------------------"

echo
echo "----------------------------------------"
echo " 1.4.1 --help"
echo "----------------------------------------"
CMD="sudo mysqldump-secure --help"
if ! run_test "PASS" "${CMD}"; then ERROR=1; fi
if ! var_test "${CMD}"; then ERROR=1; fi
if ! syn_test "${CMD}"; then ERROR=1; fi


echo
echo "----------------------------------------"
echo " 1.4.2 --conf (does not exist)"
echo "----------------------------------------"
CMD="sudo mysqldump-secure --verbose --conf=/etc/nothere"
if ! run_test "FAIL" "${CMD}"; then ERROR=1; fi
if ! var_test "${CMD}"; then ERROR=1; fi
if ! syn_test "${CMD}"; then ERROR=1; fi


echo
echo "----------------------------------------"
echo " 1.4.3 --conf (random file)"
echo "----------------------------------------"
CMD="sudo mysqldump-secure --verbose --conf=/etc/mysqldump-secure.cnf"
if ! run_test "FAIL" "${CMD}"; then ERROR=1; fi
if ! var_test "${CMD}"; then ERROR=1; fi
if ! syn_test "${CMD}"; then ERROR=1; fi


echo
echo "----------------------------------------"
echo " 1.4.4 wrong argument"
echo "----------------------------------------"
CMD="sudo mysqldump-secure --wrong"
if ! run_test "FAIL" "${CMD}"; then ERROR=1; fi
if ! var_test "${CMD}"; then ERROR=1; fi
if ! syn_test "${CMD}"; then ERROR=1; fi






echo
echo
if [ "$ERROR" = "0" ]; then
	echo "${txtgrn}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${txtrst}"
	echo "${txtgrn}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ [01] SUCESS   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${txtrst}"
	echo "${txtgrn}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${txtrst}"
else
	echo "${txtpur}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${txtrst}"
	echo "${txtpur}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  [01] FAILED   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${txtrst}"
	echo "${txtpur}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${txtrst}"
fi
exit $ERROR
