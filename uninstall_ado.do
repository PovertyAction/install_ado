* Author: Matthew White, Innovations for Poverty Action, mwhite@poverty-action.org
* Purpose: Uninstall a user-written ado-file.
* Date of last revision: April 19, 2012


*******************************MODIFY THIS!********************************
* The name of the ado command
local ado truecrypt


******************************UNDER THE HOOD*******************************
*******************************DON'T BOTHER!*******************************

loc temp : subinstr loc ado `"""' "", count(loc dq)
if `dq' {
	di as err `"{c 'g}ado' cannot contain ""'
	ex 198
}
loc letter = substr("`ado'", 1, 1)
if !regexm("`letter'", "^[a-zA-Z_]") {
	di as err "invalid command name"
	ex 198
}

loc anyerase 0
foreach dir in "`c(sysdir_personal)'" "`c(sysdir_plus)'`letter'/" {
	foreach ext in ado sthlp hlp {
		cap erase "`dir'`ado'.`ext'"
		loc anyerase = `anyerase' | !_rc
	}
}

if `anyerase' ///
	di "{txt}{cmd:`ado'} has been uninstalled."
else qui {
	di as err "`ado'.ado not found"
	ex 601
}
