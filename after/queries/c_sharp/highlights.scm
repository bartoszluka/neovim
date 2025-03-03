; extends

((comment) @comment.todo
  (#match? @comment.todo "TODO"))

((lambda_expression (modifier) @keyword.coroutine.c_sharp))

((identifier) @variable
  (#eq? @variable "file")
  (#set! priority 101))
