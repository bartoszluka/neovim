; extends

((comment) @comment.todo
  (#match? @comment.todo "TODO")
  (#set! priority 126))

((lambda_expression (modifier) @keyword.coroutine.c_sharp))

((identifier) @variable
  (#eq? @variable "file")
  (#set! priority 101))

(switch_expression_arm
  (constant_pattern
    (identifier) @type (#set! priority 101)))
