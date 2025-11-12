;; extends

(method_declaration body: (block)) @function.outer

((parameter_list
  "," @_start
  .
  (parameter) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((parameter_list
  .
  (parameter) @parameter.inner
  .
  ","? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

((argument_list
  "," @_start
  .
  (argument) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((argument_list
  .
  (argument) @parameter.inner
  .
  ","? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))
