* Author: Matthew White, Innovations for Poverty Action, mwhite@poverty-action.org
* Modified: Rohit Naimpally, J-PAL, rnaimpally@povertyactionlab.org, Harrison Diamond Pollock, IPA, hpollock@poverty-action.org
* Purpose: Install an ado-file. Modified version installs all ado files in "adolist"
* Date of last revision: September 10, 2014


*********************************MODIFY THESE!**********************************

* The directory that contains the ado-file(s) to install
local dir C:\Users\matthew\Desktop
* Optional: The name of the single ado command to install.
* The ado-file must exist in `dir'.
* If left blank, all ado-files in `dir' are installed.
local cmdname

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
if "`cmdname'" != "" {
	* Check `cmdname'.
	conf f "`dir'/`cmdname'.ado"

	loc adolist "`cmdname'"
}
else {
	loc adolist : dir "`dir'" file "*.ado"
	loc adolist : subinstr loc adolist ".ado" "", all

	if !`:list sizeof adolist' qui {
		noi di as txt _n "No ado-files found."
		ex
	}
}

* Check `adolist'.
foreach ado of loc adolist {
	if !regexm(substr("`ado'", 1, 1), "^[a-zA-z_]") {
		di as err "`ado' is an invalid command name"
		ex 198
	}
}

* Install the ado-files of `adolist'.
foreach ado of loc adolist {
	cap noi {
		if !`personal' ///
			loc outdir "`c(sysdir_plus)'`=substr("`ado'", 1, 1)'/"
		else ///
			loc outdir "`c(sysdir_personal)'"

		mata {
		outdir = st_local("outdir")
		// "el" for "element"; "els" for "elements."
		el = els = ""
		while (outdir != "") {
			pathsplit(outdir, outdir, el)
			els = `"""' + el + `"" "' + els
		}
		st_local("els", els)
		}
		loc prevels
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
	}
}
