param(
    [string]$Image = "keycloak-custom:dev",
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"
$deploymentRoot = $PSScriptRoot
$providerRoot = [System.IO.Path]::GetFullPath((Join-Path $deploymentRoot "..\keycloak-custom-provider"))
$artifact = Join-Path $providerRoot "target\keycloak-custom-provider-1.0-SNAPSHOT.jar"
$imageArtifact = Join-Path $deploymentRoot "providers\keycloak-custom-provider.jar"
$maven = Get-Command mvn -ErrorAction SilentlyContinue
if ($null -eq $maven) {
    $maven = Get-ChildItem -Path (Join-Path $HOME ".m2\wrapper\dists") -Filter mvn.cmd -Recurse -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1
}
if ($null -eq $maven) {
    throw "Maven was not found on PATH or under ~/.m2/wrapper/dists"
}
$mavenExecutable = if ($maven.Source) { $maven.Source } else { $maven.FullName }

Push-Location $providerRoot
try {
    $mavenArgs = if ($SkipTests) { @("clean", "package", "-DskipTests") } else { @("clean", "verify") }
    & $mavenExecutable @mavenArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Maven build failed with exit code $LASTEXITCODE"
    }
} finally {
    Pop-Location
}

Copy-Item -LiteralPath $artifact -Destination $imageArtifact -Force
$sourceHash = (Get-FileHash -LiteralPath $artifact -Algorithm SHA256).Hash
$imageHash = (Get-FileHash -LiteralPath $imageArtifact -Algorithm SHA256).Hash
if ($sourceHash -ne $imageHash) {
    throw "Provider artifact checksum mismatch after copy"
}

Push-Location $deploymentRoot
try {
    & docker build --pull --tag $Image .
    if ($LASTEXITCODE -ne 0) {
        throw "Container image build failed with exit code $LASTEXITCODE"
    }
} finally {
    Pop-Location
}

Write-Host "Built $Image with provider SHA256 $sourceHash"
