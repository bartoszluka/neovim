; extends

(fenced_code_block
  (info_string
    (language) @lang)
  (code_fence_content) @injection.content
  (#match? @lang "csharp")
  (#set! injection.language "cs"))

