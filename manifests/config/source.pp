define chocolatey::config::source (
  $ensure      = 'present',
  $source_name = $title,
  $location    = undef,
  $enable      = true,
  $user_name   = undef,
  $password    = undef
) {

  # Load the choco_sources fact, and in case of a stringified fact containing an
  # array, string, or hash, it returns the data in the corresponding native data type.
  $_fact = $::choco_sources
  if is_string($_fact) {
    $_yaml = regsubst($_fact,'=>',': ', 'G')
    $_destringified_fact = parseyaml($_yaml)
  } else {
    $_destringified_fact = $_fact
  }
  $_fact_choco_sources = $_destringified_fact

  validate_hash($_fact_choco_sources)

  # define some booleans used for conditions sets
  $_choco_exe_path       = "${::choco_install_path}\\bin\\choco.exe"
  $_new_choco            = versioncmp($::chocolateyversion, '0.9.9') >= 0
  $_source_exists        = has_key($_fact_choco_sources, $source_name)
  $_status_enabled       = $_source_exists and $_fact_choco_sources[$source_name]['status'] == 'Enabled'
  $_location_need_update = $_source_exists and $location and $_fact_choco_sources[$source_name]['location'] != $location
  $_user_need_update     = false # TODO
  $_password_need_update = false # TODO
  $_need_update          = $_location_need_update or $_user_need_update or $_password_need_update

  $_ensure = $ensure ? {
    'present' => true,
    'absent'  => false
  }

  # Conditions to add the source
  #  - source doesn't exist and ensure is present
  #  - source exists, ensure is present, but location must be updated
  #    (was just removed to update the location)
  $_add_source = (!$_source_exists and $_ensure) or
  ($_source_exists and $_ensure and $_need_update)

  # Conditions to remove the source
  #  - source exists and ensure is absent
  #  - source exists, ensure is present, but location must be updated
  $_remove_source = ($_source_exists and !$_ensure) or
  ($_source_exists and $_ensure and $_need_update)

  # Conditions to disable the source
  #  - source exists and enable is false and status is enabled
  #  - source doesn't exist and ensure is present and enable is false
  #
  # On version < 0.9.9, disabling source will be permanent
  # There is no way of enabling it again, as we cannot get the disable status
  $_disable_source = ($_source_exists and !$enable and $_status_enabled) or
  (!$_source_exists and $_ensure and !$enable) # special case by add + disable

  # Conditions to enable a the source
  #  - source exists and enable is true and status is disabled
  #
  # On version < 0.9.9, there is no way to enable a source,
  # as we cannot get the disable status
  $_enable_source =  $_source_exists and $enable and !$_status_enabled

  # Check if location is needed and fail if not present
  if $_add_source {
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

  # set relationships
  if $_remove_source and $_add_source {
    Exec["remove_source_${source_name}"] -> Exec["add_source_${source_name}"]
  }

  if $_remove_source {
    exec { "remove_source_${source_name}":
      command => "${_choco_exe_path} sources remove -name ${source_name}",
      path    => $::path,
    }
  }

  if $_add_source {
    exec { "add_source_${source_name}":
      command => "${_choco_exe_path} sources add -name ${source_name} -source ${location}${_user_arg}${_pw_arg}",
      path    => $::path,
    }
  }

  if $_enable_source {
    exec { "enable_source_${source_name}":
      command => "${_choco_exe_path} sources enable -name ${source_name}",
      path    => $::path,
    }
  }

  if $_disable_source {
    exec { "disable_source_${source_name}":
      command => "${_choco_exe_path} sources disable -name ${source_name}",
      path    => $::path,
    }
  }
}
