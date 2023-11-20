#Include 'parmtype.ch'
#Include "protheus.ch"
#Include "FWMBROWSE.CH"
#Include "FWMVCDEF.CH"
#Include "colors.ch"
#Include "topconn.ch"
#Include "TbiConn.Ch"
#Include "TbiCode.Ch"
#Include "vkey.ch"
#Include "FWPrintSetup.ch"

/*/{Protheus.doc} RFATF03
Expedição de pedidos de venda
@type function
@version 
@author apbessa
@since 16/08/2023
@return return_type, return_description
/*/

User Function RFATF03()
    Local aArea     := FwGetArea()
    Local oBrowse   := Nil

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias("ZA7")
    oBrowse:SetDescription("Expedição Pedidos de Venda")

    oBrowse:AddLegend("ZA7->ZA7_STATUS == '1'", "RED"    ,"Finalizado")
	oBrowse:AddLegend("ZA7->ZA7_STATUS == '2'", "GREEN"  ,"Pendente")
	oBrowse:AddLegend("ZA7->ZA7_STATUS == '3'", "BLACK"  ,"Cancelado")
	oBrowse:AddLegend("ZA7->ZA7_STATUS == '4'", "BLUE"   ,"Pendente Análise")

    oBrowse:SetMenuDef("RFATF03")
    oBrowse:Activate()
	
    FwRestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
Expedição de pedidos de venda
@type function
@version 
@author apbessa
@since 16/08/2023
@return return_type, return_description
/*/

Static Function MenuDef()
    Local aRotina := {}
	
	ADD OPTION aRotina Title "Visualizar" 	ACTION "VIEWDEF.RFATF03" OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    	ACTION "VIEWDEF.RFATF03" OPERATION 4 ACCESS 0
	
Return aRotina


/*/{Protheus.doc} ModelDef
Expedição de pedidos de venda
@type function
@version 
@author apbessa
@since 16/08/2023
@return return_type, return_description
/*/

Static Function ModelDef()
	Local oStructZA7 := FwFormStruct(1,"ZA7")
  	Local oStructZA8 := FwFormStruct(1,"ZA8")
 	Local oModel     := Nil

	oStructZA8:AddTrigger(	;
	"ZA8_QTDCON"			,;				                                                    //[01] Id do campo de origem
	"ZA8_STATUS"				,;				                                                //[02] Id do campo de destino
	{ |oModel,cId,xValue,nLinha| .T.  }	,;	                                                    //[03] Bloco de codigo de validação da execução do gatilho
	{ |oModel| FALTSTATUS(oModel:GetValue("ZA8_QTDCON"))})									    //[04] Bloco de codigo de execução do gatilho

    oStructZA8:AddTrigger(	;
	"ZA8_QTDCON"			,;				                                                    //[01] Id do campo de origem
	"LEGEST"				,;				                                                    //[02] Id do campo de destino
	{ |oModel,cId,xValue,nLinha| .T.  }	,;	                                                    //[03] Bloco de codigo de validação da execução do gatilho
	{ |oModel| If(FALTLEGEN(oModel:GetValue("ZA8_QTDCON"))== "1","BR_VERMELHO", "BR_VERDE")})  //[04] Bloco de codigo de execução do gatilho
	
    oStructZA8:AddField( ;
				AllTrim('') , ; 																// [01] C Titulo do campo
				AllTrim('') , ; 																// [02] C ToolTip do campo
				'LEGEST' 	, ;               													// [03] C identificador (ID) do Field
				'C' 		, ;                     											// [04] C Tipo do campo
				50 			, ;                      											// [05] N Tamanho do campo
				0 			, ;                       											// [06] N Decimal do campo
				Nil 		, ;                     											// [07] B Code-block de validacao do campo
				Nil 		, ;                     											// [08] B Code-block de validacao When do campo
				Nil 		, ;                     											// [09] A Lista de valores permitido do campo
				Nil 		, ;                     											// [10] L Indica se o campo tem preenchimento obrigatorio
				{ ||If(ZA8->ZA8_STATUS=="1","BR_VERMELHO","BR_VERDE")}, ;  		            	// [11] B Code-block de inicializacao do campo
				Nil 		, ;                     											// [12] L Indica se trata de um campo chave
				Nil 		, ;                     											// [13] L Indica se o campo pode receber valor em uma operacao de update.
				.T. )                       										   			// [14] L Indica se o campo Ã© virtual
					

    // Adiciona ao modelo uma estrutura de formulario de edicao por campos
    oModel := MPFormModel():New("FATF03CA", /*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
    oModel:AddFields("ZA7MASTER", /*cOwner*/, oStructZA7 )
    oModel:SetVldActive({|oModel|FVALZA7(oModel)})
	{|oModel|fZa3Valid(oModel)}
    oModel:SetPrimaryKey({"ZA7_FILIAL", "ZA7_CODIGO"} )
    oModel:AddGrid("ZA8DETAIL", "ZA7MASTER", oStructZA8, /**/, {|oLinhaVal,nLine| FLINHAOK(oLinhaVal, nLine)}, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

    // Faz relaciomaneto entre os compomentes do model
    oModel:SetRelation("ZA8DETAIL", {{"ZA8_FILIAL", "xFilial('ZA7')"} , {"ZA8_CODIGO", "ZA7_CODIGO"}}, ZA8->( IndexKey(1) ))
 	oModel:GetModel("ZA8DETAIL"):SetUniqueLIne({"ZA8_FILIAL", "ZA8_CODIGO", "ZA8_ITEM"})

    //Descrição da tela
    oModel:GetModel("ZA7MASTER"):SetDescription("Expedição Pedido de Venda")
    oModel:GetModel("ZA8DETAIL"):SetDescription("Itens Pedido de Venda")

	oModel:SetCommit({|oModel| ZA7Commit(oModel) },.F.)

 
Return oModel


/*/{Protheus.doc} ViewDef
Expedição de pedidos de venda
@type function
@version 
@author apbessa
@since 31/07/2023
@return return_type, return_description
/*/

Static Function ViewDef()
	Local oStructZA7 := FwFormStruct(2,"ZA7")
    Local oStructZA8 := FwFormStruct(2,"ZA8")
    Local oModel   	 := FWLoadModel('RFATF03')
    Local oView      := Nil

	oView:= FWFormView():New()
	oView:SetModel(oModel)

    oStructZA8:AddField( ;            			// Ord. Tipo Desc.
		'LEGEST'                 		, ;   	// [01]  C   Nome do Campo
		"00"                         	, ;     // [02]  C   Ordem
		AllTrim( ''    )        		, ;     // [03]  C   Titulo do campo
		AllTrim( '' )      				, ;     // [04]  C   Descricao do campo
		{ 'Legenda' } 					, ;     // [05]  A   Array com Help
		'C'                             , ;     // [06]  C   Tipo do campo
		'@BMP'                			, ;     // [07]  C   Picture
		Nil                             , ;     // [08]  B   Bloco de Picture Var
		''                              , ;     // [09]  C   Consulta F3
		.F.                             , ;     // [10]  L   Indica se o campo é alteravel
		Nil                             , ;     // [11]  C   Pasta do campo
		Nil                             , ;     // [12]  C   Agrupamento do campo
		Nil				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
		Nil                             , ;     // [14]  N   Tamanho maximo da maior opÃ§Ã£o do combo
		Nil                             , ;     // [15]  C   Inicializador de Browse
		.T.                             , ;     // [16]  L   Indica se o campo é virtual
		Nil                             , ;     // [17]  C   Picture Variavel
		Nil                             )       // [18]  L   Indica pulo de linha apos o campo
	
    oView:AddField("ZA7MASTER",oStructZA7)	
	oView:AddGrid("ZA8DETAIL" ,oStructZA8)
    oView:AddUserButton("Legenda(F2)","MAGIC_BMP",{ |oView| fLegend()},"Legenda",VK_F2,)

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "TOP" , 40 )
	oView:CreateHorizontalBox( "BOTTOM"   , 60 )

	//Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("ZA7MASTER","TOP")
	oView:SetOwnerView("ZA8DETAIL","BOTTOM")
	
	oView:AddIncrementField("ZA8DETAIL","ZA8_ITEM")
	
	// Liga a identificacao do componentes
	oView:EnableTitleView("ZA7MASTER")
	oView:EnableTitleView("ZA8DETAIL", "Itens do Pedido")
	
	oView:EnableControlBar(.T.)
		
Return oView


/*/{Protheus.doc} fLegend
Legendas
@type function
@version 
@author apbessa
@since 31/07/2023
@return return_type, return_description
/*/

Static Function fLegend()
	Local aLegenda := {}
	
	aAdd(aLegenda,{"BR_VERDE"		,"Finalizado"})
	aAdd(aLegenda,{"BR_VERMELHO"	,"Pendente"})
	aAdd(aLegenda,{"BR_CINZA"	    ,"Cancelado"})

	BrwLegenda("Legenda", "Pendente/Finalizado", aLegenda)
 
 Return aLegenda


/*/{Protheus.doc} ZA7Commit
Legendas
@type function
@version 
@author apbessa
@since 08/08/2023
@return return_type, return_description
/*/

 Static Function ZA7Commit(oModel)
	Local lRet   := .T.
	Local lValid := .T.
	Local nX     := 1  
	Local cQuery := ""
	Local oGrid  := oModel:GetModel("ZA8DETAIL")

	If oModel:GetOperation() == 4
		For nX := 1 To oGrid:Length()
			oGrid:GoLine(nX)
			If !(oGrid:IsDeleted()) 
				If !FWFldGet("ZA8_QTDPED",nX)  == FWFldGet("ZA8_QTDCON",nX)
					lValid := .F.
					Exit
				EndIf
			EndIf
		Next

		If lValid 
			oModel:GetModel("ZA7MASTER"):SetValue("ZA7_STATUS","1")

			cQuery :="SELECT R_E_C_N_O_ RECZA7, * "
			cQuery +="FROM " + RetSqlName("ZA7") +  " ZA7 "
			cQuery +="WHERE ZA7.D_E_L_E_T_= ' ' "
			cQuery +="	AND ZA7.ZA7_FILIAL='" + FWxFilial("ZA7") +  "' "
			cQuery +="	AND ZA7.ZA7_PEDIDO='" + ZA7->ZA7_PEDIDO + "' "
			cQuery +="	AND ZA7.ZA7_STATUS='4' "
			If Select("TZA7") > 0
				TZA7->(dbCloseArea())
			EndIf
			TcQuery cQuery New Alias TZA7

			dbSelectArea("TZA7")

			While TZA7->(!Eof())
				TZA7->(dbGoTop())
				RecLock("ZA7", .F.)
					If TZA7->ZA7_STATUS == "4"
						ZA7->ZA7_STATUS := "3"
					EndIf
				ZA7->(MsUnLock())

				TZA7->(dbSkip())
			EndDo

			TZA7->(dbCloseArea())
		Else 
			oModel:GetModel("ZA7MASTER"):SetValue("ZA7_STATUS","2")
		EndIf
	EndIf

	FWFormCommit(oModel)

	U_RWORK01(ZA7->ZA7_FILIAL, ZA7->ZA7_CODIGO)

 Return lRet

/*/{Protheus.doc} FVALZA7
Legendas
@type function
@version 
@author apbessa
@since 08/08/2023
@return return_type, return_description
/*/

 Static Function FVALZA7(oModel)
	Local lRet 		:= .T.
	Local cUserPes 	:= RetCodUsr()
	Local cParPesq 	:= SuperGetMv("NI_EXPUSR",.F.,"000000")
	Local cParAdm   := SuperGetMv("NI_EXPADM",.F.,"000000")

	//Atualização
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE 
		If  !Alltrim(cParAdm) $ cParPesq .AND. AllTrim(ZA7->ZA7_STATUS) == "3"
			oModel:SetErrorMessage("ZA7MASTER",,,,"ATENÇÃO","Não é possível alterar pedido de expedição com nota fiscal cancelada!",;
									"Apenas usuários administradores tem permissão para alterar registro")
			lRet := .F.
			Return lRet
		ElseIf !Alltrim(cParAdm) $ cParPesq .AND. AllTrim(ZA7->ZA7_STATUS) == "1"
			oModel:SetErrorMessage("ZA7MASTER",,,,"ATENÇÃO","Não é possível alterar pedido de expedição com status finalizado",;
									"Apenas usuários administradores tem permissão para alterar registro")
			lRet := .F.
			Return lRet
		ElseIf !Alltrim(cUserPes) $ cParPesq .AND. AllTrim(ZA7->ZA7_STATUS) == "4"
			oModel:SetErrorMessage("ZA7MASTER",,,,"ATENÇÃO","Não é possível alterar pedido de expedição com status pedente de análise!",;
									"Apenas usuários cadastrados no setor de logística tem permissão para alterar registro")
			lRet := .F.
			Return lRet
		EndIf

		oModel:GetModel("ZA8DETAIL"):SetNoInsertLine(.T.)
        oModel:GetModel("ZA8DETAIL"):SetNoDeleteLine(.T.)
	EndIf
	
 Return lRet

/*/{Protheus.doc} FLINHAOK
Legendas
@type function
@version 
@author apbessa
@since 08/08/2023
@return return_type, return_description
/*/

Static Function FLINHAOK(oLinhaVal, nLine) 
	Local lRet  	:= .T.
	Local nX 		:= 1
	Local oMod		:= FwModelActive()
	Local oGrid 	:= oMod:GetModel("ZA8DETAIL")

	For nX := 1 To oGrid:Length()
		oGrid:GoLine(nX)
		If !(oGrid:IsDeleted()) 
			If !FWFldGet("ZA8_QTDPED",nX)  == FWFldGet("ZA8_QTDCON",nX)
				If Empty(FWFldGet("ZA8_QTDPED",nX))
					MsgInfo("Quantidade pendente de conferência no item "  + cValToChar(FWFldGet("ZA8_ITEM",nX))+ " do pedido de expedição!", "Expedição")
				ElseIf FWFldGet("ZA8_QTDCON",nX)  < FWFldGet("ZA8_QTDPED",nX)
					MsgInfo("Quantidade menor que a quantidade do pedido de venda no item "  + cValToChar(FWFldGet("ZA8_ITEM",nX))+ "!", "Expedição")
				EndIf
				Exit
			EndIf
		EndIf
	Next

Return lRet


/*/{Protheus.doc} FALTSTATUS
//Validação se foi informado o cabeçalho
@type function
@version 
@author apbessa
@since 31/07/2023
@return return_type, return_description
/*/

Static Function FALTSTATUS(nConfPed)
	Local oModel	:= FwModelActive()
	Local cRet		:= ""
	Local nRet      := 0
	
	If nConfPed >  oModel:GetValue("ZA8DETAIL","ZA8_QTDPED")
		cRet := "2"
		oModel:GetModel("ZA8DETAIL"):SetValue("ZA8_STATUS",cRet)
		oModel:GetModel("ZA8DETAIL"):SetValue("ZA8_QTDCON",nRet)
		MsgInfo("Quantidade digitada maior que a quantidade do pedido de venda! Necessário corrigir a quantidade digitada ou alterar o pedido de venda.", "Expedição")
	ElseIf 	nConfPed  < oModel:GetValue("ZA8DETAIL","ZA8_QTDPED")
		cRet := "2"
		oModel:GetModel("ZA8DETAIL"):SetValue("ZA8_STATUS",cRet)
	Else
		cRet := "1"
		oModel:GetModel("ZA8DETAIL"):SetValue("ZA8_STATUS",cRet) 
	EndIf

Return cRet


/*/{Protheus.doc} FALTLEGEN
//Validação se foi informado o cabeçalho
@type function
@version 
@author apbessa
@since 31/07/2023
@return return_type, return_description
/*/

Static Function FALTLEGEN(nPedQtd)
	Local oModel	:= FwModelActive()
	Local cRet		:= ""
	
	If 	nPedQtd  < oModel:GetValue("ZA8DETAIL","ZA8_QTDPED")
		cRet := "2"
	Else
		cRet := "1"
	EndIf

Return cRet


