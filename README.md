# pattern_patch gem

[![Gem](https://img.shields.io/gem/v/pattern_patch.svg?style=flat)](https://rubygems.org/gems/pattern_patch)
[![Downloads](https://img.shields.io/gem/dt/pattern_patch.svg?style=flat)](https://rubygems.org/gems/pattern_patch)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/pattern_patch/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/jdee/pattern_patch.svg)](https://circleci.com/gh/jdee/pattern_patch)

Apply and revert pattern-based patches to any string or text file.

This is a very preliminary utility gem to apply and revert patches to strings (typically file contents). One
of the main intended use cases for this plugin is source-code modification, e.g.
when automatically integrating an SDK.

The current API is low-level, having evolved out of a Fastlane plugin helper. A better data model
will probably arise in later releases.

Please provide any feedback via issues in this repo.

```Ruby
require "pattern_patch"

# Add a meta-data key to the end of the application element of an Android manifest
modified = File.open("AndroidManifest.xml") do |file|
  PatternPatch::Utilities.apply_patch file.read,
                                      %r{^\s*</application>},
                                      "        <meta-data android:name=\"foo\" android:value=\"bar\" />\n",
                                      false,
                                      :prepend,
                                      0
end

File.open("AndroidManifest.xml", "w") { |f| f.write modified }
```

Capture groups may be used within the text argument in any mode. Note that
this works best without interpolation (single quotes or %q). If you use double
quotes, the backslash must be escaped, e.g. `text: "\\1\"MyOtherpod\""`.

```Ruby
require "pattern_patch"

# Change the name of a pod in a podspec
modified = File.open("AndroidManifest.xml") do |file|
  PatternPatch::Utilities.apply_patch file.read,
                                      /(s\.name\s*=\s*)"MyPod"/,
                                      '\1"MyOtherPod"',
                                      false,
                                      :replace,
                                      0
end

File.open("AndroidManifest.xml", "w") { |f| f.write modified }
```

Patches in `:append` mode using capture groups in the text argument may be
reverted. This is not currently supported in `:prepend` mode.

#### Revert patches

Revert patches by passing the optional `:revert` parameter:

```Ruby
# Revert the patch that added the metadata key to the end of the Android manifest, resulting in the original.
modified = File.open("AndroidManifest.xml") do |file|
  PatternPatch::Utilities.revert_patch file.read,
                                      %r{^\s*</application>},
                                      "        <meta-data android:name=\"foo\" android:value=\"bar\" />\n",
                                      false,
                                      :prepend,
                                      0
end

File.open("AndroidManifest.xml", "w") { |f| f.write modified }
```

Patches using the `:replace` mode cannot be reverted.
