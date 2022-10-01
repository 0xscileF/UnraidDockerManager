# UnraidDockerManager
### Makes specified Application available as "remoteApp" on Unraid  Host by creating a DockerImage with vnc Acces

# BREAKING 

PKGBUILD with symlinks across multiple lines  cause execPath to be null AND _pkgName is introduced... need  to grab that too look if it is referenced somewehere and "expand" it... make 

Concept:
 EXEC_PATH=$(echo "$PKGBUILD" | egrep -m$count -A$numlines "*ln -s*") ## need -m  count because there are more than one ln -s ?????? otherwise the ends with \ check breaks, right???  how to determine num lines jsut llop through $(echo "$PKGBUILD" | egrep "*ln -s*") ?????
 while EXECC_PATH |  grep '\\$'; do # spans multiple lines
  ++$numlines  
  EXEC_PATH=$(echo "$PKGBUILD" | egrep -A$numlines "*ln -s*")
 done;
 
 # EXAPTH should be sth  like ln -s "/opt/${pkgbase}/bin/${_pkgname}.sh" \
             "${pkgdir}/usr/bin/${pkgbase}"
 Continue normally but xargs it
 EXEC_PATH=$(echo $EXEC_PATH | xargs)
Pkg: clion

PkgBUild: https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=clion




#
Uses PKGBUILD entries to
- set AutoStartPaths accordingly
- set default icon

Available Applications:
Arch (Core/Extra/Community) 

### Tested with:
- Ghidra (Community) 
- Firefox (Extra) 
- intellij-idea-ce  (Community)

# WARNING:
- ## This is a first draft development version

- ## Use at your own risk

#

# Usage Unraid
```
cd UnraidDockerManager 
bash main.sh <programm>
In Unraid navigate to "Docker" -> addContainer
Choose TemplateFile: felix-<programm>
```
If there is no exact match a list  of candidates will be returned

Example
```
~$ bash main.sh intellij
Searching for intellij in Core/Extra...
Searching for intellij in Community...
Possible Candidates:
intellij-idea-plugin-emmy-lua
intellij-idea-community-edition-git
intellij-idea-ce
intellij-idea-community-edition-no-jre
intellij-idea-community-edition-jre
intellij-idea-ultimate-edition
intellij-idea-ultimate-edition-jre
intellij-idea-ue-eap
intellij-idea-ce-ea
```

# Based on bin-hex/pyCharm
[Base Image](https://github.com/binhex/arch-pycharm)


[bin-hex](https://github.com/binhex/)
