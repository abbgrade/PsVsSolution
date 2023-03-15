function Import-ProjectDependency {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory, ValueFromPipeline )]
        [System.IO.FileInfo]
        $ProjectPath
    )

    process {
        [string] $ProjectName = $ProjectPath.BaseName
        Select-Xml -Path $ProjectPath.FullName -XPath '//msbuild:ProjectReference' -Namespace @{
            msbuild = "http://schemas.microsoft.com/developer/msbuild/2003"
        } | ForEach-Object {
            [PSCustomObject] @{
                Object     = $ProjectName.Replace('.', '')
                Dependency = [string] $_.Node.Name.Replace('.', '')
            } | Write-Output
        }
    }

}