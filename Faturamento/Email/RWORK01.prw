#Include 'Totvs.ch'
#Include 'tbiconn.ch'
#Include "TopConn.ch"


User Function RWORK01(cFilExp, cNumExp)
    Local aAreaSl1	:= FwGetArea()
	Local cQuery	:= ""
    Local cQyEmp    := ""
    Local cHtmTes   := ""
    Local cHtml     := ""
    Local cHtmWf    := ""
    Local cTitulo1  := EncodeUTF8("WORKFLOW EXPEDIÇÃO")
    Local cMsg1     := EncodeUTF8("WORKFLOW EXPEDIÇÃO")
    Local cMsg2     := EncodeUTF8("CONFERÊNCIA EXPREDIÇÃO")
    Local cEmail    := SuperGetMv("NI_EXPMAIL",.F.,"a.pereirabessa@gmail.com")
    Local aNota     := {}
    Local aCab      := {}
   
	Local i         := 1

    cQuery :="SELECT * "
	cQuery +="FROM " + RetSqlName("ZA7") + " ZA7 (NOLOCK) "
    cQuery +="  INNER JOIN  " + RetSqlName("ZA8") + " ZA8 (NOLOCK) "
    cQuery +="      ON  ZA7.ZA7_FILIAL = ZA8.ZA8_FILIAL "
    cQuery +="      AND ZA7.ZA7_CODIGO = ZA8.ZA8_CODIGO "
	cQuery +="WHERE ZA7.D_E_L_E_T_ =''"
    cQuery +="  AND ZA8.D_E_L_E_T_ =''"
	cQuery +=" 	AND ZA7.ZA7_FILIAL ='" + AllTrim(cFilExp)  + "' "
	cQuery +=" 	AND ZA7.ZA7_CODIGO ='" + AllTrim(cNumExp)   + "' "
	If Select("TZA7") > 0
		TZA7->(dbCloseArea())
	EndIf
	TcQuery cQuery New Alias TZA7

    dbSelectArea("TZA7")
	TZA7->(dbGoTop())

    If TZA7->(!Eof())
        cQyEmp :="SELECT   " 
        cQyEmp +="	SM0.M0_FILIAL,"
        cQyEmp +="	SM0.M0_NOME  "
        cQyEmp +="FROM SYS_COMPANY SM0 "
        cQyEmp +="WHERE SM0.D_E_L_E_T_ =' ' "
        cQyEmp +="  AND SM0.M0_CODIGO ='01' "
        cQyEmp +="  AND SM0.M0_CODFIL ='" + AllTrim(cFilExp)  +  "' "
        cQyEmp := ChangeQuery(cQyEmp)
        If Select("TSM0") > 0
            TSM0->(dbCloseArea())
        EndIf
        TcQuery cQyEmp New Alias TSM0

        If TSM0->(!Eof())
            aAdd(aCab, {"EMPRESA"	    ,Alltrim(TSM0->M0_FILIAL)})
            aAdd(aCab, {"UNIDADE"	    ,Alltrim(TSM0->M0_NOME)})
            aAdd(aCab, {"DATA"		    ,AllTrim(cUserName) +"-"+DTOC(dDataBase)+" - "+Time()})
            aAdd(aCab, {"TITULO"	    ,DecodeUTF8(cMsg1)})
            aAdd(aCab, {"MSG"		    ,DecodeUTF8(cMsg2)})
            aAdd(aCab, {"EXPEDICAO"	    ,AllTrim(TZA7->ZA7_CODIGO)})
            

            While TZA7->(!Eof())
                
                aAdd(aNota,{TZA7->ZA7_NF, TZA7->ZA8_PROD   +"-"+AllTrim(TZA7->ZA8_DESC), DToC(SToD(TZA7->ZA7_EMISSA)), AllTrim(TZA7->ZA7_CLIENT), AllTrim(TZA7->ZA7_NOME),;
                             TRANSFORM(TZA7->ZA8_QTDPED,"@E 9,999,999,999,999.99"), TRANSFORM()(TZA7->ZA8_QTDCON,"@E 9,999,999,999,999.99")})

                TZA7->(dbSkip())
            EndDo

            For i:= 1 To Len(aNota)
                cHtmTes +=	'<tr width="800">'
                cHtmTes += 	'<td bgcolor="#EAF8ED"  align="center"><font face="Tahoma,Arial" size=2 >'+aNota[i][1]+'</font></td><td bgcolor="#EAF8ED"  align="center"><font face="Tahoma,Arial" size=2>'+aNota[i][2]+'</font></td>'
                cHtmTes += 	'<td bgcolor="#EAF8ED"  align="center"><font face="Tahoma,Arial" size=2 >'+aNota[i][3]+'</font></td><td bgcolor="#EAF8ED"  align="center"><font face="Tahoma,Arial" size=2>'+aNota[i][4]+'</font></td>'
                cHtmTes +=	'<td bgcolor="#EAF8ED"  align="center"><font face="Tahoma,Arial" size=2 >'+aNota[i][5]+'</font></td><td bgcolor="#EAF8ED"  align="center"><font face="Tahoma,Arial" size=2>'+aNota[i][6]+'</font></td>'
                cHtmTes +=	'<td bgcolor="#EAF8ED"  align="center"S><font face="Tahoma,Arial" size=2 >'+aNota[i][7]+'</font></td>'
                cHtmTes += 	'</tr>'
            Next i
        
            aAdd(aCab, {"CONTRATOS"	, cHtmTes})
            cHtmWf  := "\WORKFLOW\workflow_ny.html"
            cHtml	:=	u_trataHtm(aCab, {}, cHtmWf)
        EndIf

        TSM0->(dbCloseArea())
    EndIf

    If !Empty(cHtml)
        cAssunto    := DecodeUTF8(cTitulo1)
        U_RWORK02(cAssunto, cHtml, cEmail)
    EndIf

	TZA7->(dbCloseArea())
   
    FwRestArea(aAreaSl1)
Return
