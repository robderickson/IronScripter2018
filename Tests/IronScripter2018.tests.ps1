# From Kevin Marquette's blog
$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$ModuleName = (Get-ChildItem $ProjectRoot | Select-Object -first 1).Parent | Select-Object -ExpandProperty Name
$ModuleRoot = "$($ProjectRoot.Path)\Src"

Describe "General project validation: $ModuleName" {

    $scripts = Get-ChildItem $ModuleRoot -Include *.ps1,$.psm1,*.psd1 -recurse

    $TestCase = $scripts | Foreach-Object {@{file = $_}}

    It "Script <file> should be valid PowerShell" -TestCases $TestCase {
        param($file)

        $file.fullname | Should Exist

        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }

    It "Module '$ModuleName' can import cleanly" {
        { Import-Module (Join-Path $ModuleRoot "$ModuleName.psm1") -force } | Should Not Throw
    }
}