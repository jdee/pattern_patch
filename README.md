# pattern_patch gem

[![Gem](https://img.shields.io/gem/v/pattern_patch.svg?style=flat)](https://rubygems.org/gems/pattern_patch)
[![Downloads](https://img.shields.io/gem/dt/pattern_patch.svg?style=flat)](https://rubygems.org/gems/pattern_patch)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/pattern_patch/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/jdee/pattern_patch.svg)](https://circleci.com/gh/jdee/pattern_patch)

Apply and revert pattern-based patches to any string or text file.

This is a very preliminary utility gem to apply and revert patches to strings (typically file contents). One
of the main intended use cases for this plugin is source-code modification, e.g.
when automatically integrating an SDK.

Please provide any feedback via issues in this repo.

```Ruby
require "pattern_patch"

# Add a meta-data key to the end of the application element of an Android manifest
PatternPatch::Patch.new(
  regexp: %r{^\s*</application>},
  text: "        <meta-data android:name=\"foo\" android:value=\"bar\" />\n",
  mode: :prepend
).apply "AndroidManifest.xml"
```

Capture groups may be used within the text argument in any mode. Note that
this works best without interpolation (single quotes or %q). If you use double
quotes, the backslash must be escaped, e.g. `text: "\\1\"MyOtherpod\""`.

```Ruby
# Change the name of a pod in a podspec
PatternPatch::Patch.new(
  regexp: /(s\.name\s*=\s*)"MyPod"/,
  text: '\1"MyOtherPod"',
  mode: :replace
).apply "MyPod.podspec"
```

Patches in `:append` mode using capture groups in the text argument may be
reverted. This is not currently supported in `:prepend` mode.

#### Revert patches

Revert patches by passing the optional `:revert` parameter:

```Ruby
# Revert the patch that added the metadata key to the end of the Android manifest, resulting in the original.
PatternPatch::Patch.new(
  regexp: %r{^\s*</application>},
  text: "        <meta-data android:name=\"foo\" android:value=\"bar\" />\n",
  mode: :prepend
).apply "AndroidManifest.xml"
```

Patches using the `:replace` mode cannot be reverted.

#### Define patches in YAML files

Load a patch defined in YAML and apply it.

```Ruby
PatternPatch::Patch.from_yaml("patch.yaml").apply "file.txt"
```

#### Define patch text in external files

Load the contents of a file to use for the insertion/substitution text:

```Ruby
PatternPatch::Patch.new(
  regexp: /\z/,
  text_file: "text_to_insert_at_end.txt",
  mode: :append
)
```

When loading from a YAML file, the `text_file` path is interpreted relative
to the directory of the YAML file, e.g.:

**patch.yaml:**

```YAML
text_file: text_to_insert_at_end.txt
```

```Ruby
PatternPatch::Patch.from_yaml("/path/to/patches/patch.yaml")
```

This will load the contents of `/path/to/patches/text_to_insert_at_end.txt`.
