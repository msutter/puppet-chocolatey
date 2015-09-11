define chocolatey::config::feature (
  $feature_name = $title,
  $enable       = true,
) {

  $_new_choco = versioncmp($::chocolateyversion, '0.9.9') >= 0

  if $_new_choco {

    # Load the choco_features fact, and in case of a stringified fact containing an
    # array, string, or hash, it returns the data in the corresponding native data type.
    $_fact = $::choco_features
    if is_string($_fact) {
      $_yaml = regsubst($_fact,'=>',': ', 'G')
      $_destringified_fact = parseyaml($_yaml)
    } else {
      $_destringified_fact = $_fact
    }
    $_fact_choco_features = $_destringified_fact

    validate_hash($_fact_choco_features)

    # define some booleans used for conditions sets
    $_choco_exe_path  = "${::choco_install_path}\\bin\\choco.exe"
    $_feature_exists  = has_key($_fact_choco_features, $feature_name)
    $_status_disabled = $_feature_exists and $_fact_choco_features[$feature_name]['status'] == 'Disabled'

    # Validate the feature name
    if !$_feature_exists {
      fail("Feature '${$feature_name}' is not a valid feature !")
    }

    # Conditions to enable the feature
    #  - feature exists, enable is true, and status is 'disable'
    $_enable_feature = $_feature_exists and $enable and $_status_disabled

    # Conditions to disable the feature
    #  - feature exists, enable is false, and status is 'enabled'
    $_disable_feature = $_feature_exists and !$enable and !$_status_disabled

    if $_enable_feature {
      exec { "enable_feature_${feature_name}":
        command => "${_choco_exe_path} feature enable -name ${feature_name}",
        path    => $::path,
      }
    }

    if $_disable_feature {
      exec { "disable_feature_${feature_name}":
        command => "${_choco_exe_path} features disable -name ${feature_name}",
        path    => $::path,
      }
    }

  } else {
    fail('You cannot manage features on choco version < 0.9.9 !')
  }

}
