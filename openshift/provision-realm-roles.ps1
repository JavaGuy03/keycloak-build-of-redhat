param(
    [Parameter(Mandatory = $true)]
    [string]$KeycloakUrl,

    [Parameter(Mandatory = $true)]
    [string]$Realm,

    [string]$RolesFile = (Join-Path $PSScriptRoot "roles.example.txt")
)

$ErrorActionPreference = "Stop"
$adminUsername = $env:KEYCLOAK_ADMIN_USERNAME
$adminPassword = $env:KEYCLOAK_ADMIN_PASSWORD
if ([string]::IsNullOrWhiteSpace($adminUsername) -or [string]::IsNullOrWhiteSpace($adminPassword)) {
    throw "Set KEYCLOAK_ADMIN_USERNAME and KEYCLOAK_ADMIN_PASSWORD in the process environment"
}

$baseUrl = $KeycloakUrl.TrimEnd("/")
$token = Invoke-RestMethod -Method Post `
    -Uri "$baseUrl/realms/master/protocol/openid-connect/token" `
    -ContentType "application/x-www-form-urlencoded" `
    -Body @{
        client_id  = "admin-cli"
        grant_type = "password"
        username   = $adminUsername
        password   = $adminPassword
    }
$headers = @{ Authorization = "Bearer $($token.access_token)" }
$realmPath = [Uri]::EscapeDataString($Realm)

$roles = Get-Content -LiteralPath $RolesFile |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and !$_.StartsWith("#") } |
    ForEach-Object { $_.ToUpperInvariant() } |
    Sort-Object -Unique

foreach ($role in $roles) {
    $rolePath = [Uri]::EscapeDataString($role)
    try {
        Invoke-RestMethod -Method Get -Uri "$baseUrl/admin/realms/$realmPath/roles/$rolePath" -Headers $headers | Out-Null
        Write-Host "Role exists: $role"
        continue
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -ne 404) {
            throw
        }
    }

    Invoke-RestMethod -Method Post `
        -Uri "$baseUrl/admin/realms/$realmPath/roles" `
        -Headers $headers `
        -ContentType "application/json" `
        -Body (@{ name = $role } | ConvertTo-Json) | Out-Null
    Write-Host "Created role: $role"
}
