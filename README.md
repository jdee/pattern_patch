# pattern_patch gem

[![Gem](https://img.shields.io/gem/v/pattern_patch.svg?style=flat)](https://rubygems.org/gems/pattern_patch)
[![Downloads](https://img.shields.io/gem/dt/pattern_patch.svg?style=flat)](https://rubygems.org/gems/pattern_patch)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/pattern_patch/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/jdee/pattern_patch.svg)](https://circleci.com/gh/jdee/pattern_patch)

Apply and revert pattern-based patches to any string or text file.

This is a preliminary utility gem to apply and revert patches to strings (typically file contents). One
of the main intended use cases for this plugin is source-code modification, e.g.
when automatically integrating an SDK.

Please provide any feedback via issues in this repo.

See the [full documentation](http://www.rubydoc.info/github/jdee/pattern_patch/) for more details.

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

#### ERB in text and text_file

ERB is processed in the `text` value or the contents of a `text_file`:

```Ruby
PatternPatch::Patch.new(
  regexp: /x/,
  text: '<%= PatternPatch::VERSION %>',
  mode: :replace
).apply file_path
```

Optionally pass a `:binding` option to `#apply` to use a specific Binding:

```Ruby
replacement_text = 'y'
PatternPatch::Patch.new(
  regexp: /x/,
  text: '<%= replacement_text %>',
  mode: :replace
).apply file_path, binding: binding
```

or a Hash of locals for the template:
```Ruby
PatternPatch::Patch.new(
  regexp: /x/,
  text: '<%= replacement_text %>',
  mode: :replace
).apply file_path, locals: { replacement_text: 'y' }
```

This is particularly useful with a `text_file` argument.

The `#apply` and `#revert` methods also accept `:safe_level` and `:trim_mode`
options for use with ERb. These can be set at the global level using
`PatternPatch.safe_level` and `PatternPatch.trim_mode`. The `#safe_level`
and '#trim_mode' attributes in the `Methods` module are convenience methods
to set and retrieve these global values.

```Ruby
PatternPatch::Patch.new(
  regexp: /x/,
  text_file: "template.erb",
  mode: :replace
).apply file_path, trim_mode: "<>"
```

#### Regular expressions with modifiers in YAML

The `regexp` field in a YAML file may be specified with or without slashes
or a modifier:

```YAML
# Results in /^x/
regexp: '^x'
```

```YAML
# Results in /^x/i
regexp: '/^x/i'
```

Currently only the slash literal notation is supported in YAML.

#### Loading patches from a specific folder

Use `PatternPatch.patch_dir` and `PatternPatch.patch` to easily load patches
by name.

```Ruby
PatternPatch.patch_dir = "/path/to/patches"
# Use /path/to/patches/patch_name.yml
PatternPatch.patch(:patch_name).apply file_path
```

#### Configuration with patch_config method

```Ruby
include PatternPatch::Methods

patch_config do |c|
  c.patch_dir = File.expand_path '../assets/patches', __dir__
  c.trim_mode = '<>'
end

patch(:my_patch).apply '/path/to/target/file'
```

or

```Ruby
include PatternPatch::Methods

patch_config.patch_dir = File.expand_path '../assets/patches', __dir__
patch_config.trim_mode = '<>'

patch(:my_patch).apply '/path/to/target/file'
```

### Why use pattern_patch?

Modifying files from code is a common task. When modifying a file that uses a
standard format, such as XML or JSON, you can use a standard library in almost
any language to parse, interpret and update file contents.

If you have to patch other formatted text, particularly source code, there may
not be a standard library available to parse a given format. In addition, using
a library limits control over formatting. If you use REXML to modify XML, it
will generate a file using single quotes for all attributes. While this is
legitimate XML, it can cause problems in some cases, and it generates a diff
that shows irrelevant, inconsequential changes. Some XML libraries
can make other changes to the file format, such as joining multiline tags. In
some cases (e.g., Android manifests) this is quite visible and annoying.

This gem offers a more general solution to the problem. A `Patch` is defined as
an operation that can be performed on any file at all. If the file's contents do
not match the `#regexp` attribute, no change is made, but the patch may still be
applied. These operations may be
externally defined in separate files or in code (or using a combination of
both). Further, many patches may be reverted by recognizing
the pattern that would result from application of the patch and reversing its
effect.

This gem is used extensively in the
[branch_io_cli](https://github.com/BranchMetrics/branch_io_cli) gem to patch
source code, Podfiles and Cartfiles. A collection of patches is kept in
`lib/assets/patches`, both YAML patch definitions and source patches using ERB.
The PatchHelper class easily loads the patch assets and applies them to the
relevant files. The process there is similar to rendering partial templates in a
web framework like Rails. It is also used in the
[patch](https://github.com/jdee/fastlane-plugin-patch) plugin for Fastlane. In
fact this gem grew out of that plugin.

This idea was loosely inspired by Facebook's
[`react-native link` automation for Android](https://github.com/facebook/react-native/tree/master/local-cli/link/android/patches).
