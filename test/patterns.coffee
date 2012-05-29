# Patterns
# --------

# * Destructuring Assignment
# * Param Patterns
# * For Patterns

test 'Param Patterns', ->
  
  noncex = 
    u: {}
    v: {}
    w: {}
  noncey = {}
  noncez = {}
  
  o = 
    x: noncex
    y: noncey
    z: noncez
  
  (([x])        -> eq x,noncex  )([noncex])
  (([@x])       -> eq @x,noncex ).call o, [noncex,noncey]
  (([x,y])      -> eq(x, noncex); eq(y, noncey)).call o, [noncex,noncey]
  (([@x,@y])    -> eq(@x,noncex); eq(@y, noncey)).call o, [noncex,noncey]
  (([x,y],z)    -> eq(x, noncex); eq(y, noncey); eq(z, noncez)).call o, [noncex,noncey],noncez
  (([@x,@y],@z) -> eq(@x,noncex); eq(@y, noncey); eq(@z, noncez)).call o, [noncex,noncey],noncez
  
  (({x})        -> eq(x,noncex))(o)
  (({@x})       -> eq(@x,noncex)).call {}, o
  (({x,y})      -> eq(x,noncex); eq(y,noncey))(o)
  (({@x,@y})    -> eq(@x,noncex); eq(@y,noncey)).call {}, o
  (({x,y},z)    -> eq(x,noncex); eq(y,noncey); eq(z,noncez))(o,noncez)
  (({@x,@y},@z) -> eq(@x,noncex); eq(@y,noncey); eq(@z, noncez)).call  {}, o, noncez
  
  (({x:@x})     -> eq(@x,noncex)).call {}, o
  (({x:u:@x})   -> eq(@x,noncex.u)).call {}, o
  
  (({x:x})      -> eq(x,noncex)).call {}, o
  (({x:u:x})    -> eq(x,noncex.u)).call {}, o
  (({x:u:@x})   -> eq(@x,noncex.u)).call {}, o
  
  #(({'x'})      -> eq(x,noncex)).call {}, o # 'x' cannot be assigned
  (({'x':x})    -> eq(x,noncex)).call {}, o
  
  try CoffeeScript.compile "({@x:a})->" 
  catch e
    referror = e
  unless referror instanceof ReferenceError
      throw "ThisProperty on the LHS of ObjectPattern assign should throw error."