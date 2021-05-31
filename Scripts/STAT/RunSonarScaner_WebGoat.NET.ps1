#Repositorio
#https://github.com/tobyash86/WebGoat.NET


#region "Datos proyecto"
$PSScriptRoot= "C:\Utilidades\sonar-scanner"
$urlSonar="http://localhost:9000"
$projectVersion = "0.1"
$projectPath="D:\CodigoAnalisis\Seguridad"
$project_key="webgoat_net"

cd $projectPath
$sonarScanner = "$PSScriptRoot\bin\sonar-scanner.bat"


#endregion
#region "Análisis de dependencias"
$dependencycheck = "D:\Utilidades\pentesting\dependency-check\bin\dependency-check.bat"

$depencycheckReport = "$projectPath\WebGoat.NET\reports"
$params = "--project ""webGoatNet"" --scan ""$projectPath\WebGoat.NET\app"" --out ""$depencycheckReport"""
$checkDependencies=$true
if(!(Test-Path $depencycheckReport\dependency-check-report.html) -and $checkDependencies){
        #&$dependencycheck "$params"
        cmd.exe /C "$dependencycheck $params"
}
#endregion

$sonarArgs = @(
"-Dsonar.host.url=$urlSonar",
"-Dsonar.exclusions=**/bin/**/*.*,**/app/**/*.*,**/reports/**", # skip build files from analysis
"-Dsonar.projectVersion = $projectVersion",
"-Dsonar.projectKey=$project_key",
"-Dsonar.sources=$projectPath\WebGoat.NET",
"-Dsonar.dependencyCheck.htmlReportPath=$depencycheckReport\dependency-check-report.html",
"-Dsonar.java.binaries=.", 
"-X"
);

&$sonarScanner $sonarArgs