## **Miscellaneous shell scripts for WSL1/Debian**


### FOR BUILDING FILEZILLA CLIENT/SERVER
Useful in cross-compiling FileZilla Client or Server on WSL1/Debian over Windows 10 with the guides in this repository.

* Use these scripts only in conjunction with the guides they are referenced from to avoid unexpected results.  
* Download to `/sources` folder (see guides)  
* execute via `source {scriptname}` or `. {scriptname}`
<br>  

script | purpose
-|-
`setenv-buildfz` | configure environment variables for building FileZilla Client or Server<br>usage: `. setenv-buildfz client64` or `. setenv-buildfz server`
`cleanup-source-libs` | cleans all dependency build folders and cleans output folder for FileZilla Client/Server
`package-fzclient` | strips and packages the FileZilla Client for Windows installer

### OTHER SCRIPTS
Download to noted
script | purpose
-|-
`.bashrc` | `.bashrc` with enhanced prompt and some useful command aliases<br>place in `~/` folder and restart shell to enable
`DIR_COLORS` | custom lscolors - place in /etc folder for use with above `.bashrc`<br>place in `/etc` folder and restart shell to enable 


<br><br>

---
**ABSOLUTELY NO WARRANTY OR GUARANTEE GIVEN FOR USAGE OF THESE SCRIPTS OR GUIDES IN THIS REPO**
