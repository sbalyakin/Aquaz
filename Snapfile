# Uncomment the lines below you want to change by removing the # in the beginning

# A list of devices you want to take the screenshots from
devices([
  "iPhone 6s",
  "iPhone 6s Plus",
  "iPhone 5s",
  "iPhone 4s"
])

languages([
  'en-US',
  'ru-RU'
])

# Where should the resulting screenshots be stored?
screenshots_path "../Aquaz Screenshots"

# clear_previous_screenshots # remove the '#'' to clear all previously generated screenshots before creating new ones

# JavaScript UIAutomation file
js_file './Snapshot/Snapshot.js'

# The name of the project's scheme
scheme 'Aquaz'

# Where is your project (or workspace)? Provide the full path here
project_path './Aquaz.xcworkspace'

# By default, the latest version should be used automatically. If you want to change it, do it here
# ios_version '8.1'

# Comment out the line below to add a `SNAPSHOT` preprocessor macro
# More information available: https://github.com/krausefx/snapshot#custom-args-for-the-build-command
#custom_build_args "GCC_PREPROCESSOR_DEFINITIONS='$(inherited) SNAPSHOT=1' OTHER_SWIFT_FLAGS='$(inherited) -DSNAPSHOT'"

custom_run_args "-SNAPSHOT"

# Custom Callbacks

# setup_for_device_change do |device, udid, language|
#   puts "Running #{language} on #{device}"
#   system("./populateDatabase.sh")
# end

# teardown_device do |language, device|
#   puts "Finished with #{language} on #{device}"
#   system("./cleanup.sh")
# end
