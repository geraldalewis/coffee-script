# Patterns
# --------

# * Destructuring Assignment
# * Pattern Parameters

{compile} = CoffeeScript

test 'Pattern Parameters', ->
  
  # To DRY out our tests, the following list is formatted like:
  #     <parameters>  →  <arguments>   →    <optional tests>
  # ... and reconstituted into function definitions/calls below.
  patterns = """
  @x         → noncex
  @x,@y      → noncex, noncey
  @x,@y,@z   → noncex, noncey, noncez

  [x]        → [noncex]
  [@x]       → [noncex,noncey]
  [x,y]      → [noncex,noncey]
  [@x,@y]    → [noncex,noncey]
  [x,y],z    → [noncex,noncey],noncez
  [@x,@y],@z → [noncex,noncey],noncez

  {x}        → o
  {@x}       → o
  {x,y}      → o
  {@x,@y}    → o
  {x,y},z    → o, noncez
  {@x,@y},@z → o, noncez

  {x:@x}     → o
  {x:x}      → o
  {x:w:x}    → o  → eq x,  noncex.w
  {x:w:@x}   → o  → eq @x, noncex.w

  {'x':x}    → o

  {0:x}      → [noncex]
  {0:x,1:y}  → [noncex, noncey]

  [{x}]      → [{x:noncex}]
  [{x,y}]    → [{x:noncex, y:noncey}]
  [{x},{y}]  → [{x:noncex}, {y:noncey}]
  [[x],[y]]  → [[noncex], [noncey]]
  [[x,y]]    → [[noncex, noncey]]
  [[x:x,y:y],z:z] → [[o], o]
  
  # #2211: splats in pattern parameters
  [s...]        → []                       → eq s.length, 0
  [s...]        → [noncex]                 → eq s[0], noncex
  [s...],y      → [noncex], noncey         → eq(s[0], noncex); eq(y, noncey)
  [s...,y],z    → [noncex, noncey], noncez → eq(s[0], noncex); eq(y, noncey); eq(z, noncez)
  [s...],[t...] → [noncex], [noncey]       → eq(s[0], noncex); eq(t[0], noncey)

  [x,y,z] = [noncex, noncey, noncez]       → 
  [x,y,z] = [noncex, noncey, noncez]       → [noncex, noncey, noncez]
  [x,y,z] = {0:noncex, 1:noncey, 2:noncez} → 
  [x,y,z] = {0:noncex, 1:noncey, 2:noncez} → [noncex, noncey, noncez]
  {x,y,z} = {x:noncex, y:noncey, z:noncez} → 
  {x,y,z} = {x:noncex, y:noncey, z:noncez} → o

  s...,{x}        → o
  s...,{x},[y]    → o, [noncey]
  s...,{x},[y],@z → o, [noncey], noncez
  {x},s...        → o
  {x},[y],s...    → o, [noncey]
  {x},[y],@z,s... → o, [noncey], noncez
  """
  
  patterns = patterns.split '\n'
  # Reconsitute each pattern into a function/call
  for pattern in patterns when pattern.indexOf('#') isnt 0
    [params, args, tests...] = pattern.split '→'
    
    unless tests.length
      tests = for c in ['x', 'y', 'z']
        ref = if params.indexOf("@#{c}") > -1 then "@#{c}" 
        else if params.indexOf(c)  > -1 then c
        continue unless ref
        "eq(#{ref},nonce#{c})"
    
    code = """
    nonce  = {}
    noncex = w: {}
    noncey = {}
    noncez = {}
    o = x: noncex, y: noncey, z: noncez
    
    ((#{params}) ->
      #{tests.join(';')}
    ).call({}, #{args})
    """
    
    try CoffeeScript.run(code)
    catch e
      console.log "Unexpected result for Pattern Parameter #{pattern} : #{e}"
      console.log compile(code, bare: on)
      throw e


test 'Illegal identifiers within Pattern Parameters should raise ReferenceErrors', ->
  # Illegal productions; disable if grammar corrected
  references = [
    "{'x'}"
    "{@x:a}"
    "{y:x()}"
    "{0}"
    "[0]"
  ]
  
  for reference in references
    referr = null
    try compile "(#{reference})->" catch e then referr = e
    unless referr instanceof ReferenceError
        throw "Illegal Pattern Parameters should \
               throw a ReferenceError: (#{reference})->"
  
test 'Invocations within Pattern Parameters should raise a parse error (#2213)', ->
  # While Ecmascript allows calls to produce references (for Host objects),
  # CoffeeScript does not.
  invocations = [
    '[x()]'
    '[x:y()]'
    '[x:y.z()]'
    '{x()}'
    '{x():y}'
    '{x:y()}'
    '{x:y.z()}'
  ]
  
  for invocation in invocations
    err = null
    try compile "(#{invocation})->" catch e then err = e
    throw "Function calls cannot produce references: (#{invocation})->" unless err

test 'Pattern Parameters should not contain multiple splats', ->
  try compile '([s...,t...])->' catch e then err = e
  throw "Pattern Parameters may not contain multiple splats: (#{code})->" unless err

test "Invalid identifiers may not be used on the LHS of Pattern Parameters (#1005)", ->
  
  invalid = (pattern, description) ->
    throws (-> compile pattern), null, "Illegal identifier within #{description}"
  
  identifiers = ['eval', 'arguments', 'case']
  for identifier in identifiers
    invalid "([#{identifier}])->",    'Array Pattern'
    invalid "([#{identifier}...])->", 'Splatted Array Pattern'
    invalid "({#{identifier}])->",    'Object Pattern'
    invalid "({#{identifier}...)->",  'Splatted Object Pattern'
    doesNotThrow -> 
      compile "(@#{identifier})->"
      compile "([@#{identifier}])->"
      compile "([@#{identifier}...])->"
      compile "({@#{identifier}})->"
  

test "Pattern Parameter identifiers should shadow outer scope variables (#904)", ->
  nonce = {}
  id = nonce
  
  at    = (@id)  -> id
  arr   = ([id]) -> id
  obj   = ({id}) -> id
  objid = ({id:id}) -> id
  splat = ([id]...) -> id
  
  eq arr([2]), 2
  eq obj(id:3), 3
  eq objid(id:4), 4
  eq at(5), 5
  eq splat(6), 6
  eq id, nonce
