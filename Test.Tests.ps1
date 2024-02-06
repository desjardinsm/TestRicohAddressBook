Describe 'Test Describe' {
    It 'Test Test' {
        1 | Should -Be 1
    }

    It 'Test Failure' {
        1 | Should -Be 2
    }

    It 'Test Failure2' {
        2 | Should -Be 1
    }

    It 'Test Success' {
        1 | Should -Be 1
    }
}
