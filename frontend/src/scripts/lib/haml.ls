#! The HAML runtime.
#! This is used to centralize the HAML helper methods.
_ = require 'underscore'

#! Delegates to `underscore.string` to properly escape any HTML tags.
exports.escape = (text) -> _.escapeHTML text

#! HAML Coffee clean value function. Beside just
#! cleaning `null` and `undefined` values, it
#! adds a hidden unicode marker character to
#! boolean values, so that the render time boolean
#! logic can distinguish between real booleans and
#! boolean-like strings.
exports.clean = (text) ->
  switch text
    when null, undefined then ''
    when true, false then '\u0093' + text
    else text

#! Preserve newlines in the text.
exports.preserve = (text) -> text.replace /\n/g, '&#x000A;'
