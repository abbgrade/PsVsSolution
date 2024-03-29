function Import-Project {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory, ValueFromPipeline )]
        [System.IO.FileInfo]
        $SolutionPath
    )

    process {
        $RawSolution = ( Get-Content $SolutionPath -Raw ) -replace "`r" -replace "`n"

        $Projects = $RawSolution | 
        Select-String -Pattern 'Project(.*?)EndProject' -AllMatches | 
        Select-Object -ExpandProperty Matches |
        Select-Object -ExpandProperty Value |
        ForEach-Object {
            $ProjectGroups = $_ | 
            Select-String -Pattern 'Project\("\{(?<typeId>.*?)\}"\) = (?<definition>.*?)EndProject' | 
            Select-Object -ExpandProperty Matches |
            Select-Object -ExpandProperty Groups

            [string] $definition = $ProjectGroups | Where-Object Name -eq definition | Select-Object -ExpandProperty Value

            [Guid] $typeId = $ProjectGroups | Where-Object Name -eq typeId | Select-Object -ExpandProperty Value

            $ProjectDetails = $definition | Select-String -Pattern '"(?<name>.*)", "(?<relativePath>.*)", "\{(?<id>.*)\}"' | 
            Select-Object -ExpandProperty Matches |
            Select-Object -ExpandProperty Groups

            [string] $name = $ProjectDetails | Where-Object Name -eq name | Select-Object -ExpandProperty Value

            $relativePath = ( $ProjectDetails | Where-Object Name -eq relativePath | Select-Object -ExpandProperty Value )
        
            [Guid] $id = $ProjectDetails | Where-Object Name -eq id | Select-Object -ExpandProperty Value

            $Project = [PSCustomObject]@{
                Id   = $id
                Name = $name
            }

            if ($relativePath -ne $name) {
                [System.IO.FileInfo] $fullPath = Join-Path $SolutionPath.Directory $relativePath
                $Project | Add-Member Path $fullPath
                $Project | Add-Member Type 'Project'
            }
            else {
                $Project | Add-Member Type 'Folder'
                $Project | Add-Member Content @()
            }

            Write-Output $Project
        }

        $RawSolution | 
        Select-String -Pattern 'GlobalSection(.*?)EndGlobalSection' -AllMatches | 
        Select-Object -ExpandProperty Matches |
        Select-Object -ExpandProperty Value |
        ForEach-Object {
            $NestedProjectGroups = $_ | 
            Select-String -Pattern 'GlobalSection\(NestedProjects\) = (?<definition>.*)EndGlobalSection' | 
            Select-Object -ExpandProperty Matches |
            Select-Object -ExpandProperty Groups

            [string] $definition = $NestedProjectGroups | Where-Object Name -eq definition | Select-Object -ExpandProperty Value

            $Nestings = $definition | Select-String -Pattern '\{(?<projectId>.*?)\} = \{(?<folderId>.*?)\}' -AllMatches | 
            Select-Object -ExpandProperty Matches |
            ForEach-Object {
                [Guid] $projectId = $_.Groups | Where-Object Name -eq projectId | Select-Object -ExpandProperty Value

                [Guid] $folderId = $_.Groups | Where-Object Name -eq folderId | Select-Object -ExpandProperty Value

                $folder = $Projects | Where-Object Id -eq $folderId

                $project = $Projects | Where-Object Id -eq $projectId

                $project | Add-Member Folder $folder
                $folder.Content += $project
            }
        }

        Write-Output $Projects
    }

}