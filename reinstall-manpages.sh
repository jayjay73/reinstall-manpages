#!/bin/bash

set -e
set -o pipefail

echo -n "gathering packages to reinstall: " >&2

installed_packages=$( TERM=dumb unbuffer yum list installed | awk '/\s@/ {print $1}' | sort -u )

packages_to_install=$( for p in $installed_packages ; do
    reinstall=0

    file_list=$( repoquery -l $p | grep '/man/' )
    for f in $file_list ; do
        stat $f >/dev/null 2>&1
        if [[ $? -ne 0 ]] ; then
            reinstall=1
            break
        fi
    done
    if [[ $reinstall -eq 1 ]] ; then
        echo $p
        echo -n "." >&2
    fi
done | sort -u )

echo " done." >&2
#echo "$packages_to_install"

echo -n "re-installing packages: " >&2

yum --rpmverbosity=error -q -y -e 0 reinstall $packages_to_install

echo "$packages_to_install" >/var/lib/manpages-reinstalled

echo "done." >&2

