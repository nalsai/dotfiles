#SingleInstance force

!a::Send ä
!o::Send ö
!u::Send ü
!s::Send ß
!+a::Send Ä
!+o::Send Ö
!+u::Send Ü
!+s::Send ẞ
!e::Send €

^+v::								;Ctrl+Shift+v -- paste clipboard content as plain text
	ClipboardOld := ClipboardAll	;save original clipboard contents
	Clipboard = %Clipboard%			;store plain text from clipboard to clipboard
	Send ^v							;send the Ctrl+V command
	Sleep, 250						;give some time to finish paste (before restoring clipboard)
	Clipboard := ClipboardOld		;restore the original clipboard contents
	ClipboardOld =					;clear temporary variable (potentially contains large data)
	Return