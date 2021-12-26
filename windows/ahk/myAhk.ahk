#SingleInstance force

!a::Send ä
!o::Send ö
!u::Send ü
!+a::Send Ä
!+o::Send Ö
!+u::Send Ü

!q::Send ä
!p::Send ö
!y::Send ü
!+q::Send Ä
!+p::Send Ö
!+y::Send Ü

!e::Send €
!s::Send ß
!+s::Send ẞ

^+v::								;Ctrl+Shift+v -- paste clipboard content as plain text
	ClipboardOld := ClipboardAll	;save original clipboard contents
	Clipboard = %Clipboard%			;store plain text from clipboard to clipboard
	Send ^v							;send the Ctrl+V command
	Sleep, 250						;give some time to finish paste (before restoring clipboard)
	Clipboard := ClipboardOld		;restore the original clipboard contents
	ClipboardOld =					;clear temporary variable (potentially contains large data)
	Return

