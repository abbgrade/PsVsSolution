function Import-ProjectDependency {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory, ValueFromPipeline )]
        [System.IO.FileInfo]
        $ProjectPath
    )

    begin {
        $MsBuildNamespace = 'http://schemas.microsoft.com/developer/msbuild/2003'
    }

    process {
        [string] $ProjectName = $ProjectPath.BaseName

        [guid] $ProjectId = Select-Xml -Path $ProjectPath.FullName -XPath '//msbuild:ProjectGuid' -Namespace @{ msbuild = $MsBuildNamespace } | 
        Select-Object -ExpandProperty Node |
        Select-Object -ExpandProperty InnerText |
        ForEach-Object {
            $_.Replace('{', '').Replace('}', '')
        }

        Select-Xml -Path $ProjectPath.FullName -XPath '//msbuild:ProjectReference' -Namespace @{ msbuild = $MsBuildNamespace } | 
        ForEach-Object {
            $Project = [PSCustomObject]@{
                Id   = $ProjectId
                Name = $ProjectName
                Path = $ProjectPath
            }
            $Dependency = [PSCustomObject]@{
                Id   = [guid] $_.Node.Project.Replace('{', '').Replace('}', '')
                Name = [string] $_.Node.Name
                Path = [System.IO.FileInfo] ( Join-Path $ProjectPath.Directory $_.Node.Include )
            }
            [PSCustomObject] @{
                Project    = $Project
                Dependency = $Dependency
            } | Write-Output
        }
    }

}