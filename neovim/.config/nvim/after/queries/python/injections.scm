; extends
;(((string) @the-whole-string
; ((string_content) @injection.content
; (#match? @the-whole-string "SELECT|CREATE|WITH|DROP|UPDATE|INSERT")
; (#set! injection.language "sql"))))

;(
;	(string
;		(string_content)+ @injection.content
;		(interpolation)?
;		(#match? @injection.content "SELECT|CREATE|WITH|DROP|UPDATE|INSERT")
;		(#set! injection.language "sql")
;		;(#set! injection.include-children)
;		(#set! injection.combined)
;	)
;)

;(
;	(string
;		(string_content)* @_start
;		(string_end) @_end
;		(#make-range! "full_string" @_start @_end)
;		(#match? full_string "SELECT|CREATE|WITH|DROP|UPDATE|INSERT")
;		(#set! injection.content "full_string")
;		(#set! injection.language "sql")
;		;(#set! injection.include-children)
;		(#set! injection.combined)
;	)
;)
(
  string
    (
      (string_content)
      ( (interpolation) (string_content))*
    ) @injection.content
    (#any-match? @injection.content "SELECT|CREATE|WITH|DROP|UPDATE|INSERT")
    (#set! injection.language "sql")
    ;(#set! injection.include-children)
    ;(#set! injection.combined)
)
