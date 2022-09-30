# UnraidDockerManager
Makes specified Application available as "remoteApp" on Unraid  Host by creating a DockerImage with vnc Acces



Uses PKGBUILD entries to
- set AutoStartPaths accordingly
- pulls default icon

Available Applications:
Arch (Core/Extra/Community) 

Tested with:
Ghidra (Community)
Firefox (Extra)
intellij-idea-ce  (Community)


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

# Based on bin-hex/arch-int-gui
[Base Image](https://github.com/binhex/arch-int-gui)


[bin-hex](https://github.com/binhex/)