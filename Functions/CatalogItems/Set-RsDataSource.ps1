# Copyright (c) 2016 Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT License (MIT)


function Set-RsDataSource
{
    <#
<<<<<<< HEAD
        .SYNOPSIS
            This script updates information about a data source on Report Server.
        
        .DESCRIPTION
            This script updates information about a data source on Report Server that was retrieved using Get-RsDataSource.
        
        .PARAMETER Path
            Specify the path to the data source.
        
        .PARAMETER DataSourceDefinition
            Specify the data source definition of the Data Source to update
        
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
            Set-RsDataSource -Path '/path/to/my/datasource' -DataSourceDefinition $dataSourceDefinition
            Description
            -----------
            This command will establish a connection to the Report Server located at http://localhost/reportserver using current user's credentials and update the details of data source found at '/path/to/my/datasource'.
        
        .EXAMPLE
            Set-RsDataSource -ReportServerUri 'http://remote-machine:8080/reportserver_sql16' -Path '/path/to/my/datasource' -DataSourceDefinition $dataSourceDefinition
            Description
            -----------
            This command will establish a connection to the Report Server located at http://remote-machine:8080/reportserver_sql16 using current user's credentials and update the details of data source found at '/path/to/my/datasource'.
=======
    .SYNOPSIS
        This script updates information about a data source on Report Server.

    .DESCRIPTION
        This script updates information about a data source on Report Server that was retrieved using Get-RsDataSource.  

    .PARAMETER ReportServerUri
        Specify the Report Server URL to your SQL Server Reporting Services Instance.

    .PARAMETER ReportServerCredentials
        Specify the credentials to use when connecting to your SQL Server Reporting Services Instance.

    .PARAMETER Proxy
        Specify the Proxy to use when communicating with Reporting Services server. If Proxy is not specified, connection to Report Server will be created using ReportServerUri, ReportServerUsername and ReportServerPassword.

    .PARAMETER DataSourcePath
        Specify the path to the data source.

    .PARAMETER DataSourceDefinition
        Specify the data source definition of the Data Source to update 

    .EXAMPLE 
        Set-RsDataSource -DataSourcePath '/path/to/my/datasource' -DataSourceDefinition $dataSourceDefinition 
        Description
        -----------
        This command will establish a connection to the Report Server located at http://localhost/reportserver using current user's credentials and update the details of data source found at '/path/to/my/datasource'.

    .EXAMPLE 
        Set-RsDataSource -ReportServerUri 'http://remote-machine:8080/reportserver_sql16' -DataSourcePath '/path/to/my/datasource' -DataSourceDefinition $dataSourceDefinition 
        Description
        -----------
        This command will establish a connection to the Report Server located at http://remote-machine:8080/reportserver_sql16 using current user's credentials and update the details of data source found at '/path/to/my/datasource'.		
>>>>>>> refs/remotes/Microsoft/master
    #>
    
    [cmdletbinding()]
    param
    (
        [Alias('DataSourcePath','ItemPath')]
        [Parameter(Mandatory = $True)]
        [string]
        $Path,
        
        [Parameter(Mandatory = $True)]
        $DataSourceDefinition,
        
        [string]
        $ReportServerUri,
        
        [Alias('ReportServerCredentials')]
        [System.Management.Automation.PSCredential]
        $Credential,
        
        $Proxy
    )
    
    if ($PSCmdlet.ShouldProcess($Path, "Applying new definition"))
    {
        $Proxy = New-RsWebServiceProxyHelper -BoundParameters $PSBoundParameters
        
        #region Input Validation
        if ($DataSourceDefinition.GetType().Name -ne 'DataSourceDefinition')
        {
            throw 'Invalid object specified for DataSourceDefinition!'
        }
        
        if ($DataSourceDefinition.CredentialRetrieval -like 'STORE')
        {
            if (-not ($DataSourceDefinition.UserName))
            {
                throw "Username and password must be specified when CredentialRetrieval is set to Store!"
            }
        }
        else
        {
            if ($DataSourceDefinition.UserName -or $DataSourceDefinition.Password)
            {
                throw "Username and/or password can be specified only when CredentialRetrieval is Store!"
            }
            
            if ($DataSourceDefinition.ImpersonateUser)
            {
                throw "ImpersonateUser can be set to true only when CredentialRetrieval is Store!"
            }
        }
        #endregion Input Validation
        
        # validating extension specified by the user is supported
        Write-Verbose "Retrieving data extensions..."
        try
        {
            if ($Proxy.ListExtensions("Data").Name -notcontains $DataSourceDefinition.Extension)
            {
                throw "Extension specified is not supported by the report server!"
            }
        }
        catch
        {
            throw (New-Object System.Exception("Failed to retrieve list of supported extensions from Report Server: $($_.Exception.Message)", $_.Exception))
        }
        
        
        try
        {
            Write-Verbose "Updating data source..."
            $Proxy.SetDataSourceContents($Path, $DataSourceDefinition)
            Write-Verbose "Data source updated successfully!"
        }
        catch
        {
            throw (New-Object System.Exception("Exception occurred while updating data source! $($_.Exception.Message)", $_.Exception))
        }
    }
}
