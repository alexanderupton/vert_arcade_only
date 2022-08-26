#!/bin/bash
# vert_arcade_only.sh : v0.01 : Alexander Upton : 04/24/2022

# vert_arcade_only.sh : v0.02 : Alexander Upton : 08/26/2022
# Changes:
# - List cleanup
# - Added a ".Most Recent" directory on the front menu that lists
#   the most recent 25 Arcade titles that have been updated after
#   each update.
# - Added "-mr <number>" execution to control the number of ganes the
#  ".Most Recent" directory will contain. Default is 25.
# - Added .ini support to support override of "CONFIGURABLE" variables.

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
# https://github.com/alexanderupton/MiSTer-Scripts

# v0.01 : Alexander Upton : 04/24/2021 : Initial Draft

# ========= IMMUTABLE ================
IFS=$'\n'
OIFS="$IFS"
SWITCH="${1}"
OPTION="${2}"

if [ "${SWITCH}" == "-v" ]; then
 export MKDIR_OPT="-pv"
 export LN_OPT="-sfv"
else
 export MKDIR_OPT="-p"
 export LN_OPT="-sf"
fi


# ======== CONFIGURABLE ==============
MEDIA_ROOT="/media/fat"
MISTER_UPDATER="${MEDIA_ROOT}/Scripts/downloader.sh"
REBOOT="false"
COUNTDOWN_TIME="15"
MRA_PATH="/media/fat"
MRA_RECENT_DIR="${MRA_PATH}/_.Most Recent"

if [ -s "${MEDIA_ROOT}/Scripts/vert_arcade_only.ini" ]; then
 echo; echo "vert_arcade_only.sh : Using ${MEDIA_ROOT}/Scripts/vert_arcade_only.ini"
 . "${MEDIA_ROOT}/Scripts/vert_arcade_only.ini"
fi

# ========= USAGE ====================
USAGE(){
 echo
 echo "vert_arcade_only.sh <option>"
 echo "options:"
 echo "  -s|-setup : Change the default MiSTer menu to display ONLY vertical arcade titles"
 echo "  -r|-rollback : Revert back to the default MiSTer root menu structure"
 echo "  -u|-update : Update MiSTer and retain vertical arcade menu changes" 
 echo
 echo "example:"
 echo "     ./vert_arcade_only.sh -u"
 echo
 exit 0
}

# ========= CODE STARTS HERE =========
COUNTDOWN() {
# To align in with existing MiSTer administration tools.

 local BOLD_IN="$(tput bold)"
 local BOLD_OUT="$(tput sgr0)"
 echo
 echo " ${BOLD_IN}*${BOLD_OUT}Press <${BOLD_IN} UP ${BOLD_OUT}>, To exit now."
 echo -n " ${BOLD_IN}*${BOLD_OUT}Press <${BOLD_IN} DOWN ${BOLD_OUT}>, To continue now."

 set +e
 echo -e '\e[3A\e[K'
 for (( i=0; i <= COUNTDOWN_TIME ; i++)); do
  local SECONDS=$(( COUNTDOWN_TIME - i ))
 
  if (( SECONDS < 10 )) ; then
   SECONDS=" ${SECONDS}"
  fi
 
  printf "\r${COUNTDOWN_MSG} in ${SECONDS} seconds."
  
  for (( j=0; j < i; j++)); do
   printf "."
  done

  read -r -s -N 1 -t 1 key
   if [[ "${key}" == "A" ]]; then
    exit 0
   elif [[ "${key}" == "B" ]]; then
    COUNTDOWN_SELECTION="continue"
    break
   fi

 done
}

DEFAULT_MOVE_SETUP(){
echo;echo "Sequence:
- Rename default directory structure to prevent display in menu 
- Scan Arcade root level .mra files for vertical rotation (cw,ccw)
- Create symlinks to all detected and known vertical Arcade titles
- Create symlinks to supporting Arcade cores
- Reboot
-"

echo;export COUNTDOWN_MSG="Building MiSTer Vertical Menu"
COUNTDOWN

echo;echo "Building MiSTer Vertical Arcade Menu."
unset IFS OIFS
BASE_DIR_LIST="Arcade Console Computer Utility Other"

cd ${MEDIA_ROOT}
for DIR in ${BASE_DIR_LIST}; do
 [[ -d "_${DIR}" ]] && mv "_${DIR}" "${DIR}"
done

export REBOOT="true"
}

MRA_SETUP(){
IFS=$'\n'
OIFS="$IFS"
echo "Scanning MiSTer .mra files for vertical orientation"
if [ -d ${MEDIA_ROOT}/Arcade ]; then
 for mra in "${MEDIA_ROOT}"/Arcade/*.mra ; do
  BASEMRA=$(basename ${mra})
  if grep -q rotation\>vertical ${mra}; then
   echo "Processing: ${BASEMRA}"
   cd ${MEDIA_ROOT}
   MRA_NAME=$(basename ${mra})
   MRA_RAW=$(echo ${MRA_NAME} | awk -F. {'print $1'})
   MRA_ROOT_STRIP=$(echo "${mra}" | sed 's|\/media\/fat\/||'g)
 
   if [ -f "${mra}" ]; then
    [[ ! -L "./${MRA_NAME}" ]] && ln -sf "${MRA_ROOT_STRIP}" ./"${MRA_NAME}"
   else
    echo "BAD-${MRA_PATH}"
   fi

   if [ -d "Arcade/_alternatives/_${MRA_RAW}" ]; then
    echo "Setup Alternative versions of ${MRA_RAW}"
    [[ ! -L "./_${MRA_RAW}" ]] && ln -sf "Arcade/_alternatives/_${MRA_RAW}" "_${MRA_RAW}"
    [[ ! -L "./_${MRA_RAW}/cores" ]] && ln -sf "${MEDIA_ROOT}/Arcade/cores" "_${MRA_RAW}/cores"
   fi
   
  fi
 done
 
 echo "Downloading supplemental MiSTer supported vertical arcade title list"
 wget -qO ${MEDIA_ROOT}/Scripts/vert_arcade_only.list \
 https://raw.githubusercontent.com/alexanderupton/vert_arcade_only/main/vert_arcade_only.list 

 if [ -f ${MEDIA_ROOT}/Scripts/vert_arcade_only.list ]; then
  cd ${MEDIA_ROOT}
  for mra in $(sort -u ${MEDIA_ROOT}/Scripts/vert_arcade_only.list); do
   if [ -f "${MEDIA_ROOT}"/Arcade/${mra}.mra ]; then
    echo "Processing: ${mra}.mra"
    if [[ ! -L "${MEDIA_ROOT}"/${mra}.mra ]]; then
     ln -sf Arcade/"${mra}".mra "${mra}".mra
    fi
   fi

   if [ -d "Arcade/_alternatives/_${mra}" ]; then
    echo "Setup alternative versions of "${mra}" "
    ln -sf "Arcade/_alternatives/_${mra}" "_${mra}"
    ln -sf "${MEDIA_ROOT}/Arcade/cores" "_${mra}/cores"
   fi

  done
 else
  echo "File not found : ${MEDIA_ROOT}/Scripts/vert_arcade_only.list"
  echo "Check Internet connection to: https://raw.githubusercontent.com/alexanderupton/vert_arcade_only/main/vert_arcade_only.list"
 fi
fi

if [ "${REBOOT}" == "true" ]; then
 echo;export COUNTDOWN_MSG="Rebooting MiSTer"
 COUNTDOWN
 reboot
fi

}

CORE_SETUP(){
if [[ ! -L ${MEDIA_ROOT}/cores ]]; then
 [[ -d ${MEDIA_ROOT}/Arcade/cores ]] && ln -sf ${MEDIA_ROOT}/Arcade/cores ${MEDIA_ROOT}/cores
fi
}

UPDATE(){
if [ ! -f "${MISTER_UPDATER}" ]; then
 echo;echo "Fail: 
 Missing downloader.sh. Unable to update MiSTer.
 Please install the MiSTer Downloader tool to continue.
 https://github.com/MiSTer-devel/Downloader_MiSTer";echo
 exit 1
fi

echo;export COUNTDOWN_MSG="Updating MiSTer and checking for new Vertical Arcade titles"
COUNTDOWN

echo;echo "Sequence:
- Restore default _Arcade _Console _Computer _Utility _Other directory structure
- Remove all symlinks from ${MEDIA_ROOT}
-
"

cd ${MEDIA_ROOT}
unset IFS OIFS
BASE_DIR_LIST="Arcade Console Computer Utility Other"

echo "Temporaily restoring default MiSTer menu structure to support update"

for DIR in ${BASE_DIR_LIST}; do
 [[ -d "${MEDIA_ROOT}/${DIR}" ]] && mv "${MEDIA_ROOT}/${DIR}" "${MEDIA_ROOT}/_${DIR}"
done

${MISTER_UPDATER}

echo "Restoring MiSTer Vertical Arcade Menu"
for DIR in ${BASE_DIR_LIST}; do
 [[ -d "${MEDIA_ROOT}/_${DIR}" ]] && mv "${MEDIA_ROOT}/_${DIR}" "${MEDIA_ROOT}/${DIR}"
done

echo "Done!"
}

ROLLBACK(){
echo;echo "Sequence:
- Restore default _Arcade _Console _Computer _Utility _Other directory structure
- Remove all symlinks from ${MEDIA_ROOT}
- Reboot
"

echo;export COUNTDOWN_MSG="Restoring default MiSTer menu"
COUNTDOWN

IFS=$'\n'
OIFS="$IFS"
BASE_DIR_LIST="Arcade Console Computer Utility Other"

cd ${MEDIA_ROOT}
for mra_sym in $(find ! -name . -prune -type l); do
 rm -fv "${mra_sym}"
done

unset IFS OIFS
for DIR in ${BASE_DIR_LIST}; do
 [[ -d "${MEDIA_ROOT}/${DIR}" ]] && mv "${MEDIA_ROOT}/${DIR}" "${MEDIA_ROOT}/_${DIR}"
done

echo "Done!"

echo;export COUNTDOWN_MSG="Rebooting MiSTer"
COUNTDOWN
reboot
}

MOST_RECENT() {
[[ ! -d "${MRA_RECENT_DIR}" ]] && mkdir ${MKDIR_OPT} "${MRA_RECENT_DIR}"
[[ ! -L ${MRA_RECENT_DIR}/cores ]] && ln -sf ${MEDIA_ROOT}/Arcade/cores ${MRA_RECENT_DIR}/cores

OPTION_RE='^[0-9]+$'

[[ ${OPTION} =~ ${OPTION_RE} ]] && MRA_RECENT_LEN=${OPTION} || MRA_RECENT_LEN="25"

LAST_25_MRA=$(ls -tr ${MRA_PATH}/*.mra | tail -${MRA_RECENT_LEN})

for MRA in ${LAST_25_MRA}; do
 LAST_25_MRA_LIST="${LAST_25_MRA_LIST} ${MRA}"
 if [ -L "${MRA}" ]; then
  MRA_NAME=$(basename ${MRA})
  MFG_NAME=$(sed -ne '/manufacturer/{s/.*<manufacturer>\(.*\)<\/manufacturer>.*/\1/p;q;}' ${MRA} | awk -F\( {'print $1'})
  CORE_NAME=$(sed -ne '/rbf/{s/.*<rbf>\(.*\)<\/rbf>.*/\1/p;q;}' ${MRA} | awk -F\( {'print $1'})
  echo "Processing: ${MRA_NAME} - Manufacturer: ${MFG_NAME} - Core: ${CORE_NAME}"

  if [ ! -L "${MRA_RECENT_DIR}/${MRA_NAME}" ]; then
    ln ${LN_OPT} ${MRA} "${MRA_RECENT_DIR}/${MRA_NAME}"
  fi

 fi
  unset MRA MRA_NAME MFG_NAME CORE_NAME
done

for MRA in ${MRA_RECENT_DIR}/*; do
 if [ ${MRA} == "*.mra" ]; then
  MRA_NAME=$(basename ${MRA})
  if ! echo ${LAST_25_MRA_LIST} | grep -q "${MRA_NAME}"; then
   rm -fv ${MRA} | logger -t vert_arcade_only.sh
  fi
 #else
 # basename "${MRA}"
 fi
done

}

case ${SWITCH} in
 -u|-update)
  UPDATE
  MRA_SETUP 
  MOST_RECENT ;;
 -s|-setup) 
  DEFAULT_MOVE_SETUP
  CORE_SETUP
  MRA_SETUP
  MOST_RECENT ;;
 -r|-rollback)
  ROLLBACK ;;
 -mr)
  MOST_RECENT ;;
 *) USAGE ;;
esac
