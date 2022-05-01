# vert_arcade_only
Vertical Menu Manager for the MiSTer FPGA Platform. 

vert_arcade_only aims to exist as an interim solution for MiSTer users who want a flat menu for vertically oriented Arcade titles only. Generally users who have their MiSTer hosted in an Arcade cabinet.

#### Important Usage Notes 
- vert_arcade_only usage assumes that users cease "direct" usage of downloader.sh or update_all.sh as vert_arcade_only.sh when invoked with "-u" will call out to the defined update tool while managing the vertical arcade structure. 
- Any execution of downloader.sh or update_all.sh after the initial 10 second delay will result in either tool redownloading the entire _Arcade, _Console, _Computer, _Utility, and _Other directory structure again.
- update_all.sh users can still make use of the text based menu to make changes to the respective .ini files but should exit when done and not let the download begin.
- Users who wish to return to standard MiSTer menu operation can do so with the "-r" option
- Currently CW an CCW orientations are not discriminated but can be if there's interest.
  Hoping more cores adopt a CW,CCW rotate option in the future.
- vert_arcade_only.list will be downloaded at runtime as a dependency as some .mra files are not published with a rotation tag.
- Theypsilon's downloader.sh is called during the update process and is a dependency.
- - https://github.com/MiSTer-devel/Downloader_MiSTer

#### Q: How to install vert_arcade_only ?<br>
<pre>wget --no-check-certificate -O /media/fat/Scripts/vert_arcade_only.sh https://raw.githubusercontent.com/alexanderupton/vert_arcade_only/main/vert_arcade_only.sh</pre>

#### Q: How to use vert_arcade_only ?<br>
After installation to /media/fat/Scripts vert_arcade_only.sh can be executed via shell login.

<pre>vert_arcade_only.sh <option>
options:
  -s|-setup : Change the default MiSTer menu to display ONLY vertical arcade titles
  -r|-rollback : Revert back to the default MiSTer root menu structure
  -u|-update : Update MiSTer and retain vertical arcade menu changes

example:
     ./vert_arcade_only.sh -u
</pre>
