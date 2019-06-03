#Parse update file 
#Return file with reformat *Package* *Current Version* *Available update version to install*
#Filename as server_up.txt
function Parse_up {
    param (
        [String]$srv,
        [String]$prettyname        
    )
    
    $location = "[Enter Path to save generated files]" + $prettyname + "_libup.txt"
    

    if ((get-childitem $location).length -eq 0) {
        Add-Content -Path $("[Enter Path to save generated files]" + $prettyname + "_up.txt") -Value "0"
    }
    else {
        $up_file = Get-Content($location)
        foreach ($line in $up_file) {
            $pars1 = $line.Split(" ")

            $pars_aux = $pars1[2].Substring(0, $pars1[2].Length - 1)
            $pars2 = $pars_aux.Substring(1)

            $pars_aux = $pars1[3]
            $pars3 = $pars_aux.Substring(1)

            $pars = $pars1[1] + ";" + $pars2 + ";" + $pars3
            Add-Content -Path $("[Enter Path to save generated files]" + $prettyname + "_up.txt") -Value $pars+";1"
        }

    }
}