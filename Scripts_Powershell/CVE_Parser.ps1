#Parse CVE file 
#Return json file for report presentation
#Filename as server_cve.json
function Parse_CVE {
    param (
        [String]$srv,
        [String]$prettyname     
    )

    $location = "[Enter Path to save generated files]" + $prettyname + "_cveup.txt"
    $cve_file = Get-Content($location)
    if (!$cve_file) {
        $json_init = '['
        $json_middle = ''
        $json_middle += '{"Lib": ,"data":[{"CVE": ,"LibUp": "}]},'
        $json_end = $json_init + $json_middle.Substring(0, $json_middle.Length - 1) + ']'

        $json_end | Out-File -Encoding ASCII -FilePath $("[Enter Path to save generated files]" + $prettyname + "_cve.json")
    }
    else {
        $secpasswd = ConvertTo-SecureString "[Private ssh key pwd]" -AsPlainText -Force
        $ssh_user = "[user]"
        $mycreds = New-Object System.Management.Automation.PSCredential ($ssh_user, $secpasswd)

        $json_init = '['
        $json_middle = ''

        $CVE_List = @{ }

        foreach ($line in $cve_file) {
            #Get package
            $pkg_aux = $line.split(' ')
            if ($CVE_List.ContainsKey($pkg_aux[1]) ) {
                $aux_val = $CVE_List[$pkg_aux[1]]
                if ($line -match "\(") {
                    $middle_aux = $line.split('(')
                    $final_aux = $middle_aux[1].Substring(0, $middle_aux[1].Length - 1)
                    $app_val = $aux_val + '; ' + $pkg_aux[0] + ',' + $final_aux
                }
                else {
                    $app_val = $aux_val + '; ' + $pkg_aux[0] + ','
                }
                $CVE_List[$pkg_aux[1]] = $app_val
            }
            else {
                #$aux_val = $CVE_List[$pkg_aux[1]]
                if ($line -match "\(") {
                    $middle_aux = $line.split('(')
                    $final_aux = $middle_aux[1].Substring(0, $middle_aux[1].Length - 1)
                    $app_val = $pkg_aux[0] + ',' + $final_aux
                }
                else {
                    $app_val = $pkg_aux[0]
                }
                $CVE_List[$pkg_aux[1]] = $app_val
            }
        }

        $CVE_List.GetEnumerator() | ForEach-Object {
    
            $Session = New-SSHSession -ComputerName $srv -Credential $mycreds  -KeyFile "[Path to private ssh key]" -Port "[SSH Port]" -AcceptKey:$true

            $cm_exec = "apt-get -V -s install " + $_.key + ' | grep -m1 "[[:blank:]]' + $_.key + '[[:blank:]]"'

            $y = Invoke-SSHCommand -SSHSession $Session -Command $cm_exec -TimeOut 600

            Remove-SSHSession -Name $Session | Out-Null 

            $pkg_update = $y[0].Output

            $json_middle += '{"Lib":"' + $_.key + '","data":[{"CVE":"' + $_.value + '","LibUp":"' + $pkg_update + '"}]},'
        }

        $json_end = $json_init + $json_middle.Substring(0, $json_middle.Length - 1) + ']'

        $json_end | Out-File -Encoding ASCII -FilePath $("[Enter Path to save generated files]" + $prettyname + "_cve.json")
    }
}