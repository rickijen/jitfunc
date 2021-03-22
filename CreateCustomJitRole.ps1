#! Get Virtual Machine Contributor Role Definition 
$role = Get-AzRoleDefinition "Virtual Machine Contributor"
$role.Id = $null
$role.Name = "JIT VM Access User"
$role.Description = "Users that can enable access to Azure Virtual Machines."
$role.Actions.Clear()

#
# Define role actions & scopes
#
$role.Actions.Add("Microsoft.Security/locations/jitNetworkAccessPolicies/initiate/action")
$role.Actions.Add("Microsoft.Security/locations/jitNetworkAccessPolicies/*/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/read")
$role.Actions.Add("Microsoft.Network/networkInterfaces/*/read")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/7f3cc5e6-2fda-4486-b5c4-66de147a9f86/resourceGroups/RG-JIT-Demo/providers/Microsoft.Security/locations/southcentralus/jitNetworkAccessPolicies/default")
$role.AssignableScopes.Add("/subscriptions/7f3cc5e6-2fda-4486-b5c4-66de147a9f86/resourceGroups/RG-JIT-Demo/providers/Microsoft.Compute/virtualMachines/Target")

New-AzRoleDefinition -Role $role

#
# Assign the role to the AAD Object ID (must be an ServicePrincipal Type, cannot be Application)
# User Assigned Managed Identity is considered an SP
#
New-AzRoleAssignment -ObjectId ff95bfe6-a374-4abb-b06c-2c7a1f4c3514 -RoleDefinitionName "JIT VM Access User" -Scope "/subscriptions/7f3cc5e6-2fda-4486-b5c4-66de147a9f86/resourceGroups/RG-JIT-Demo/providers/Microsoft.Security/locations/southcentralus/jitNetworkAccessPolicies/default"
New-AzRoleAssignment -ObjectId ff95bfe6-a374-4abb-b06c-2c7a1f4c3514 -RoleDefinitionName "JIT VM Access User" -Scope "/subscriptions/7f3cc5e6-2fda-4486-b5c4-66de147a9f86/resourceGroups/RG-JIT-Demo/providers/Microsoft.Compute/virtualMachines/Target"
