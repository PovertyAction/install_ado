* Author: Matthew White, Innovations for Poverty Action, mwhite@poverty-action.org
* Purpose: Install a user-written ado-file.
* Date of last revision: January 23, 2013


*********************************MODIFY THESE!**********************************

* The name of the ado command
local ado bcstats
* The directory that contains the ado-file
local dir C:\Users\matthew\Desktop
* Advanced: 1 to overwrite the ado-file if it already exists and 0 otherwise;
* default is 0.
local replace 0
* Advanced: 0 to install in the PLUS system directory and 1 to install in the
* PERSONAL system directory; default is 0.
local personal 0


*********************************UNDER THE HOOD*********************************
*********************************DON'T BOTHER!**********************************

foreach loc in ado dir replace personal {
	* "dq" for "double quote"
	loc temp : subinstr loc `loc' `"""' "", count(loc dq)
	if `dq' {
		di as err "{c 'g}`loc'' invalid"
		ex 198
	}
}

conf f "`dir'/`ado'.ado"

if !regexm(substr("`ado'", 1, 1), "^[a-zA-z_]") {
	di as err "`ado' is an invalid command name"
	ex 198
}

foreach loc in replace personal {
	if !inlist("``loc''", "0", "1") {
		di as err "{c 'g}`loc'' must be 0 or 1"
		ex 198
	}
}

if !`personal' ///
	loc outdir "`c(sysdir_plus)'`=substr("`ado'", 1, 1)'/"
else ///
	loc outdir "`c(sysdir_personal)'"

mata:
outdir = st_local("outdir")
// "el" for "element"; "els" for "elements."
el = els = ""
while (outdir != "") {
	pathsplit(outdir, outdir, el)
	els = `"""' + el + `"" "' + els
}
st_local("els", els)
end
foreach el of loc els {
	cap mkdir "`prevels'`el'"
	* "prevels" for "previous elements"
	loc prevels `prevels'`el'/
}

if !`replace' ///
	conf new f "`outdir'`ado'.ado"

foreach ext in ado sthlp hlp {
	cap erase "`outdir'`ado'.`ext'"
	cap copy "`dir'/`ado'.`ext'" "`outdir'`ado'.`ext'"
}

di as txt "Installation of {cmd:`ado'} complete."
