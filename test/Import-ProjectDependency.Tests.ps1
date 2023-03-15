#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe Import-ProjectDependency {
    
    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsVsSolution.psd1 -Force -ErrorAction Stop
    }

    Context SqlProject {

        BeforeAll {
            $ProjectPath = 'C:\Users\ny36717\Repos\port-part\nexus-app\src\backend\SEM.DB\SEM.DB.sqlproj'
        }

        It works {
            $Dependency = Import-VsProjectDependency `
                -ProjectPath $ProjectPath
            $Dependency | Should -Not -BeNullOrEmpty
            $Dependency.Count | Should -Be 2
            $Dependency[0].Project | Should -Not -BeNullOrEmpty
            $Dependency[0].Project.Id | Should -Not -BeNullOrEmpty
            $Dependency[0].Project.Name | Should -Not -BeNullOrEmpty
            $Dependency[0].Project.Path | Should -Not -BeNullOrEmpty
            $Dependency[0].Dependency | Should -Not -BeNullOrEmpty
            $Dependency[0].Dependency.Id | Should -Not -BeNullOrEmpty
            $Dependency[0].Dependency.Name | Should -Not -BeNullOrEmpty
            $Dependency[0].Dependency.Path | Should -Not -BeNullOrEmpty
        }

        It works-in-pipeline {
            $Dependency = Get-Item $ProjectPath | 
            Import-VsProjectDependency
            $Dependency | Should -Not -BeNullOrEmpty
            $Dependency.Count | Should -Be 2
            $Dependency[0].Project | Should -Not -BeNullOrEmpty
            $Dependency[0].Project.Id | Should -Not -BeNullOrEmpty
            $Dependency[0].Project.Name | Should -Not -BeNullOrEmpty
            $Dependency[0].Project.Path | Should -Not -BeNullOrEmpty
            $Dependency[0].Dependency | Should -Not -BeNullOrEmpty
            $Dependency[0].Dependency.Id | Should -Not -BeNullOrEmpty
            $Dependency[0].Dependency.Name | Should -Not -BeNullOrEmpty
            $Dependency[0].Dependency.Path | Should -Not -BeNullOrEmpty
        }

    }

}