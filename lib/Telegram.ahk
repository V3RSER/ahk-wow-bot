message(emoji, text){
	TelegramBotToken = 5973967899:AAEuB9uXGDbLUOs1JZ4ckYfynPyJiwt2NBc
	TelegramBotChatID = 1764256669
	iconBot := "%F0%9F%90%89"

	if (emoji == 1) ; X
		icon := "%E2%9D%8C"
	if (emoji == 2) ; ?
		icon := "%E2%9D%94"
	if (emoji == 3) ; !
		icon := "%E2%9A%A0%EF%B8%8F"
	if (emoji == 4) ; ¡
		icon := "%E2%84%B9%EF%B8%8F"
	if (emoji == 5) ; Confetti
		icon := "%F0%9F%8E%8A"

	Text = [%iconBot%] %icon% %text%

	loop 3
	{
		UrlDownloadToFile https://api.telegram.org/bot%TelegramBotToken%/sendmessage?chat_id=%TelegramBotChatID%&text=%Text%, %A_ScriptDir%\check.rups
		sleep 1000
		ifExist %A_ScriptDir%\check.rups
		{
			break
		}
		if A_index = 3
		{
			MsgBox, 16,, something went wrong with sending
		}
	}
	filedelete %A_ScriptDir%\check.rups
}
