2015-09-09 Release 1.1.0:
- Install Chocolatey itself / ensure Chocolatey is installed (PUP-1691)
- Adds custom facts for chocolateyversion and choco_install_path

2015-07-23 Release 1.0.2:
- Fixes [#71](https://github.com/chocolatey/puppet-chocolatey/issues/71) - Allow `ensure => $version` to work with already installed packages

2015-07-01 Release 1.0.1:
- Fixes [#66](https://github.com/chocolatey/puppet-chocolatey/issues/66) - Check for choco existence more comprehensively

2015-06-08 Release 1.0.0:
- No change, bumping to 1.0.0

2015-05-22 Release 0.5.3:
- Fix manifest issue
- Fix choco path issue
- Update ReadMe - fix/clarify how options with quotes need to be passed.

2015-04-23 Release 0.5.2:
- Update ReadMe
- Add support for Windows 10.
- Fixes [#56](https://github.com/chocolatey/puppet-chocolatey/pull/56) - Avoiding puppet returning 2 instead of 0 when there are no changes to be done.

2015-03-31 Release 0.5.1
- Fixes [#54](https://github.com/chocolatey/puppet-chocolatey/issues/54) - Blocking: Linux masters throw error if module is present

2015-03-30 Release 0.5.0
- Provider enhancements
- Better docs
- Works with both compiled and powershell Chocolatey clients
- Fixes #50 - work with newer compiled Chocolatey client (0.9.9+)
- Fixes #43 - check for installed packages is case sensitive
- Fixes #18 - The OS handle's position is not what FileStream expected.
- Fixes #52 - Document best way to pass options with spaces (#15 also related)
- Fixes #26 - Document Chocolatey needs to be installed by other means
