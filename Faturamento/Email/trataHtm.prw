User Function trataHtm(aCampos, aCpoItens, cArqHtml)
	Local cHtmlStr	:= ""
	Local aDeleted	:= {}
	Local i, j
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File(cArqHtml)
		apMsgInfo("Arquivo html do e-mail não encontrado. VerIfique em " + cArqHtml + ".")
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abre o arquivo e faz a contagem total para setar na regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ft_fuse(cArqHtml)
	
	While  ! ft_feof()
		cLinha	 := ft_freadln()
		cHtmlStr += cLinha
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se no arquivo HTML possui item    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := at("<!-- Itens -->", cLinha)
		
		If nPos > 0
			cItem	:= ""
			ft_fskip()
			nPos := 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a representacao do HTML referente a um item  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While nPos == 0

				cLinha	:= ft_fReadLn()
				nPos	:= at("<!-- Fim Itens -->", cLinha)

                If nPos == 0
					cItem += cLinha
					ft_fskip()
				else
					cFimItem := cLinha
				EndIf	
			EndDo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Modifica as Tags para a quantidade de itens. ex.: ³
			//³ %nome1% ... %codigo1%                             ³
			//³ %nome2% ... %codigo2%                             ³
			//³ %nome3% ... %codigo3%                             ³
			//³ ...                                               ³
			//³ para que posteriomente seja feito a substituicao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For i := 1 To Len(aCpoItens)
				cNewLine	:= cItem
				For j := 1 To Len(aCpoItens[i])
					// Itens marcados com '*' e' pq estao 'deletados'
					If AllTrim(aCpoItens[i][j][2]) == '*'
						aAdd(aDeleted, AllTrim(aCpoItens[i][j][1]))
						Loop
					EndIf
					
					cNewLine := subsTag(cNewLine, aCpoItens[i][j][1], aCpoItens[i][j][2])
				Next
				cHtmlStr += cNewLine
			Next
			
			cHtmlStr += cFimItem
			
		EndIf
		
		ft_fskip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Modifica as tags (%<tag>%) pelo valor passado. Nao coloquei ³
	//³ dentro do while para evitar processamento demasiado         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i := 1 To Len(aCampos)
		// Itens marcados com '*' e' pq estao 'deletados'
		If AllTrim(aCampos[i][2]) == '*'
			aAdd(aDeleted, AllTrim(aCampos[i][1]))
			Loop
		EndIf
		
		cHtmlStr := subsTag(cHtmlStr, aCampos[i][1], aCampos[i][2])
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura se existe alguma (%<tag>%) marcada como deletada    ³
	//³ e retira do html.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i := 1 To Len(aDeleted)
		cHtmlStr := subsTag(cHtmlStr, aDeleted[i], '')
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura se ficou alguma (%<tag>%) sem ser substituida e     ³
	//³ substitui por "-".                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos 	:= at("%", cHtmlStr)  
	nPos2 	:= nPos
	While nPos > 0
		cValida := SubStr(cHtmlStr, nPos2+1, 1) 
		
		If cValida != ';' .AND. cValida != ' ' .AND. cValida != "'" .AND. cValida != '"' .AND. cValida != '<' .AND. cValida != ')'
			nLen 	 := at("%", SubStr(cHtmlStr, nPos2+1, Len(cHtmlStr)))
			cHtmlStr := Stuff(cHtmlStr, nPos2, nLen+1, '-')
		EndIf
		
		nPos  := at("%", SubStr(cHtmlStr, nPos2+1, Len(cHtmlStr)))
		nPos2 += nPos
	EndDo
	
Return cHtmlStr

Static Function subsTag(cString, cTag, cValor)
	Local nPos	:= 0
	
	nPos := at("%" + cTag + "%", cString)
	While nPos > 0
		cString	:= Stuff(cString, nPos, Len("%" + cTag + "%"), cValor )
		nPos	:= at("%" + cTag + "%", cString)
	EndDo
		
Return cString
