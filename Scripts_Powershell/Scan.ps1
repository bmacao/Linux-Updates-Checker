."[Enter Path to script]\CVE_Parser.ps1"
."[Enter Path to script]\Up_parser.ps1"

#Execute remote package cache update & get upgradable packages and version changes
#Return file with format *Package* *Current Version* *Available update version to install*
#Filename as server_libup.txt
function list_up {
    param (
        [String]$srv,
        [String]$prettyname
    )

    $secpasswd = ConvertTo-SecureString "[Private key pwd]" -AsPlainText -Force
    $ssh_user = "root"
    $mycreds = New-Object System.Management.Automation.PSCredential ($ssh_user, $secpasswd)

    $Session = New-SSHSession -ComputerName $srv -Credential $mycreds  -KeyFile "[Path to private SSH key]" -Port "[SSH port]" -AcceptKey:$true

    $y = Invoke-SSHCommand -SSHSession $Session -Command "apt-get update "  -TimeOut 600
    $x = Invoke-SSHCommand -SSHSession $Session -Command "apt-get -s upgrade | grep Inst "  -TimeOut 600

    Remove-SSHSession -Name $Session | Out-Null 

    $aux = $x[0].Output

    $aux | Out-File -FilePath $("[Enter Path to save generated files]" + $prettyname + "_libup.txt")
}

function CVE_scan {
    param (
        [String]$srv,
        [String]$prettyname
    )

    $secpasswd = ConvertTo-SecureString "[SSH private key pwd]" -AsPlainText -Force
    $ssh_user = "root"
    $mycreds = New-Object System.Management.Automation.PSCredential ($ssh_user, $secpasswd)

    $Session = New-SSHSession -ComputerName $srv -Credential $mycreds  -KeyFile "[Enter Path to private ssh key]" -Port "[SSH key]" -AcceptKey:$true

    $x = Invoke-SSHCommand -SSHSession $Session -Command "debsecan"  -TimeOut 600

    Remove-SSHSession -Name $Session | Out-Null 

    $aux = $x[0].Output

    $aux | Out-File -FilePath $("[Enter Path to save generated files]" + $prettyname + "_cveup.txt")
}

$dev_server = @{dev = 'x.x.x.x' }
$prod_server = @{
    prod1 = 'x.x.x.x'
    prod2 = 'x.x.x.x'
    prod3 = 'x.x.x.x'

}

#Alter array name for dev or prod usage
foreach ($key in $prod_server.keys) {
    list_up $prod_server[$key] $key
    CVE_scan $prod_server[$key] $key

    Parse_up $prod_server[$key] $key
    Parse_cve $prod_server[$key] $key
}
