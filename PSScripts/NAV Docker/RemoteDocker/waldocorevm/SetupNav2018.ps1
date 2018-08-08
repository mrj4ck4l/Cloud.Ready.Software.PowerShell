. (Join-Path $PSScriptRoot '.\_Settings.ps1')

$Containername = 'nav2018'
$ContainerAdditionalParameters += "--ip 172.21.31.12"

#$ContainerDockerImage = 'microsoft/dynamics-nav:2018'
$ContainerDockerImage = 'microsoft/dynamics-nav:2018-be'
$ContainerAlwaysPull = $true

New-RDHNAVContainer `
    -DockerHost $DockerHost `
    -DockerHostCredentials $DockerHostCredentials `
    -DockerHostUseSSL:$DockerHostUseSSL `
    -DockerHostSessionOption $DockerHostSessionOption `
    -ContainerDockerImage $ContainerDockerImage `
    -ContainerName $Containername `
    -ContainerLicenseFile $SecretSettings.containerLicenseFile `
    -ContainerCredential $ContainerCredential `
    -ContainerAlwaysPull:$false `
    -ContainerAdditionalParameters $ContainerAdditionalParameters `
    -doNotExportObjectsToText 