#!/bin/bash
# vert_arcade_only.sh : v0.01 : Alexander Upton : 04/24/2022
# Release: v0.01 : Alexander Upton : 04/24/2021 : Initial Draft
#
# vert_arcade_only.sh : v0.02 : Alexander Upton : 08/26/2022
# Changes:
# - List cleanup
# - Added a ".Most Recent" directory on the front menu that lists
#   the most recent 25 Arcade titles that have been updated after
#   each update.
# - Added "-mr <number>" execution to control the number of ganes the
#  ".Most Recent" directory will contain. Default is 25.
# - Added .ini support to support override of "CONFIGURABLE" variables.

# vert_arcade_only.sh : v0.03 : Alexander Upton : 10/08/2022
# Changes:
# - Added support for [mister] arcade-cores filtering to downloader.ini
#  to prevent download and update of non-arcade MiSTer cores.

# vert_arcade_only.sh : v0.04 : Alexander Upton : 10/11/2022
# Changes:
# - Cleaned up support for [mister] arcade-cores filtering to downloader.ini
#  to preserve existing [mister] filters.
# - Improved validation of existing MiSTer framework state during -s[etup] to
#  call update_all.sh in the event a user is starting from an SD card created
#  through Mr. Fusion or similar imaging utilities with no further setup.
#
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
# Overwrite at runtime in Scripts/vert_arcade_only.ini

MEDIA_ROOT="/media/fat"
MISTER_UPDATER="${MEDIA_ROOT}/Scripts/downloader.sh"
REBOOT="false"
COUNTDOWN_TIME="15"
MRA_PATH="/media/fat"
MRA_RECENT_DIR="${MRA_PATH}/_[ Most Recent ]"
#MRA_RECENT_DIR="${MRA_PATH}/_.Most Recent"
FAVORITES_DIR="_[ Favorites ]"
ALTERNATIVES_DIR="_[ Alternatives ]"

if [ -s "${MEDIA_ROOT}/Scripts/vert_arcade_only.ini" ]; then
 echo; echo "vert_arcade_only.sh : Using ${MEDIA_ROOT}/Scripts/vert_arcade_only.ini"
 . "${MEDIA_ROOT}/Scripts/vert_arcade_only.ini"
fi

# ========= USAGE ====================
USAGE(){
 echo
 echo "vert_arcade_only.sh <option>"
 echo "options:"
 echo "  -f|-favorites : Build a top-level .Favorites menu from vert_arcade_only.favorites"
 echo "  -i|-install : Change the default MiSTer menu to display ONLY vertical arcade titles"
 echo "  -r|-remove : Revert back to the default MiSTer root menu structure"
 echo "  -u|-update : Update MiSTer and retain vertical arcade menu changes" 
 echo "  -mr|-mostrecent : Scan for recently updated Arcade titles and make them available in the '.Most Recent' menu" 
 echo
 echo "example:"
 echo "     Check for MiSTer updates: vert_arcade_only.sh -u"
 echo "     Add 75 most recent Arcade titles to the '.Most Recent' menu: vert_arcade_only.sh -mr 75"
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

ENV_CHECK(){
# unfinished
if [ -n "${TATE_DIR}" ]; then
 ARCADE_DIR="${MEDIA_ROOT}/_Arcade"
 ALT_DIR="${TATE_DIR}/${ALTERNATIVES_DIR}"
 LINK_ROOT="${TATE_DIR}"
else
 ARCADE_DIR="${MEDIA_ROOT}/Arcade"
 ALT_DIR="${MEDIA_ROOT}/${ALTERNATIVES_DIR}"
 LINK_ROOT="${MEDIA_ROOT}"
fi
}

DOWNLOADER_INI_FILTER(){
APPLY_FILTER(){
echo '[mister]
filter = "arcade-cores"' >> ${MEDIA_ROOT}/downloader.ini
}

 FILTER="arcade-cores"
 if [ -f ${MEDIA_ROOT}/downloader.ini ]; then
  if grep -q "arcade-cores" ${MEDIA_ROOT}/downloader.ini; then
   echo "arcade-cores [mister] filter set in ${MEDIA_ROOT}/downloader.ini"
  else
   if grep -q filter ${MEDIA_ROOT}/downloader.ini; then
    MISTER_FILTER=$(grep '\[mister\]' -A1 ../downloader.ini |grep -v mister | awk -F= {'print $2'} | awk -F\" {'print $2'})
    NEW_FILTER="${FILTER} ${MISTER_FILTER}"
    sed -iv "s|${MISTER_FILTER}|${NEW_FILTER}|g" ${MEDIA_ROOT}/downloader.ini
   else
    APPLY_FILTER
   fi
  fi
else
 APPLY_FILTER
 if [ "$?" == "0" ]; then
  echo "Adding arcade-cores filter to ${MEDIA_ROOT}/downloader.ini"
 else
  echo "Failed to write to ${MEDIA_ROOT}/downloader.ini"
 fi
fi

 if [ -f ${MEDIA_ROOT}/Scripts/update_all.ini ]; then
  AUTO_REBOOT=$(awk -F "= " '/AUTOREBOOT/ {print $2}' ${MEDIA_ROOT}/Scripts/update_all.ini)
  if [ "${AUTO_REBOOT}" != \"false\" ]; then
   sed -i 's/AUTOREBOOT="true"/AUTOREBOOT="false"/g' ${MEDIA_ROOT}/Scripts/update_all.ini
  fi
 fi

}

DEFAULT_MOVE_SETUP(){
echo;echo;echo "Sequence:
- Rename default directory structure to prevent display in menu 
- Scan Arcade root level .mra files for vertical rotation (cw,ccw)
- Create symlinks to all detected and known vertical Arcade titles
- Create symlinks to supporting Arcade cores
- Reboot
-"
sleep 1

# Checking if any previous MiSTer installation exists when invoking setup.
[[ -d "/media/fat/Arcade" ]] && EXISTING="1" || EXISTING="0"
[[ -d "/media/fat/_Arcade" ]] && EXISTING_="1" || EXISTING_="0"
EXISTING_STATE=$(( "${EXISTING}" + "${EXISTING_}" ))

if [[ "${EXISTING_STATE}" > "0" ]]; then
 echo;export COUNTDOWN_MSG="Building MiSTer Vertical Menu"
 COUNTDOWN
else
 echo "Looks like this is a new MiSTer setup. Updating via update_all.sh"
 UPDATE
fi

echo;echo "Building MiSTer Vertical Arcade Menu."
unset IFS OIFS
BASE_DIR_LIST="Arcade Console Computer Utility Other"

cd ${MEDIA_ROOT}
for DIR in ${BASE_DIR_LIST}; do
 [[ -d "_${DIR}" ]] && mv "_${DIR}" "${DIR}"
done

}

FAVORITES_SETUP(){
 if [ -n "${TATE_DIR}" ]; then
  export ARCADE_DIR="${MEDIA_ROOT}/_Arcade"
  export ALT_DIR="${TATE_DIR}/${ALTERNATIVES_DIR}"
  export LINK_ROOT="${TATE_DIR}"
 else
  export ARCADE_DIR="${MEDIA_ROOT}/Arcade"
  export ALT_DIR="${MEDIA_ROOT}/${ALTERNATIVES_DIR}"
  export LINK_ROOT="${MEDIA_ROOT}"
 fi

 if [ -f ${MEDIA_ROOT}/Scripts/vert_arcade_only.favorites ]; then
  [[ ! -d "${LINK_ROOT}/${FAVORITES_DIR}/${ALTERNATIVES_DIR}" ]] && mkdir -p "${LINK_ROOT}/${FAVORITES_DIR}/${ALTERNATIVES_DIR}"
  [[ ! -L "${LINK_ROOT}/${FAVORITES_DIR}/cores" ]] && ln -sf "${ARCADE_DIR}/cores" "${LINK_ROOT}/${FAVORITES_DIR}/cores"
  cd ${MEDIA_ROOT}
  for mra in $(sort -u ${MEDIA_ROOT}/Scripts/vert_arcade_only.favorites); do
   if [ -f "${ARCADE_DIR}/${mra}.mra" ]; then
    BASEMRA=$(basename ${mra})
    MRA_NAME=$(basename ${mra})
    MRA_RAW=$(echo ${MRA_NAME} | awk -F. {'print $1'})
    MRA_ROOT_STRIP=$(echo "${mra}" | sed 's|\/media\/fat\/||'g)
    echo "Favoriting: ${mra}.mra"
    if [[ ! -L "${LINK_ROOT}/${FAVORITES_DIR}/${mra}.mra" ]]; then
     ln -sf "${ARCADE_DIR}/${mra}".mra "${LINK_ROOT}/${FAVORITES_DIR}/${mra}".mra
    fi
   fi

   if [ -d "${ARCADE_DIR}/_alternatives/_${MRA_RAW}" ]; then
    echo "Favoriting: Alternate versions of ${MRA_RAW}"
    ln -sf "${ARCADE_DIR}/_alternatives/_${MRA_RAW}" "${LINK_ROOT}/${FAVORITES_DIR}/${ALTERNATIVES_DIR}/_${MRA_RAW}"
   fi

  done

 fi
 
 if [ -d "${MEDIA_ROOT}/Favorites.old" ]; then
  for mra in $(ls ${MEDIA_ROOT}/Favorites.old); do
   if [ -f "${ARCADE_DIR}/${mra}" ]; then
    BASEMRA=$(basename ${mra})
    MRA_NAME=$(basename ${mra})
    MRA_RAW=$(echo ${MRA_NAME} | awk -F. {'print $1'})
    MRA_ROOT_STRIP=$(echo "${mra}" | sed 's|\/media\/fat\/||'g)
    echo "Favoriting: ${mra}"
    if [[ ! -L "${LINK_ROOT}"/${FAVORITES_DIR}/${mra} ]]; then
     ln -sf "${ARCADE_DIR}/${mra}" "${LINK_ROOT}/${FAVORITES_DIR}/${mra}"
    fi
   fi
  done
 fi
}

RESTART(){
if [ "${REBOOT}" == "true" ]; then
 echo;export COUNTDOWN_MSG="Rebooting MiSTer"
 COUNTDOWN
 reboot
fi
}

MRA_SETUP(){
IFS=$'\n'
OIFS="$IFS"

if [ -n "${TATE_DIR}" ]; then
 ARCADE_DIR="${MEDIA_ROOT}/_Arcade"
 ALT_DIR="${TATE_DIR}/${ALTERNATIVES_DIR}"
 LINK_ROOT="${TATE_DIR}"
else
 ARCADE_DIR="${MEDIA_ROOT}/Arcade"
 ALT_DIR="${MEDIA_ROOT}/${ALTERNATIVES_DIR}"
 LINK_ROOT="${MEDIA_ROOT}"
fi

echo "Scanning MiSTer .mra files for vertical orientation"
if [ -d ${ARCADE_DIR} ]; then
 [[ ! -d "${ALT_DIR}" ]] && mkdir -p "${ALT_DIR}"
 [[ ! -L "${ALT_DIR}/cores" ]] && ln -sf "${ARCADE_DIR}/cores" "${ALT_DIR}/cores"
 for mra in ${ARCADE_DIR}/*.mra ; do
  BASEMRA=$(basename ${mra})
  if grep -q rotation\>vertical ${mra}; then
   cd ${LINK_ROOT}
   MRA_NAME=$(basename ${mra})
   MRA_RAW=$(echo ${MRA_NAME} | awk -F. {'print $1'})
   MRA_ROOT_STRIP=$(echo "${mra}" | sed 's|\/media\/fat\/||'g)
 
   if [ -f "${mra}" ]; then
    echo "Processing: ${BASEMRA}"
    [[ ! -L "./${MRA_NAME}" ]] && ln -sf "${mra}" ${LINK_ROOT}/"${MRA_NAME}"
    #[[ ! -L "./${MRA_NAME}" ]] && ln -sf "${MRA_ROOT_STRIP}" ./"${MRA_NAME}"
   else
    echo "BAD-${MRA_PATH}"
   fi

   if [ -d "${ARCADE_DIR}/_alternatives/_${MRA_RAW}" ]; then
    echo "Processing: Alternate versions of ${MRA_RAW}"
    ln -sf "${ARCADE_DIR}/_alternatives/_${MRA_RAW}" "${ALT_DIR}/_${MRA_RAW}"
   fi

  fi
 done
 
 echo "Downloading supplemental MiSTer supported vertical arcade title list"
 wget -qO ${MEDIA_ROOT}/Scripts/vert_arcade_only.list \
 https://raw.githubusercontent.com/alexanderupton/vert_arcade_only/main/vert_arcade_only.list 

 if [ -f ${MEDIA_ROOT}/Scripts/vert_arcade_only.list ]; then
  cd ${MEDIA_ROOT}
  for mra in $(sort -u ${MEDIA_ROOT}/Scripts/vert_arcade_only.list); do
   if [ -f "${ARCADE_DIR}/${mra}.mra" ]; then
    echo "Processing: ${mra}.mra"
    if [[ ! -L "${LINK_ROOT}/${mra}.mra" ]]; then
     ln -sf "${ARCADE_DIR}/${mra}.mra" "${LINK_ROOT}/${mra}.mra"
    fi
   fi

   if [ -d "${ARCADE_DIR}/_alternatives/_${mra}" ]; then
    echo "Processing: Alternate versions of ${mra}"
    ln -sf "${ARCADE_DIR}/_alternatives/_${mra}" "${ALT_DIR}/_${mra}"
    ln -sf "${ARCADE_DIR}/cores" "${ALT_DIR}/_${mra}/cores"
   fi

  done
 else
  echo "File not found : ${MEDIA_ROOT}/Scripts/vert_arcade_only.list"
  echo "Check Internet connection to: https://raw.githubusercontent.com/alexanderupton/vert_arcade_only/main/vert_arcade_only.list"
 fi
fi

}

CORE_SETUP(){
 if [ -n "${TATE_DIR}" ]; then
  if [[ ! -L "${TATE_DIR}/cores" ]]; then
   [[ -d ${MEDIA_ROOT}/_Arcade/cores ]] && ln -sf ${MEDIA_ROOT}/_Arcade/cores ${TATE_DIR}/cores
  fi
 else
  if [[ ! -L ${MEDIA_ROOT}/cores ]]; then
   [[ -d ${MEDIA_ROOT}/Arcade/cores ]] && ln -sf ${MEDIA_ROOT}/Arcade/cores ${MEDIA_ROOT}/cores
  fi
 fi
}

FAVORITES_CHECK(){
if [[ -f ${MEDIA_ROOT}/Scripts/favorites.sh ]]; then
 [[ -L ${MEDIA_ROOT}/cores ]] && rm -f ${MEDIA_ROOT}/cores
fi

if [ -d "${MEDIA_ROOT}/_Favorites" ]; then
 [[ -L ${MEDIA_ROOT}/_Favorites/cores ]] && rm -f ${MEDIA_ROOT}/_Favorites/cores
 mv ${MEDIA_ROOT}/_Favorites ${MEDIA_ROOT}/Favorites.old
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
- Remove all symlinks from ${MEDIA_ROOT}"

cd ${MEDIA_ROOT}
unset IFS OIFS
BASE_DIR_LIST="Arcade Console Computer Utility Other"

if [ ! -n "${TATE_DIR}" ]; then
 echo "Temporaily restoring default MiSTer menu structure to support update"
 for DIR in ${BASE_DIR_LIST}; do
  [[ -d "${MEDIA_ROOT}/${DIR}" ]] && mv "${MEDIA_ROOT}/${DIR}" "${MEDIA_ROOT}/_${DIR}"
 done
fi

${MISTER_UPDATER}

if [ ! -n "${TATE_DIR}" ]; then
 echo "Restoring MiSTer Vertical Arcade Menu"
 for DIR in ${BASE_DIR_LIST}; do
  [[ -d "${MEDIA_ROOT}/_${DIR}" ]] && mv "${MEDIA_ROOT}/_${DIR}" "${MEDIA_ROOT}/${DIR}"
 done
fi

echo "Done!"
}

ROLLBACK(){
echo;echo "Sequence:
- Restore default _Arcade _Console _Computer _Utility _Other directory structure
- Remove all symlinks from ${MEDIA_ROOT}
- Reboot"

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
LINK_O="L"
LINK="${LINK_O}"

if [ -n "${TATE_DIR}" ]; then
 MRA_PATH="/media/fat/_Arcade"
 FILE_O="f"
 LINK=${FILE_O}
 MRA_RECENT_DIR="${TATE_DIR}/_[ Most Recent ]"
fi

[[ ! -d "${MRA_RECENT_DIR}" ]] && mkdir ${MKDIR_OPT} "${MRA_RECENT_DIR}"
[[ ! -L ${MRA_RECENT_DIR}/cores ]] && ln -sf ${MRA_PATH}/cores ${MRA_RECENT_DIR}/cores

OPTION_RE='^[0-9]+$'

if [[ ${MRA_RECENT_LEN} =~ ${OPTION_RE} ]]; then
 if [[ ${OPTION} =~ ${OPTION_RE} ]]; then
  echo "vert_arcade_only.sh : Overriding MRA_RECENT_LEN value in vert_arcade_only.ini with -mr value ${OPTION}"
  MRA_RECENT_LEN=${OPTION}
 else
  echo "Using MRA_RECENT_LEN value of ${MRA_RECENT_LEN} from vert_arcade_only.ini"
 fi
else
 if [[ ${OPTION} =~ ${OPTION_RE} ]]; then
  MRA_RECENT_LEN="${OPTION}"
 else
  echo "Defaulting '[ Most Recent ]' list to 50"
  MRA_RECENT_LEN="50"
 fi
fi

#RECENT_MRA=$(ls -tr ${MRA_PATH}/*.mra | tail -${MRA_RECENT_LEN})

RECENT_MRA=$(for mra in $(ls -tr ${MRA_PATH}/*.mra); do
 if grep -q rotation\>vertical ${mra}; then
  echo $mra
 fi
done | tail -${MRA_RECENT_LEN})

#for i in ${ML_LIST}; do
# echo $i
#done

for MRA in ${RECENT_MRA}; do
 RECENT_MRA_LIST="${RECENT_MRA_LIST} ${MRA}"
 if [ -${LINK} "${MRA}" ]; then
  MRA_NAME=$(basename ${MRA})
  MFG_NAME=$(sed -ne '/manufacturer/{s/.*<manufacturer>\(.*\)<\/manufacturer>.*/\1/p;q;}' "${ARCADE_DIR}/${MRA_NAME}" | awk -F\( {'print $1'})
  CORE_NAME=$(sed -ne '/rbf/{s/.*<rbf>\(.*\)<\/rbf>.*/\1/p;q;}' "${ARCADE_DIR}/${MRA_NAME}" | awk -F\( {'print $1'})
  echo "Processing: ${MRA_NAME} - Manufacturer: ${MFG_NAME} - Core: ${CORE_NAME}"

  #echo "TEST MRA = ${MRA}"
  #echo "TEST MRA_NAME = ${MRA_NAME}"
  #exit 0

  if [ ! -L "${MRA_RECENT_DIR}/${MRA_NAME}" ]; then
    ln ${LN_OPT} ${ARCADE_DIR}/${MRA_NAME} "${MRA_RECENT_DIR}/${MRA_NAME}"
    #ln ${LN_OPT} ${MRA} "${MRA_RECENT_DIR}/${MRA_NAME}"
  fi

 fi
  unset MRA MRA_NAME MFG_NAME CORE_NAME
done

for MRA in ${MRA_RECENT_DIR}/*; do
 if [ ${MRA} == "*.mra" ]; then
  MRA_NAME=$(basename ${MRA})
  if ! echo ${RECENT_MRA_LIST} | grep -q "${MRA_NAME}"; then
   rm -fv ${MRA} | logger -t vert_arcade_only.sh
  fi
 fi
done

}

TATE_DIR(){
[[ ! -n "${TATE_DIR}/" ]] && export TATE_DIR=${MEDIA_ROOT}/_.TATE
[[ ! -d "${TATE_DIR}" ]] && mkdir -p "${TATE_DIR}"

APPLY_TATE_DIR(){
echo 'TATE_DIR="/media/fat/_[ TATE ]"' >> ${MEDIA_ROOT}/Scripts/vert_arcade_only.ini
. "${MEDIA_ROOT}/Scripts/vert_arcade_only.ini"
}

if [ -f ${MEDIA_ROOT}/Scripts/vert_arcade_only.ini ]; then
 if ! grep TATE_DIR ${MEDIA_ROOT}/Scripts/vert_arcade_only.ini; then
  APPLY_TATE_DIR
 fi
else
 APPLY_TATE_DIR
fi
}

case ${SWITCH} in
 -u|-update)
  DOWNLOADER_INI_FILTER
  UPDATE
  FAVORITES_CHECK
  MRA_SETUP
  CORE_SETUP 
  MOST_RECENT
  FAVORITES_SETUP
  RESTART ;;
 -i|-install)
  DOWNLOADER_INI_FILTER 
  DEFAULT_MOVE_SETUP
  FAVORITES_CHECK
  CORE_SETUP
  MRA_SETUP
  MOST_RECENT
  FAVORITES_SETUP
  RESTART ;;
 -r|-remove)
  ROLLBACK ;;
 -f|-favorites)
  FAVORITES_SETUP ;;
 -mr|-mostrecent)
  MOST_RECENT ;;
 -td|-tatedir)
  TATE_DIR 
  MRA_SETUP
  CORE_SETUP
  MOST_RECENT 
  FAVORITES_SETUP 
  RESTART ;;
 -du|-debugupdate)
  DOWNLOADER_INI_FILTER
  #UPDATE
  FAVORITES_CHECK
  MRA_SETUP
  CORE_SETUP
  MOST_RECENT
  FAVORITES_SETUP ;;
 *) USAGE ;;
esac

