User Function trataHtm(aCampos, aCpoItens, cArqHtml)
	Local cHtmlStr	:= ""
	Local aDeleted	:= {}
	Local i, j
	
	//旼컴컴컴컴컴컴컴컴컴커
	//� Variaveis Locais   �
	//읕컴컴컴컴컴컴컴컴컴켸
	If !File(cArqHtml)
		apMsgInfo("Arquivo html do e-mail n�o encontrado. VerIfique em " + cArqHtml + ".")
		Return
	EndIf

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿌bre o arquivo e faz a contagem total para setar na regua �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	ft_fuse(cArqHtml)
	
	While  ! ft_feof()
		cLinha	 := ft_freadln()
		cHtmlStr += cLinha
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Verifica se no arquivo HTML possui item    �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		nPos := at("<!-- Itens -->", cLinha)
		
		If nPos > 0
			cItem	:= ""
			ft_fskip()
			nPos := 0
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Monta a representacao do HTML referente a um item  �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Modifica as Tags para a quantidade de itens. ex.: �
			//� %nome1% ... %codigo1%                             �
			//� %nome2% ... %codigo2%                             �
			//� %nome3% ... %codigo3%                             �
			//� ...                                               �
			//� para que posteriomente seja feito a substituicao  �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Modifica as tags (%<tag>%) pelo valor passado. Nao coloquei �
	//� dentro do while para evitar processamento demasiado         �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	For i := 1 To Len(aCampos)
		// Itens marcados com '*' e' pq estao 'deletados'
		If AllTrim(aCampos[i][2]) == '*'
			aAdd(aDeleted, AllTrim(aCampos[i][1]))
			Loop
		EndIf
		
		cHtmlStr := subsTag(cHtmlStr, aCampos[i][1], aCampos[i][2])
	Next
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Procura se existe alguma (%<tag>%) marcada como deletada    �
	//� e retira do html.                                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	For i := 1 To Len(aDeleted)
		cHtmlStr := subsTag(cHtmlStr, aDeleted[i], '')
	Next
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Procura se ficou alguma (%<tag>%) sem ser substituida e     �
	//� substitui por "-".                                          �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
