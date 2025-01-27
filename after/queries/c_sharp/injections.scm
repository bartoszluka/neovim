; extends

((variable_declarator
  name: (identifier) @id
  (raw_string_literal
    (raw_string_content) @injection.content))
  (#match? @id "[jJ][sS][oO][nN]")
  (#set! injection.language "json"))

((attribute
  ((identifier) @name
    (attribute_argument_list
      (attribute_argument
        [(verbatim_string_literal)
          (string_literal)] @injection.content))))
  (#match? @name "[Rr]egex")
  (#set!
    injection.language "regex"
    priority 126 ; semantic tokens `string` in `csharp_ls` has priority 125 and overrides it
  )
)
