# vert_arcade_only
Vertical Menu Manager for the MiSTer FPGA Platform. 

vert_arcade_only aims to exist as an interim solution for MiSTer users who want a flat menu for vertically oriented Arcade titles only. Generally users who have their MiSTer hosted in an Arcade cabinet.

- Currently CW an CCW orientations are not discriminated but can be if there's interest.
  Hoping more cores adopt a CW,CCW rotate option in the future.
- vert_arcade_only.list will be downloaded at runtime as a dependency as some .mra files are not published with the appropiate <rotation> tag.
- Theypsilon's downloader.sh is called during the update process and is a dependency.
- - https://github.com/MiSTer-devel/Downloader_MiSTer

  
<pre>vert_arcade_only.sh <option>
options:
  -s|-setup : Change the default MiSTer menu to display ONLY vertical arcade titles
  -r|-rollback : Revert back to the default MiSTer root menu structure
  -u|-update : Update MiSTer and retain vertical arcade menu changes

example:
     ./vert_arcade_only.sh -u
</pre>
