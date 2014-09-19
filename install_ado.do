* Purpose: Install an ado-file. Modified version installs all ado files in "adolist"


*********************************MODIFY THESE!**********************************

* The directory that contains the ado-file(s) to install
local dir C:\Users\matthew\Desktop

* Advanced: 1 to overwrite the ado-file if it already exists and 0 otherwise;
* default is 0.
local replace 0
* Advanced: 0 to install in the PLUS system directory and 1 to install in the
* PERSONAL system directory; default is 0.
local personal 0


*********************************UNDER THE HOOD*********************************
*********************************DON'T BOTHER!**********************************

* Check `replace' and `personal'.
foreach loc in replace personal {
	if !inlist("``loc''", "0", "1") {
		di as err "{c 'g}`loc'' must be 0 or 1"
		ex 198
	}
}

* Define `adolist', the list of the names of the ado-file commands to install.
if !`:length loc dir' ///
	loc dir .
loc adolist : dir "`dir'" file "*.ado"
loc adolist : subinstr loc adolist ".ado" "", all
if !`:list sizeof adolist' qui {
	noi di as txt _n "No ado-files found."
	ex
}

* Check `adolist'.
foreach ado of loc adolist {
	if !regexm(substr("`ado'", 1, 1), "^[a-zA-z_]") {
		di as err "`ado' is an invalid command name"
		ex 198
	}
}

* Create the system directory if necessary.
if !`personal' ///
	loc sysdir "`c(sysdir_plus)'"
else ///
	loc sysdir "`c(sysdir_personal)'"
mata:
sysdir = st_local("sysdir")
// "el" for "element"; "els" for "elements."
el = els = ""
while (sysdir != "") {
	pathsplit(sysdir, sysdir, el)
	els = `"""' + el + `"" "' + els
}
st_local("els", els)
end
foreach el of loc els {
	cap mkdir "`prevels'`el'"
	* "prevels" for "previous elements"
	loc prevels `prevels'`el'/
}

* Install the ado-files of `adolist'.
foreach ado of loc adolist {
	loc outdir "`sysdir'"
	if !`personal' {
		loc outdir "`outdir'`=substr("`ado'", 1, 1)'/"
		cap mkdir "`outdir'"
	}

	if `replace' ///
		loc copy 1
	else {
		cap noi conf new f "`outdir'`ado'.ado"
		loc copy = !_rc
	}

	if `copy' {
		foreach ext in ado sthlp hlp {
			cap erase "`outdir'`ado'.`ext'"
			cap copy "`dir'/`ado'.`ext'" "`outdir'`ado'.`ext'"
		}

		di as txt "Installation of {cmd:`ado'} complete."
	}
}
