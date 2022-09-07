. (Join-Path $PSScriptRoot '.\_Settings.ps1')

$artifactUrl = Get-BCArtifactUrl `
    -Type Sandbox `
    -Select NextMajor `
    -sasToken $SecretSettings.InsiderSASToken

$ContainerName = 'bcdaily'
# $ImageName = $ContainerName

$includeTestToolkit = $true
$includeTestLibrariesOnly = $true
$includeTestFrameworkOnly = $true
$includePerformanceToolkit = $true
$forceRebuild = $true

$StartMs = Get-date

New-BcContainer `
    -accept_eula `
    -containerName $ContainerName  `
    -artifactUrl $artifactUrl `
    -Credential $ContainerCredential `
    -auth "UserPassword" `
    -updateHosts `
    -alwaysPull `
    -includeTestToolkit:$includeTestToolkit `
    -includeTestFrameworkOnly:$includeTestFrameworkOnly `
    -includeTestLibrariesOnly:$includeTestLibrariesOnly `
    -licenseFile $SecretSettings.containerLicenseFile `
    -enableTaskScheduler `
    -forceRebuild:$forceRebuild `
    -assignPremiumPlan `
    -isolation hyperv `
    -multitenant:$false `
    -myScripts @("https://raw.githubusercontent.com/tfenster/nav-docker-samples/swaggerui/AdditionalSetup.ps1")
    # -includePerformanceToolkit:$includePerformanceToolkit `
    # -imageName $imageName `

# if (!$includeTestLibrariesOnly) {
    UnInstall-BcContainerApp -containerName bccurrent -name "Tests-TestLibraries" -ErrorAction SilentlyContinue
    # UnInstall-BcContainerApp -containerName bccurrent -name "Tests-Misc"
# }

if ($includePerformanceToolkit) {
    $BcContainerCountry = Get-BcContainerCountry -containerOrImageName $ContainerName
    $BcContainerArtifactUrl = Get-BcContainerArtifactUrl -containerName $ContainerName
    $BcContainerArtifactUrl = $BcContainerArtifactUrl -replace 'https://bcartifacts.azureedge.net/', 'C:/bcartifacts.cache/'
    $BcContainerArtifactUrl = $BcContainerArtifactUrl -replace $BcContainerCountry, 'platform'
    $PerformanceToolkitSamples = (Get-ChildItem -Recurse -Path $BcContainerArtifactUrl -Filter "*Microsoft_Performance Toolkit Samples.app*").FullName
    
    if ($PerformanceToolkitSamples) {             
        Publish-BcContainerApp `
        -containerName $ContainerName `
        -appFile $PerformanceToolkitSamples `
        -install `
        -sync `
        -syncMode ForceSync
    }
}

# Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
#     Set-NAVServerConfiguration `
#         -ServerInstance "BC" `
#         -KeyName SqlLongRunningThreshold `
#         -KeyValue 20 `
#         -ApplyTo Memory

#     Invoke-Sqlcmd -Query "alter DATABASE CRONUS
#     SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE);"
#     Invoke-Sqlcmd -Query "alter DATABASE CRONUS
#     SET QUERY_STORE = ON (WAIT_STATS_CAPTURE_MODE = ON);"
# }
 
$EndMs = Get-date
Write-host "This script took $(($EndMs - $StartMs).Seconds) seconds to run"
