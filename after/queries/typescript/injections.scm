; extends

(pair
  key: (_)@k
  value: (template_string (string_fragment)@injection.content)
  (#match? @k "template")
  (#set! injection.language "html"))
