Describe 'Running PSAnalyser scripts' {

    Context 'Validating puppet-agent-installer.ps1' {

        BeforeAll {
            $analysis = Invoke-ScriptAnalyzer -Settings puppet-agent-installer.codeformating.psd1 -Path ./puppet-agent-installer.ps1
        }

        $TestCases = @()
        Get-ScriptAnalyzerRule | Select-Object -Property RuleName | Foreach-object -Process { $TestCases += @{ RuleName = $_.RuleName } }

        It -Name "Should pass <RuleName>" -TestCases $TestCases {
            param($RuleName)
            $analysis | Where-Object RuleName -EQ $RuleName -outvariable failures | Out-Default
            $failures.Count | Should -Be 0
        }
    }

    Context 'Validating puppet-agent-installer.codeformating.psd1' {

        BeforeAll {
            $analysis = Invoke-ScriptAnalyzer -Settings ./puppet-agent-installer.codeformating.psd1 -Path ./puppet-agent-installer.codeformating.psd1
        }

        $TestCases = @()
        Get-ScriptAnalyzerRule | Select-Object -Property RuleName | Foreach-object -Process { $TestCases += @{ RuleName = $_.RuleName } }

        It -Name "Should pass <RuleName>" -TestCases $TestCases {
            param($RuleName)
            $analysis | Where-Object RuleName -EQ $RuleName -outvariable failures | Out-Default
            $failures.Count | Should -Be 0
        }
    }

    Context 'Validating puppet-agent-installer.tests.ps1' {

        BeforeAll {
            $analysis = Invoke-ScriptAnalyzer -Settings ./puppet-agent-installer.codeformating.psd1 -Path ./puppet-agent-installer.tests.ps1
        }

        $TestCases = @()
        Get-ScriptAnalyzerRule | Select-Object -Property RuleName | Foreach-object -Process { $TestCases += @{ RuleName = $_.RuleName } }

        It -Name "Should pass <RuleName>" -TestCases $TestCases {
            param($RuleName)
            $analysis | Where-Object RuleName -EQ $RuleName -outvariable failures | Out-Default
            $failures.Count | Should -Be 0
        }
    }
}
