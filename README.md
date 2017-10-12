# pattern_patch gem

[![Gem](https://img.shields.io/gem/v/pattern_patch.svg?style=flat)](https://rubygems.org/gems/pattern_patch)
[![Downloads](https://img.shields.io/gem/dt/pattern_patch.svg?style=flat)](https://rubygems.org/gems/pattern_patch)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/pattern_patch/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/jdee/pattern_patch.svg)](https://circleci.com/gh/jdee/pattern_patch)

Apply and revert pattern-based patches to any text file.

This is a very preliminary plugin to apply and revert patches to text files. One
of the main intended use cases for this plugin is source-code modification, e.g.
when automatically integrating an SDK.

Please provide any feedback via issues in this repo.

### patch action

```Ruby
patch(
  files: "examples/PatchTestAndroid/app/src/main/AndroidManifest.xml",
  regexp: %r{^\s*</application>},
  mode: :prepend,
  text: "        <meta-data android:name=\"foo\" android:value=\"bar\" />\n"
)
```

This action matches one or all occurrences of a specified regular expression and
modifies the file contents based on the optional `:mode` parameter. By default,
the action appends the specified text to the pattern match. It can also prepend
the text or replace the pattern match with the text. Use an optional `:global`
parameter to apply the patch to all instances of the regular expression.

The `regexp`, `text`, `mode` and `global` options may be specified in a YAML file to
define a patch, e.g.:

**patch.yaml**:
```yaml
regexp: '^\s*</application>'
mode: prepend
text: "        <meta-data android:name='foo' android:value='bar' />\n"
global: false
```

**Fastfile**:
```Ruby
patch(
  files: "examples/PatchTestAndroid/app/src/main/AndroidManifest.xml",
  patch: "patch.yaml"
)
```

#### Capture groups

Capture groups may be used within the text argument in any mode. Note that
this works best without interpolation (single quotes or %q). If you use double
quotes, the backslash must be escaped, e.g. `text: "\\1\"MyOtherpod\""`.

```Ruby
patch(
  files: "MyPod.podspec",
  regexp: /(s\.name\s*=\s*)"MyPod"/,
  text: '\1"MyOtherPod"',
  mode: :replace
)
```

Patches in `:append` mode using capture groups in the text argument may be
reverted. This is not currently supported in `:prepend` mode.

#### Revert patches

Revert patches by passing the optional `:revert` parameter:

```Ruby
patch(
  files: "examples/PatchTestAndroid/app/src/main/AndroidManifest.xml",
  regexp: %r{^\s*</application>},
  mode: :prepend,
  text: "        <meta-data android:name=\"foo\" android:value=\"bar\" />\n",
  revert: true
)
```

```Ruby
patch(
  files: "examples/PatchTestAndroid/app/src/main/AndroidManifest.xml",
  patch: "patch.yaml"
  revert: true
)
```

Patches using the `:replace` mode cannot be reverted.

### Options

|key|description|type|optional|default value|
|---|-----------|----|--------|-------------|
|:files|Absolute or relative path(s) to one or more files to patch|Array or String|no| |
|:regexp|A regular expression to match|Regexp|yes| |
|:text|Text to append to the match|String|yes| |
|:global|If true, patch all occurrences of the pattern|Boolean|yes|false|
|:mode|:append, :prepend or :replace|Symbol|yes|:append|
|:offset|Offset from which to start matching|Integer|yes|0|
|:patch|A YAML file specifying patch data|String|yes| |
|:revert|Set to true to revert the specified patch rather than apply it|Boolean|yes|false|

The :regexp and :text options must be set either in a patch file specified using the
:patch argument or via arguments in the Fastfile.

**Note**: The `apply_patch` and `revert_patch` actions have been deprecated in favor of a single
`patch` action with an optional `:revert` parameter.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, and running `fastlane install_plugins`.

The examples folder contains an empty Android project called PatchTestAndroid. There is an example
patch at the repo root in `patch.yaml` that will add a `meta-data` key to the end of the `application`
element in the Android project's manifest. The Fastfile includes two lanes: `apply` and `revert`.

Apply the patch to `examples/PatchTestAndroid/app/src/main/AndroidManifest.xml`:
```bash
fastlane apply
```

Revert the patch:
```bash
fastlane revert
```
