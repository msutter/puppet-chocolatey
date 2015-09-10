define chocolatey::config::source (
  $ensure      = 'present',
  $source_name = $title,
  $location    = undef,
  $enable      = true,
  $user_name   = undef,
  $password    = undef
) {

  $_fact = $::choco_sources

  # Destringify facts if needed
  if is_string($_fact) {
    $_yaml = regsubst($_fact,'=>',': ', 'G')
    $_destringified_fact = parseyaml($_yaml)
  } else {
    $_destringified_fact = $_fact
  }

  $_fact_choco_sources = $_destringified_fact

  validate_hash($_fact_choco_sources)

  # define some bool used for conditions sets
  $_choco_exe_path      = "${::choco_install_path}\\bin\\choco.exe"
  $_new_choco           = versioncmp($::chocolateyversion, '0.9.9') >= 0
  $_source_exists       = has_key($_fact_choco_sources, $source_name)
  $_status_enabled      = $_source_exists and $_fact_choco_sources[$source_name]['status'] == 'Enabled'
  $_need_update         = $_source_exists and $location and $_fact_choco_sources[$source_name]['location'] != $location # Todo: status of user/password

  $_ensure = $ensure ? {
    'present' => true,
    'absent'  => false
  }

  # Conditions where we need the location
  #  - source doesn't exist and ensure is present
  #  - source exists, ensure is present, but location must be updated
  if (!$_source_exists and $_ensure) or
    ($_source_exists and $_ensure and $_need_update) {
    if !location {
      fail("Must pass location to Chocolatey::Config::Source[${source_name}]")
    }
  }

  # Generate command line arguments
  # -user
  if $user_name {
    if $_new_choco {
      $_user_arg = " -user ${user_name}"
    } else {
      $_user_arg     = ''
      $_user_message = "Ignoring parameter 'user_name' which is supported on choco version < 0.9.9"

      notify{$_user_message:}
    }
  }

  # -password
  if $password {
    if $_new_choco {
      $_pw_arg = " -password ${password}"
    } else {
      $_pw_arg = ''
      $_pw_message = "Ignoring parameter 'password' which is supported on choco version < 0.9.9"
      notify{$_pw_message:}
    }
  }

  # Conditions to remove the source
  #  - source exists and ensure is absent
  #  - source exists, ensure is present, but location must be updated
  exec { "remove_source_${source_name}":
    command => "${_choco_exe_path} sources remove -name ${source_name}",
    path    => $::path,
    onlyif  => ($_source_exists and !$_ensure) or
    ($_source_exists and $_ensure and $_need_update)
  } ->

  # Conditions to add the source
  #  - source doesn't exist and ensure is present
  #  - source exists, ensure is present, but location must be updated
  #    (was just removed to update the location)
  exec { "add_source_${source_name}":
    command => "${_choco_exe_path} sources add -name ${source_name} -source ${location}${_user_arg}${_pw_arg}",
    path    => $::path,
    onlyif  => (!$_source_exists and $_ensure) or
    ($_source_exists and $_ensure and $_need_update),
  } ->

  # Conditions to enable a the source
  #  - source exists and enable is true and status is disabled
  #
  # On version < 0.9.9, there is no way to enable a source,
  # as we cannot get the disable status
  exec { "enable_source_${source_name}":
    command => "${_choco_exe_path} sources enable -name ${source_name}",
    path    => $::path,
    onlyif  => $_source_exists and $enable and !$_status_enabled
  } ->

  # Conditions to disable a the source
  #  - source exists and enable is false and status is enabled
  #
  # On version < 0.9.9, disabling source will be permanent
  # There is no way of enabling it again, as we cannot get the disable status
  exec { "disable_source_${source_name}":
    command => "${_choco_exe_path} sources disable -name ${source_name}",
    path    => $::path,
    onlyif  => $_source_exists and !$enable and $_status_enabled
  }

}
