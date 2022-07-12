#Change the following variables:
$Organization = "contoso.onmicrosoft.com"
$AppId = "1111111-1111-1111-1111-1111111111"
$Tenantid = "1111111-1111-1111-1111-1111111111""
$Thumbprint = "123456789abcdefghijklmnopqrstuvwxyz"

#Exchange Online
Connect-ExchangeOnline -CertificateThumbprint $Thumbprint -AppId $AppId -ShowBanner:$false -Organization $Organization 

#Connect to Graph
Connect-Graph -TenantId $Tenantid -AppId  $AppId -CertificateThumbprint $Thumbprint

#Get all users with a business phone number
$OrgContacts = Get-MgUser | ?{$_.BusinessPhones -ne $Null}

#Get all users with mailboxes
$OrgUsers = Get-ExoMailbox -RecipientTypeDetails UserMailbox | Select ExternalDirectoryObjectId, DisplayName, UserPrincipalName

#Loop through all users with mailboxes
ForEach ($User in $OrgUsers) {
    #Loop through all contacts with a phone number
    ForEach ($Contact in $OrgContacts) {
        #Set Contact Values
        $Phone = $Contact.BusinessPhones
        $Company = $Contact.CompanyName
        $Department = $Contact.Department
        $DisplayName = $Contact.DisplayName
        $Title = $Contact.JobTitle
        $First = $Contact.GivenName
        $Last = $Contact.Surname
        $Email = $Contact.UserPrincipalName
        $graphEmail = @{Address = $Email; Name = $DisplayName}
        #Search the current loop user to see if the contact already exists
        $Result = Get-MgUserContact -UserID $User.ExternalDirectoryObjectId -Filter "emailAddresses/any(a:a/address eq '$Email')"
            #If contact does NOT exist
            if ($Result.count -eq 0){
                New-MgUserContact -UserId $user.ExternalDirectoryObjectId -BusinessPhones $Phone -CompanyName $Company -Department $Department -DisplayName $DisplayName -GivenName $First -JobTitle $Title -Surname $Last -EmailAddresses $graphEmail
            }
            #If contact does exist
            elseif ($Result.count -eq 1){
                Update-MgUserContact -UserId $user.ExternalDirectoryObjectId -ContactId $Result.Id -BusinessPhones $Phone
            }
            #If more than one result returned
            else{
                write-host "Error"
            }
    }
}
