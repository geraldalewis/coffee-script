# Strict Early Errors
# -------------------

# The following are prohibited under ES5's `strict` mode
# * `Octal Integer Literals`
# * `Octal Escape Sequences`
# * duplicate property definitions in `Object Literal`s
# * duplicate formal parameter
# * `delete` operand is a variable
# * `delete` operand is a parameter
# * `delete` operand is `undefined`
# * `Future Reserved Word`s as identifiers: implements, interface, let, package, private, protected, public, static, yield
# * `eval` or `arguments` as `catch` identifier
# * `eval` or `arguments` as formal parameter
# * `eval` or `arguments` as function declaration identifier
# * `eval` or `arguments` as LHS of assignment
# * `eval` or `arguments` as the operand of a post/pre-fix inc/dec-rement expression

# helper to assert that code complies with strict prohibitions
strict = (code, msg) ->
  throws (-> CoffeeScript.compile code), null, msg
strictOk = (code, msg) ->
  doesNotThrow (-> CoffeeScript.compile code), msg


test "Octal Integer Literals prohibited", ->
  strict    '01'
  strict    '07777'
  strictOk  '09'
  strictOk  '079'
  strictOk  '`01`'

test "Octal Escape Sequences prohibited", ->
  strict    'e = "\\01"'
  strict    'e = "\\0777"'
  strictOk  'e = "\\09"'
  strictOk  'e = "\\07777"'
  strictOk  "e = `'\033[0;1m'`"

test "duplicate property definitions in `Object Literal`s are prohibited", ->
  strict 'o = {x:1,x:1}'
  strict 'x = 1; o = {x, x: 2}'

test "duplicate formal parameter are prohibited", ->
  nonce = {}

  # a Param can be an Identifier, ThisProperty( @-param ), Array, or Object
  # a Param can also be a splat (...) or an assignment (param=value)
  # the following function expressions should throw errors
  strict '(_,_)->',          'param, param'
  strict '(_,@_)->',         'param, @param'
  strict '(_,_...)->',       'param, param...'
  strict '(@_,_...)->',      '@param, param...'
  strict '(_,_ = true)->',   'param, param='
  strict '(@_,@_)->',        'two @params'
  strict '(_,@_ = true)->',  'param, @param='
  strict '(_,{_})->',        'param, {param}'
  strict '(@_,{_})->',       '@param, {param}'
  strict '({_,_})->',        '{param, param}'
  strict '({_,@_})->',       '{param, @param}'
  strict '(_,[_])->',        'param, [param]'
  strict '([_,_])->',        '[param, param]'
  strict '([_,@_])->',       '[param, @param]'
  strict '(_,[_]=true)->',   'param, [param]='
  strict '(_,[@_,{_}])->',   'param, [@param, {param}]'
  strict '(_,[_,{@_}])->',   'param, [param, {@param}]'
  strict '(_,[_,{_}])->',    'param, [param, {param}]'
  strict '(_,[_,{__}])->',   'param, [param, {param2}]'
  strict '(_,[__,{_}])->',   'param, [param2, {param}]'
  strict '(__,[_,{_}])->',   'param, [param2, {param2}]'
  # the following function expressions should **not** throw errors
  strictOk '({},_arg)->'
  strictOk '({},{})->'
  strictOk '([]...,_arg)->'
  strictOk '({}...,_arg)->'
  strictOk '({}...,[],_arg)->'
  strictOk '([]...,{},_arg)->'
  strictOk '(@case,_case)->'
  strictOk '(@case,_case...)->'
  strictOk '(@case...,_case)->'
  strictOk '(_case,@case)->'
  strictOk '(_case,@case...)->'

test "`delete` operand is a var is prohibited", ->
  strict 'a = 1; delete a'
  strictOk 'delete a' #noop

test "`delete` operand is a parameter is prohibited", ->
  strict '(a) -> delete a'
  strict '(@a) -> delete a'
  strict '(a...) -> delete a'
  strict '(a = 1) -> delete a'
  strict '([a]) -> delete a'
  strict '({a}) -> delete a'

test "`Future Reserved Word`s as identifiers prohibited", ->
  futures = 'implements interface let package private protected public static yield'.split ' '
  for keyword in futures
    strict "#{keyword} = 1"
    strict "class #{keyword}"
    strict "try new Error catch #{keyword}"
    strict "(#{keyword}) ->"
    strict "{keyword}++"
    strict "++{keyword}"
    strict "{keyword}--"
    strict "--{keyword}"

test "`eval` and `arguments` use restricted", ->
  proscribeds = 'eval arguments'.split ' '
  for proscribed in proscribeds
    strict "#{proscribed} = 1"
    strict "class #{proscribed}"
    strict "try new Error catch #{proscribed}"
    strict "(#{proscribed}) ->"
    strict "{proscribed}++"
    strict "++{proscribed}"
    strict "{proscribed}--"
    strict "--{proscribed}"
  strictOk "eval 'true'"
  strictOk "-> arguments[0]"

  
  
  