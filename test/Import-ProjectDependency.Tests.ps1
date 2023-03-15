#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe Import-ProjectDependency {
    
    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsVsSolution.psd1 -Force -ErrorAction Stop
    }

    It works {
        $Projects = Import-VsProjectDependency `
            -ProjectPath C:\Users\ny36717\Repos\port-part\nexus-app\src\backend\SEM.DB\SEM.DB.sqlproj
        $Projects | Should -Not -BeNullOrEmpty
    }

    It works-in-pipeline {
        $Projects = Get-Item C:\Users\ny36717\Repos\port-part\nexus-app\src\backend\SEM.DB\SEM.DB.sqlproj | 
        Import-VsProjectDependency
        $Projects | Should -Not -BeNullOrEmpty
    }

}