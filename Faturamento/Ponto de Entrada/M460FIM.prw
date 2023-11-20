#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
 
/*/{Protheus.doc} M460FIM
	(long_description)
	@type Atualizar campo vendedor
	@author apbess
	@since 30/11/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

User Function M460FIM()
	Local cArea   := GetArea()

	U_RFATF04(SC5->C5_FILIAL, SC5->C5_NUM, SF2->F2_DOC)
	
	RestArea(cArea)
Return

