$pfolder = Get-Date -Format MMddyy
$mailboxFolder = "\Mailboxes\$pfolder"
New-PublicFolder -Name $pfolder -Path '\Mailboxes'
Enable-MailPublicFolder $mailboxFolder
Set-MailPublicFolder $mailboxFolder -HiddenFromAddressListsEnabled $true
Remove-PublicFolderClientPermission $mailboxFolder -User "Default" -AccessRights 'FolderVisible' -Confirm:$false

$junkFolder = "$mailboxFolder\Junk E-mail"
New-PublicFolder -Name 'Junk E-mail' -Path $mailboxFolder
Enable-MailPublicFolder $junkFolder
Set-MailPublicFolder $junkFolder -EmailAddressPolicyEnabled $false -EmailAddresses "$pfolder-Junk@domain.com" -HiddenFromAddressListsEnabled $true

$username = Read-Host "Enter the username"

$condition1 = Get-TransportRulePredicate SentTo
$condition1.Addresses = @(Get-Mailbox "$username@domain.com")
$condition2 = Get-TransportRulePredicate SCLOver
$condition2.SCLValue = 8
$action1 = Get-TransportRuleAction blindcopyto
$action1.Addresses = @(Get-MailPublicFolder "$pfolder-Junk@domain.com")
New-TransportRule "junk sent to $username" -Conditions @($condition1,$condition2) -Actions @($action1) -Priority 1

$action1.Addresses = @(Get-MailPublicFolder "$pfolder@domain.com")
New-TransportRule "mail sent to $username" -Conditions @($condition1) -Actions @($action1) -Priority 3

$condition1 = Get-TransportRulePredicate From
$condition1.Addresses = @(Get-Mailbox "$username@domain.com")
New-TransportRule "mail sent from $username" -Conditions @($condition1) -Actions @($action1) -Priority 3

