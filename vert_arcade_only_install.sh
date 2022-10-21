#!/bin/bash
# vert_arcade_only_install.sh : v0.01 : Alexander Upton : 10/08/2022

# Copyright (c) 2022 Alexander Upton <alex.upton@gmail.com>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# You can download the latest version of this script from:
# https://github.com/alexanderupton/vert_arcade_only

# ========= CODE STARTS HERE =========

export SCRIPTS_DIR="/media/fat/Scripts"

DOWNLOAD(){
FILES="vert_arcade_only.sh vert_arcade_only.ini vert_arcade_only_update.sh vert_arcade_only.favorites"

for FILE in ${FILES}; do

 if [ ! -f "${SCRIPTS_DIR}/Scripts/${FILE}" ]; then
  wget \
  --no-check-certificate \
  -O ${SCRIPTS_DIR}/${FILE} \
  https://raw.githubusercontent.com/alexanderupton/vert_arcade_only/main/${FILE}
 fi

 if [ "$?" != "0" ]; then
  echo "${SCRIPTS_DIR}/${FILE} is required for base operation."
  echo "Check Internet Connection. Exiting..."
  exit 1
 fi

done
}

INSTALL(){
if [ -f "${SCRIPTS_DIR}/vert_arcade_only_update.sh" ]; then
 echo "Update via MiSTer Scripts UI is setup"
else
 echo "${SCRIPTS_DIR}/vert_arcade_only_update.sh is required for base operation. Check Internet connection"
 exit 1
fi

if [ -f "${SCRIPTS_DIR}/vert_arcade_only.ini" ]; then
 echo "Installing with the following default options:"
 cat ${SCRIPTS_DIR}/vert_arcade_only.ini
else
 echo "${SCRIPTS_DIR}/vert_arcade_only.ini is required for base operation. Check Internet connection"
 exit 1
fi

if [ -f "${SCRIPTS_DIR}/vert_arcade_only.sh" ]; then
 ${SCRIPTS_DIR}/vert_arcade_only.sh -td
else
 echo "${SCRIPTS_DIR}/vert_arcade_only.sh is required for base operation. Check Internet connection"
 exit 1
fi
}

DOWNLOAD
INSTALL
