User Function trataHtm(aCampos, aCpoItens, cArqHtml)
	Local cHtmlStr	:= ""
	Local aDeleted	:= {}
	Local i, j
	
	//��������������������Ŀ
	//� Variaveis Locais   �
	//����������������������
	If !File(cArqHtml)
		apMsgInfo("Arquivo html do e-mail n�o encontrado. VerIfique em " + cArqHtml + ".")
		Return
	EndIf

	//����������������������������������������������������������Ŀ
	//�Abre o arquivo e faz a contagem total para setar na regua �
	//������������������������������������������������������������
	ft_fuse(cArqHtml)
	
	While  ! ft_feof()
		cLinha	 := ft_freadln()
		cHtmlStr += cLinha
		
		//��������������������������������������������Ŀ
		//� Verifica se no arquivo HTML possui item    �
		//����������������������������������������������
		nPos := at("<!-- Itens -->", cLinha)
		
		If nPos > 0
			cItem	:= ""
			ft_fskip()
			nPos := 0
			
			//����������������������������������������������������Ŀ
			//� Monta a representacao do HTML referente a um item  �
			//������������������������������������������������������
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
			
			//���������������������������������������������������Ŀ
			//� Modifica as Tags para a quantidade de itens. ex.: �
			//� %nome1% ... %codigo1%                             �
			//� %nome2% ... %codigo2%                             �
			//� %nome3% ... %codigo3%                             �
			//� ...                                               �
			//� para que posteriomente seja feito a substituicao  �
			//�����������������������������������������������������
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

	//�������������������������������������������������������������Ŀ
	//� Modifica as tags (%<tag>%) pelo valor passado. Nao coloquei �
	//� dentro do while para evitar processamento demasiado         �
	//���������������������������������������������������������������
	For i := 1 To Len(aCampos)
		// Itens marcados com '*' e' pq estao 'deletados'
		If AllTrim(aCampos[i][2]) == '*'
			aAdd(aDeleted, AllTrim(aCampos[i][1]))
			Loop
		EndIf
		
		cHtmlStr := subsTag(cHtmlStr, aCampos[i][1], aCampos[i][2])
	Next
	
	//�������������������������������������������������������������Ŀ
	//� Procura se existe alguma (%<tag>%) marcada como deletada    �
	//� e retira do html.                                           �
	//���������������������������������������������������������������
	For i := 1 To Len(aDeleted)
		cHtmlStr := subsTag(cHtmlStr, aDeleted[i], '')
	Next
	
	//�������������������������������������������������������������Ŀ
	//� Procura se ficou alguma (%<tag>%) sem ser substituida e     �
	//� substitui por "-".                                          �
	//���������������������������������������������������������������
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
