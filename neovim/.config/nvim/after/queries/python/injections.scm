; extends
((string
 (string_content) @injection.content
 (#match? string "SELECT|CREATE|WITH|DROP|UPDATE|INSERT"))
 (#set! injection.language "sql"))
