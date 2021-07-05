#Repositorio
#https://github.com/bkimminich/juice-shop
#git clone -b v12.7.2 https://github.com/bkimminich/juice-shop.git

#region "Datos proyecto"
$PSScriptRoot= "C:\Utilidades\sonar-scanner"
$urlSonar="http://localhost:9000"
$projectVersion = "v12.7.2"
$projectPath="D:\CodigoAnalisis\Seguridad"
$project_key="juiceshop"

cd $projectPath
$sonarScanner = "$PSScriptRoot\bin\sonar-scanner.bat"
$dependencycheck = "D:\Utilidades\pentesting\dependency-check\bin\dependency-check.bat"




#endregion

#region "Análisis de dependencias"
$depencycheckReport = "$projectPath\juice-shop\reports"
$params = "--project ""juice-shop"" --scan ""$projectPath\juice-shop\node_modules"" --out ""$depencycheckReport"""
$checkDependencies=$true
if(!(Test-Path "$depencycheckReport\dependency-check-report.html") -and $checkDependencies){
    cmd.exe /C "$dependencycheck $params"
}
#endregion

$sonarArgs = @(
"-Dsonar.host.url=$urlSonar",
"-Dsonar.exclusions=**/dist/**/*.*,**/test/**,**/reports/**", # skip build files from analysis
"-Dsonar.projectVersion = $projectVersion",
"-Dsonar.projectKey=$project_key",
"-Dsonar.sources=$projectPath\juice-shop",
"-Dsonar.dependencyCheck.htmlReportPath=$depencycheckReport\dependency-check-report.html"
"-Dsonar.java.binaries=.", 
"-X"
);


&$sonarScanner $sonarArgs