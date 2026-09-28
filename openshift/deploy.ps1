[CmdletBinding()]
param(
    [string]$Namespace = "ssc3",
    [string]$Manifest = (Join-Path $PSScriptRoot "keycloak.example.yaml"),

    [Parameter(Mandatory = $true)]
    [string]$DbUsername,

    [Parameter(Mandatory = $true)]
    [string]$TlsCertificate,

    [Parameter(Mandatory = $true)]
    [string]$TlsPrivateKey,

    [Parameter(Mandatory = $true)]
    [string]$DbCaCertificate,

    [SecureString]$DbPassword,
    [switch]$SkipWait
)

$ErrorActionPreference = "Stop"

function Assert-LastExitCode {
    param([string]$Operation)

    if ($LASTEXITCODE -ne 0) {
        throw "$Operation failed with exit code $LASTEXITCODE"
    }
}

function ConvertTo-Base64Utf8 {
    param([string]$Value)

    return [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Value))
}

function Apply-JsonResource {
    param([hashtable]$Resource)

    $Resource | ConvertTo-Json -Depth 10 -Compress | & oc apply -f -
    Assert-LastExitCode "Applying $($Resource.kind)/$($Resource.metadata.name)"
}

if (-not (Get-Command oc -ErrorAction SilentlyContinue)) {
    throw "The OpenShift CLI (oc) is not available on PATH"
}

$manifestPath = (Resolve-Path -LiteralPath $Manifest).Path
$certificatePath = (Resolve-Path -LiteralPath $TlsCertificate).Path
$privateKeyPath = (Resolve-Path -LiteralPath $TlsPrivateKey).Path
$dbCaCertificatePath = (Resolve-Path -LiteralPath $DbCaCertificate).Path

& oc whoami | Out-Null
Assert-LastExitCode "Checking the OpenShift login"

& oc get namespace $Namespace | Out-Null
Assert-LastExitCode "Checking namespace '$Namespace'"

& oc get crd keycloaks.k8s.keycloak.org | Out-Null
Assert-LastExitCode "Checking the RHBK Operator CRD"

& oc apply --dry-run=server -f $manifestPath | Out-Null
Assert-LastExitCode "Validating the Keycloak custom resource"

$manifestResource = & oc create --dry-run=client -f $manifestPath -o json | ConvertFrom-Json
Assert-LastExitCode "Reading the Keycloak custom resource"
if ($manifestResource.kind -ne "Keycloak") {
    throw "Manifest '$manifestPath' must contain exactly one Keycloak resource"
}
if ($manifestResource.metadata.namespace -ne $Namespace) {
    throw "Manifest namespace '$($manifestResource.metadata.namespace)' does not match -Namespace '$Namespace'"
}
$keycloakName = $manifestResource.metadata.name

if (-not $DbPassword) {
    $DbPassword = Read-Host "PostgreSQL password" -AsSecureString
}
if ($DbPassword.Length -eq 0) {
    throw "PostgreSQL password cannot be empty"
}

$passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($DbPassword)
try {
    $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)

    Apply-JsonResource @{
        apiVersion = "v1"
        kind = "Secret"
        metadata = @{
            name = "keycloak-db"
            namespace = $Namespace
        }
        type = "Opaque"
        data = @{
            username = ConvertTo-Base64Utf8 $DbUsername
            password = ConvertTo-Base64Utf8 $plainPassword
        }
    }
} finally {
    $plainPassword = $null
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
}

Apply-JsonResource @{
    apiVersion = "v1"
    kind = "ConfigMap"
    metadata = @{
        name = "keycloak-db-ca"
        namespace = $Namespace
    }
    data = @{
        "ca.crt" = [IO.File]::ReadAllText($dbCaCertificatePath)
    }
}

Apply-JsonResource @{
    apiVersion = "v1"
    kind = "Secret"
    metadata = @{
        name = "keycloak-tls"
        namespace = $Namespace
    }
    type = "kubernetes.io/tls"
    data = @{
        "tls.crt" = [Convert]::ToBase64String([IO.File]::ReadAllBytes($certificatePath))
        "tls.key" = [Convert]::ToBase64String([IO.File]::ReadAllBytes($privateKeyPath))
    }
}

& oc apply -f $manifestPath
Assert-LastExitCode "Applying the Keycloak custom resource"

if (-not $SkipWait) {
    & oc -n $Namespace wait --for=condition=Ready --timeout=15m "keycloak/$keycloakName"
    Assert-LastExitCode "Waiting for Keycloak to become ready"
}

& oc -n $Namespace get keycloak,pods,service,route
Assert-LastExitCode "Reading the deployment status"
