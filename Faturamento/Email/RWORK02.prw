#Include "rwmake.ch"
#Include 'tbiconn.ch' 
#Include 'ap5mail.ch' 
#Include "PROTHEUS.CH"


User Function RWORK02(cAssunto, cMensagem, cTo)
    Local lResult		:= .F.		
	Local lEnviado		:= .F.	
   
    Local cServer		:= GetMV("MV_RELSERV")
	Local cAccount	    := GetMV("MV_RELACNT")
	Local cPassword 	:= GetMV("MV_RELPSW")
	Local cEnviador 	:= GetMV("MV_RELACNT")
    
    Default cAnexos		:= ""
	Default cBcc		:= ""
	Default cTo		    := ""

    CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult // Resultado da tentativa de conexão

    If lResult
		FWLogMsg("INFO", /*cTransactionId*/, "NOVA", /*cCategory*/, /*cStep*/, /*cMsgId*/,"Conectado com servidor de E-Mail - " + cServer, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	Else
		FWLogMsg("INFO", /*cTransactionId*/, "NOVA", /*cCategory*/, /*cStep*/, /*cMsgId*/,"Nao foi possivel conectar ao servidor de E-Mail - " + cServer, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	EndIf	
	
	If Mailauth(cAccount,cPassword)
		FWLogMsg("INFO", /*cTransactionId*/, "NOVA", /*cCategory*/, /*cStep*/, /*cMsgId*/,"Autenticado servidor de E-Mail - " + cServer , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	Else
		FWLogMsg("INFO", /*cTransactionId*/, "NOVA", /*cCategory*/, /*cStep*/, /*cMsgId*/,"Nao Autenticado servidor de E-Mail - " + cServer, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	EndIf

    If !lResult
		MsgInfo("Não foi possível se conectar no servidor de e-mail", Funname())
	Else
		SEND MAIL;
		FROM cEnviador;
		TO cTo;
		BCC cBcc;
		SUBJECT cAssunto;
		BODY cMensagem;
		ATTACHMENT cAnexos;
		RESULT 	lEnviado             	// Resultado da tentativa de envio
		DISCONNECT SMTP SERVER

		If lEnviado
			FWLogMsg("INFO", /*cTransactionId*/, "NOVA", /*cCategory*/, /*cStep*/, /*cMsgId*/,'---------------------- ENVIO FINALIZADO ---------------------------------', /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		Else
			FWLogMsg("INFO", /*cTransactionId*/, "NOVA", /*cCategory*/, /*cStep*/, /*cMsgId*/,'---------------------- E-MAIL NAO ENVIADO ---------------------------------', /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf	
	EndIf
	
Return
