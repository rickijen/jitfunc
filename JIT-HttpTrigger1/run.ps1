using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

########################## VARIABLES ###############################
# Subscription ID
$SubscriptionId = "7f3cc5e6-2fda-4486-b5c4-66de147a9f86"
# User Assigned Managed Identity ID - retrieve from portal and need to run New-AzRoleAssignment -ObjectId <Obj ID of Client ID>
$UAMIClientId = "0a2a4f78-c9d5-4e29-8823-ddc84f1c38c8"
# Variables for REST API calls
$Apiversion = "2020-01-01"
$JitNetworkAccessPolicyName = "default"
$AscLocation = "southcentralus"
$ResourceGroupName = "RG-JIT-Demo"
$VMName = "Target"
# Please make sure that the duration between the request's start and end times is less than 24 hours and higher than 5 minutes.
$JITAccessDuration = "PT5M"
$JITAccessPort = 22
$allowedSourceAddressPrefix = "10.0.0.4"
####################################################################

# Obtain access token for User Assigned Managed Identity, we need to include client_id of the User Assigned MI in the query
$resourceURI = "https://management.azure.com/"
$tokenAuthURI = $env:IDENTITY_ENDPOINT + "?resource=$resourceURI&client_id=$UAMIClientId&api-version=2019-08-01"

# Write-Host "=================="
# Write-Host $tokenAuthURI
# Write-Host "=================="

$tokenResponse = Invoke-RestMethod -Method Get -Headers @{"X-IDENTITY-HEADER"="$env:IDENTITY_HEADER"} -Uri $tokenAuthURI

# Initiate JIT Access Request
$JITAccessApiUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Security/locations/$AscLocation/jitNetworkAccessPolicies/$JitNetworkAccessPolicyName/initiate?api-version=$apiversion"

# Add Bearer token to header
$Headers = @{}
$Headers.Add("Authorization","$($tokenResponse.token_type) "+ " " + "$($tokenResponse.access_token)")

# JSON Request Body
$bodyJITRequest = @{
    virtualMachines = @( 
        @{
            id="/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/virtualMachines/$VMName"
            ports=@( @{
                number=$JITAccessPort
                duration=$JITAccessDuration
                allowedSourceAddressPrefix=$allowedSourceAddressPrefix
            })
        })
    justification = "Open port 22 for Apigee maintenance requested by $UAMIClientId : Duration $JITAccessDuration from $allowedSourceAddressPrefix"
} | ConvertTo-Json -Depth 4

# Write-Host "=================="
# Write-Host $bodyJITRequest
# Write-Host "=================="

$resp = Invoke-RestMethod -Method Post -Uri $JITAccessApiUri -Headers $Headers -Body $bodyJITRequest -ContentType 'application/json'

Write-Host "=====RESPONSE====="
Write-Host $resp
Write-Host "=====RESPONSE====="

$body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

if ($name) {
    $body = "Hello, $name. This HTTP triggered function executed successfully."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
