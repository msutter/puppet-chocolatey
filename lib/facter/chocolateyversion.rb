Facter.add('chocolateyversion') do
  confine :kernel => 'windows'
  setcode do
    version = nil
    chocopath = Facter.value(:choco_install_path)
    if File.exist? chocopath
      command = "#{chocopath}\\bin\\choco.exe -v"
      command_result = Facter::Util::Resolution.exec(command)
      old_choco_message = 'Please run chocolatey /? or chocolatey help - chocolatey v'
      version = command_result.gsub(old_choco_message,'').strip
    end
    version
  end
end
