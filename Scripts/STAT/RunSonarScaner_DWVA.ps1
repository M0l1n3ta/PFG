

#Repositrio
#https://github.com/digininja/DVWA.git
#git clone -b 2.0.1 https://github.com/digininja/DVWA.git

#regin "Datos projecto
$PSScriptRoot= "C:\Utilidades\sonar-scanner"
$urlSonar="http://localhost:9000"
$projectVersion = "2.0.1"
$projectPath="D:\CodigoAnalisis\Seguridad"
$project_key="dvwa"

cd $projectPath
$sonarScanner = "$PSScriptRoot\bin\sonar-scanner.bat"

$sonarArgs = @(
"-Dsonar.host.url=$urlSonar",
#"-Dsonar.exclusions=**/bin/**/*.*,**/obj/**/*.*,**/*.sqlproj", # skip build files from analysis
"-Dsonar.projectVersion = $projectVersion",
"-Dsonar.projectKey=$project_key",
"-Dsonar.sources=$projectPath\DVWA",
"-Dsonar.java.binaries=.", 
"-X"
);


#
&$sonarScanner $sonarArgs