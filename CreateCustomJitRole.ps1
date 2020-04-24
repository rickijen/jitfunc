#! Get Virtual Machine Contributor Role Definition 
$role = Get-AzRoleDefinition "Virtual Machine Contributor"
$role.Id = $null
$role.Name = "Just In Time VM access User"
$role.Description = "Users that can enable access to Azure Virtual Machines."
$role.Actions.Clear()

#
# Permissions according to https://docs.microsoft.com/en-us/azure/security-center/security-center-just-in-time#permissions-needed-to-configure-and-use-jit
#
$role.Actions.Add("Microsoft.Security/locations/jitNetworkAccessPolicies/initiate/action")
$role.Actions.Add("Microsoft.Security/locations/jitNetworkAccessPolicies/*/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/read")
$role.Actions.Add("Microsoft.Network/networkInterfaces/*/read")

$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/7f3cc5e6-2fda-4486-b5c4-66de147a9f86/resourceGroups/JIT-demo/providers/Microsoft.Security/locations/westus/jitNetworkAccessPolicies/default")
$role.AssignableScopes.Add("/subscriptions/7f3cc5e6-2fda-4486-b5c4-66de147a9f86/resourceGroups/JIT-demo/providers/Microsoft.Compute/virtualMachines/VM-Target")
$role.AssignableScopes.Add("/subscriptions/7f3cc5e6-2fda-4486-b5c4-66de147a9f86/resourceGroups/JIT-demo/providers/Microsoft.Compute/virtualMachines/VM-Mgmt")

New-AzRoleDefinition -Role $role

#
# Assign the role to the AAD Object ID (must be an ServicePrincipal Type, cannot be Application)
# User Assigned Managed Identity is considered an SP
#
New-AzRoleAssignment -ObjectId e2a5ffc8-064b-41af-b038-e1d6c846e669 -RoleDefinitionName "Just In Time VM access User" -Scope "/subscriptions/7f3cc5e6-2fda-4486-b5c4-66de147a9f86/resourceGroups/JIT-demo/providers/Microsoft.Security/locations/westus/jitNetworkAccessPolicies/default"
New-AzRoleAssignment -ObjectId e2a5ffc8-064b-41af-b038-e1d6c846e669 -RoleDefinitionName "Just In Time VM access User" -Scope "/subscriptions/7f3cc5e6-2fda-4486-b5c4-66de147a9f86/resourceGroups/JIT-demo/providers/Microsoft.Compute/virtualMachines/VM-Target"