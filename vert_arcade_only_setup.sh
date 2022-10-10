#!/bin/bash
# vert_arcade_only_setup.sh : v0.01 : Alexander Upton : 10/08/2022

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
if [ -f /media/fat/Scripts/vert_arcade_only.sh ]; then
 /media/fat/Scripts/vert_arcade_only.sh -s
else
 echo "vert_arcade_only.sh is not installed in /media/fat/Scripts"
 echo "Download: https://github.com/alexanderupton/vert_arcade_only"
fi

exit 0
