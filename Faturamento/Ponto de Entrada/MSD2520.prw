#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"

/*/{Protheus.doc} 
    @since 16/08/2023
    @version MSD2520
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example apbessa
    (examples)
    @see (links_or_references)
//*/

User Function MSD2520()
    Local uRet   := Nil
    Local cQuery := "" 
    Local aArea  := FwGetArea()

    cQuery :="SELECT ZA7.R_E_C_N_O_ RECZA7, * "
    cQuery +="FROM " +RetSqlName("ZA7") +  " ZA7 "
    cQuery +="WHERE ZA7.D_E_L_E_T_=''"
    cQuery +="    AND ZA7.ZA7_FILIAL  ='" + FWxFilial("ZA7") +  "' "
    cQuery +="    AND ZA7.ZA7_CLIENT  ='" + AllTrim(SF2->F2_CLIENTE) +  "' "
    cQuery +="    AND ZA7.ZA7_LOJA    ='" + AllTrim(SF2->F2_LOJA) +  "' "
    cQuery +="    AND ZA7.ZA7_NF      ='" + AllTrim(SF2->F2_DOC) +  "' "
    cQuery :=ChangeQuery(cQuery)
    If Select("TZA7") > 0
        TZA7->(dbCloseArea())
    EndIf
    TcQuery cQuery New Alias TZA7

    dbSelectArea("TZA7")

    If TZA7->(!Eof())
        dbSelectArea("ZA7")
		ZA7->(dbGoTo(TZA7->RECZA7))
		RecLock("ZA7",.F.)
            If AllTrim(TZA7->ZA7_STATUS) == "2" 
			    ZA7->ZA7_STATUS := "4"
            Else 
                ZA7->ZA7_STATUS := "3"
            EndIf
		ZA7->(MsUnLock())
    EndIf

    TZA7->(dbCloseArea())

    FwRestArea(aArea)

Return(uRet)
