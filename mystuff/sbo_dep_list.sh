#!/bin/sh
#
# (c) LEVAI Daniel <leva@ecentrum.hu>
#
# Version: 2

#set -e


typeset -i DEBUG=0
typeset -i CHECK_INSTALLED=0
while getopts id opt;do
	case ${opt} in
	i)
		CHECK_INSTALLED=1
	;;
	d)
		DEBUG=1
	;;
	\?)
		echo "Usage:"
		echo "$0 [-i] [-d]"
		echo "	-i : Check for every dependency package, if it is installed on the system."
		echo "	-d : Show debug messages."
		exit 1
	;;
	esac
done
shift $(($OPTIND - 1))

if [ -z "$1" ];then
	echo "$0 <path to package source directory>"
	exit 1
fi

typeset -i DEPTH=0
typeset -i i=0
typeset -i FOUND=0
REQUIRES=''

REPO_TAG='_SBo'
PACKAGE_INFORMATION=/var/packages/packages 


_INSTALLED_PKGS=$( find "${PACKAGE_INFORMATION}" -type f -name "*${REPO_TAG}" -printf "%f " )
# extract only the package name
for pkg in ${_INSTALLED_PKGS};do
	pkg=$( echo "${pkg}" |sed -e"s,^\(.*\)-\([^-]\+\)-[^-]\+-\([0-9]\)\+${REPO_TAG}$,\1," )
	INSTALLED_PKGS=$INSTALLED_PKGS" ${pkg##*/}"
done
unset _INSTALLED_PKGS

PKGS_INIT=$(find /usr/slackbuilds/git/ -type d -mindepth 2 -maxdepth 2 ! -name '.git' ! -path '*/.git/*')
#PKGS_INIT="${PKGS_INIT}
#$(find /usr/slackbuilds/mystuff/ -type d -mindepth 2 -maxdepth 2 ! -name '.git' ! -path '*/.git/*')"

get_requires()
{
	DEPTH=$(( DEPTH + 1 ))
	[ ${DEBUG} -gt 1 ]  &&  echo "get_requires(): DEPTH='${DEPTH}'"

	[ ${DEBUG} -gt 0 ]  &&  echo "get_requires(): pkg_name=$1"

	PKG_PATH=''
	for entry in ${PKGS_INIT};do
		if [ "$1" == "${entry##*/}" ];then
			PKG_PATH=${entry}
			if [ "${DEPTH}" -eq 1 ];then
				echo "Package path: ${PKG_PATH}"
				echo "$1"
			fi
			break
		fi
	done

	[ ${DEBUG} -gt 0 ]  &&  echo "get_requires(): PKG_PATH=${PKG_PATH}"

	if [ -z "${PKG_PATH}" ];then
		i=1
		while [ $i -lt $DEPTH ];do
			printf "\t"
			i=$(( i + 1 ))
		done
		echo "Couldn't find '$1' in the specified repository!"

		DEPTH=$(( DEPTH - 1 ))
		[ ${DEBUG} -gt 1 ]  &&  echo "get_requires(): DEPTH='${DEPTH}'"

		return
	fi

	REQUIRES=''
	if [ -r "${PKG_PATH}"/*.info ];then
		[ ${DEBUG} -gt 1 ]  &&  echo "get_requires(): including $(ls -1 ${PKG_PATH}/*.info)"
		. "${PKG_PATH}"/*.info
	else
		i=1
		while [ $i -lt $DEPTH ];do
			printf "\t"
			i=$(( i + 1 ))
		done
		echo "Couldn't open info file: ${PKG_PATH}/*.info"

		DEPTH=$(( DEPTH - 1 ))
		[ ${DEBUG} -gt 1 ]  &&  echo "get_requires(): DEPTH='${DEPTH}'"

		return
	fi

	[ ${DEBUG} -gt 0 ]  &&  echo "get_requires(): REQUIRES='${REQUIRES}'"

	if [ -n "${REQUIRES}" ];then
		for pkg in ${REQUIRES};do
			i=1
			while [ $i -lt $DEPTH ];do
				printf "|\t"
				i=$(( i + 1 ))
			done

			echo -n "\_ ${pkg}"

			if [ ${CHECK_INSTALLED} -eq 1 ];then

				for installed_pkg in ${INSTALLED_PKGS};do
					if [ "${installed_pkg}" == "${pkg}" ];then
						FOUND=1
						break;
					fi
				done

				if [ ${FOUND} -eq 1 ];then
					echo -n " (installed)"
				fi
				FOUND=0
			fi

			echo

			if [ "${pkg}" != '%README%' ];then
				get_requires ${pkg}
			fi
		done
	else
		if [ ${DEPTH} == 1 ];then
			i=1
			while [ $i -lt $DEPTH ];do
				printf "|\t"
				i=$(( i + 1 ))
			done
			echo "\_ <NONE>"
		fi
		[ ${DEBUG} -gt 1 ]  &&  echo "get_requires(): end of requires for $1"
	fi

	DEPTH=$(( DEPTH - 1 ))
	[ ${DEBUG} -gt 1 ]  &&  echo "get_requires(): DEPTH='${DEPTH}'"
}

for param in $@;do
	pkg_name=$(echo ${param} |sed -e's%/$%%')

	# If we specified just a package name, treat it as a source package directory if it exists in the CWD,
	# then this makes sure that the directories' REQUIRES specified on the command line has precedence over the repository packages.
	# Otherwise the specified package name will be treated as an ordinary package name which will be searched for
	# in the repositories in $PKGS_INIT.
	if [ -d "./${pkg_name}" ];then
		PKGS_INIT="${pkg_name}
${PKGS_INIT}"
	fi
	[ ${DEBUG} -gt 1 ]  &&  echo "PKGS_INIT='${PKGS_INIT}'"

	pkg_name=${pkg_name##*/}

	[ ${DEBUG} -gt 0 ]  &&  echo "main(): pkg_name=${pkg_name}"

	[ ${DEBUG} -gt 1 ]  &&  echo "main(): entering get_requires() for ${pkg_name}"
	get_requires ${pkg_name}
done
