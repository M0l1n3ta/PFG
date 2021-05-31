#Repositorio
#https://github.com/WebGoat/WebGoat


#region "Datos proyecto"
$PSScriptRoot= "C:\Utilidades\sonar-scanner"
$urlSonar="http://localhost:9000"
$projectVersion = "vtest10"
$projectPath="D:\CodigoAnalisis\Seguridad"
$project_key="webgoat"

cd $projectPath
$sonarScanner = "$PSScriptRoot\bin\sonar-scanner.bat"


#endregion
$checkDependencies=$true
if(!(Test-Path "$projectPath\juice-shop\dependency-check-report.html") -and $checkDependencies){
    mvn dependency-check:check
}

$sonarArgs = @(
"-Dsonar.host.url=$urlSonar",
"-Dsonar.exclusions=**/bin/**/*.*,**/target/**/*.*,**/test/**", # skip build files from analysis
"-Dsonar.projectVersion = $projectVersion",
"-Dsonar.projectKey=$project_key",
"-Dsonar.sources=$projectPath\WebGoat",
"-Dsonar.dependencyCheck.htmlReportPath=$projectPath\WebGoat\webgoat-container\target\dependency-check-report.html",
"-Dsonar.java.binaries=.", 
"-X"

# it is possible to specify absolute path to the MSBuild code analysis report or directory where file matching *StaticCodeAnalysis.Results.xml resides, by default plugin will try to find it in the base directory's subdirectories
#"-Dsonar.sql.tsql.ms.report=$PSScriptRoot\src\ExampleDatabase\ExampleDatabase\bin\Debug"

);


#
&$sonarScanner $sonarArgs