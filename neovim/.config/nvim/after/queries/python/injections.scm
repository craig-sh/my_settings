; extends

;; f"""..."""
((string
   (string_content) @_sql) @injection.content
  (#match? @_sql "SELECT|CREATE|WITH|DROP|UPDATE|INSERT")
  (#match? @injection.content "^f\"\"\"")
  (#set! injection.language "sql")
  (#set! injection.include-children)
  (#offset! @injection.content 0 4 0 -3))


;; f"..."
((string
   (string_content) @_sql) @injection.content
  (#match? @_sql "SELECT|CREATE|WITH|DROP|UPDATE|INSERT")
  (#match? @injection.content "^f\"")
  (#set! injection.language "sql")
  (#set! injection.include-children)
  (#offset! @injection.content 0 2 0 -1))


;; "..."
((string
   (string_content) @_sql) @injection.content
  (#match? @_sql "SELECT|CREATE|WITH|DROP|UPDATE|INSERT")
  (#match? @injection.content "\"[^\"]")
  (#set! injection.language "sql")
  (#set! injection.include-children)
  (#offset! @injection.content 0 1 0 -1))

;; """..."""
((string
   (string_content) @_sql) @injection.content
  (#match? @_sql "SELECT|CREATE|WITH|DROP|UPDATE|INSERT")
  (#match? @injection.content "\"\"\"")
  (#set! injection.language "sql")
  (#set! injection.include-children)
  (#offset! @injection.content 0 3 0 -3))
