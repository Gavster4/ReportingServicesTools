# Copyright (c) 2016 Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT License (MIT)

<<<<<<< HEAD
=======
<#

.SYNOPSIS
    Overrides the reference of a report or dataset to a shared data source. 

.DESCRIPTION
    Overrides the reference of a report or dataset to a shared data source. 

.PARAMETER ReportServerUri
    Specify the Report Server URL to your SQL Server Reporting Services Instance.
    Has to be provided if proxy is not provided.

.PARAMETER ReportServerCredentials
    Specify the credentials to use when connecting to your SQL Server Reporting Services Instance.

.PARAMETER Proxy
    Report server proxy to use. 
    Has to be provided if ReportServerUri is not provided.
    
.PARAMETER ItemPath 
    Path to DataSource.

.PARAMETER Password 
    Password to set.

.EXAMPLE
    
    Set-RsDataSourcePassword -ReportServerUri 'http://localhost/reportserver_sql2012' -ItemPath /DataSource1 -Password SuperSecretPassword

    Description
    -----------
    Sets the password for the datasource /DataSource1 to 'SuperSecretPassword'
#>

>>>>>>> refs/remotes/Microsoft/master

function Set-RsDataSourcePassword
{
    <#
        .SYNOPSIS
            Overwrites the password on a Datasource.
        
        .DESCRIPTION
            Overwrites the password on a Datasource.
        
        .PARAMETER Path
            Path to DataSource.
        
        .PARAMETER Password
            Password to set.
        
        .PARAMETER ReportServerUri
            Specify the Report Server URL to your SQL Server Reporting Services Instance.
            Use the "Connect-RsReportServer" function to set/update a default value.
        
        .PARAMETER Credential
            Specify the password to use when connecting to your SQL Server Reporting Services Instance.
            Use the "Connect-RsReportServer" function to set/update a default value.
        
        .PARAMETER Proxy
            Report server proxy to use.
            Use "New-RsWebServiceProxy" to generate a proxy object for reuse.
            Useful when repeatedly having to connect to multiple different Report Server.
        
        .EXAMPLE
            Set-RsDataSourcePassword -ReportServerUri 'http://localhost/reportserver_sql2012' -Path /DataSource1 -Password SuperSecretPassword
            
            Description
            -----------
            Sets the password for the datasource /DataSource1 to 'SuperSecretPassword'
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Alias('ItemPath')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] 
        $Path,

        [Parameter(Mandatory = $true)]
        [string]
        $Password,
        
        [string]
        $ReportServerUri,
        
        [Alias('ReportServerCredentials')]
        [System.Management.Automation.PSCredential]
        $Credential,
        
        $Proxy
    )
    
    Begin
    {
        $Proxy = New-RsWebServiceProxyHelper -BoundParameters $PSBoundParameters
    }
    
    Process
    {
        foreach ($item in $Path)
        {
            if ($PSCmdlet.ShouldProcess($item, "Overwrite the password"))
            {
                try
                {
                    $dataSourceContent = $Proxy.GetDataSourceContents($item)
                }
                catch
                {
                    throw (New-Object System.Exception("Failed to retrieve Datasource content: $($_.Exception.Message)", $_.Exception))
                }
                $dataSourceContent.Password = $Password
                Write-Verbose "Setting password of datasource $item"
                try
                {
                    $Proxy.SetDataSourceContents($item, $dataSourceContent)
                }
                catch
                {
                    throw (New-Object System.Exception("Failed to update Datasource content: $($_.Exception.Message)", $_.Exception))
                }
            }
        }
    }
}

