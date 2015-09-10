# chocolatey::config - Private class used for configuration
class chocolatey::config(
  $enable_checksumfiles           = $::chocolatey::enable_checksumfiles,
  $enable_autouninstaller         = $::chocolatey::enable_autouninstaller,
  $enable_allowglobalconfirmation = $::chocolatey::enable_allowglobalconfirmation,
  $enable_failonautouninstaller   = $::chocolatey::enable_failonautouninstaller,
  $disable_default_source         = $::chocolatey::disable_default_source,
  $sources                        = $::chocolatey::sources,
){
  assert_private()

  # this will require a second converge when choco is not
  # installed the first time through. This is on purpose
  # as we don't want to try to set these values for a
  # version less than 0.9.9 and we don't know what the
  # user may link to - it could be an older version of
  # Chocolatey
  if versioncmp($::chocolateyversion, '0.9.9.0') >= 0 {
    feature {'checksumFiles':
      enable => $enable_checksumfiles
    }

    feature {'autoUninstaller':
      enable => $enable_autouninstaller
    }

    feature {'allowGlobalConfirmation':
      enable => $enable_allowglobalconfirmation
    }

    feature {'failOnAutoUninstaller':
      enable => $enable_failonautouninstaller
    }

  } else {
    notify{'features are ignored on chocolatey version < 0.9.9':}
  }

  if $disable_default_source {
    source {'chocolatey':
      enable => false,
    }
  }

  create_resources(source, $sources)
}