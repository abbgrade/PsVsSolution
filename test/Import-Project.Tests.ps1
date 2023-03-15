#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe Import-Project {
    
    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsVsSolution.psd1 -Force -ErrorAction Stop
    }

    It works {
        $Projects = Import-VsProject `
            -SolutionPath C:\Users\ny36717\Repos\port-part\nexus-app\src\backend\DataRepository.sln
        $Projects | Should -Not -BeNullOrEmpty
    }

    It works-in-pipeline {
        $Projects = Get-Item C:\Users\ny36717\Repos\port-part\nexus-app\src\backend\DataRepository.sln | 
        Import-VsProject
        $Projects | Should -Not -BeNullOrEmpty
    }

}