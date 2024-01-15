; extends
((string_content) @injection.content
 (#match? @injection.content "SELECT|CREATE|WITH|DROP|UPDATE|INSERT")
 (#set! injection.language "sql"))
