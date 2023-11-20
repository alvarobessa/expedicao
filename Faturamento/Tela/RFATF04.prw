#Include "protheus.ch"
#Include "topconn.ch"

/*/{Protheus.doc} RFATF04
Expedição de pedidos de venda
@type function
@version 
@author apbessa
@since 20/08/2023
@return return_type, return_description
/*/


User Function RFATF04(cFilPed, cNumPed, cNotaFis )
    Local aArea     := FwGetArea()
    Local cQySc5    := ""
    Local cQySc6    := ""
    Local cCod      := ""
 
    Begin Transaction 
        cQySc5 :="SELECT  "
        cQySc5 +="  SC5.C5_CLIENTE, "
        cQySc5 +="  SC5.C5_LOJACLI, "
        cQySc5 +="  SC5.C5_EMISSAO, "
        cQySc5 +="  SC5.C5_TPFRETE, "
        cQySc5 +="  SC5.C5_YTPEXP, "
        cQySc5 +="  SC5.C5_CLIENT, "
        cQySc5 +="  SC5.C5_LOJAENT, "
        cQySc5 +="  SC5.C5_VEND1, "
        cQySc5 +="  SC5.C5_YTRANSP, "
        cQySc5 +="ISNULL(CAST(CAST(SC5.C5_YOBSPED AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS OBS
        cQySc5 +="FROM " +RetSqlName("SC5") +  " SC5 "
        cQySc5 +="WHERE SC5.D_E_L_E_T_= '' "
        cQySc5 +="  AND SC5.C5_FILIAL='" + AllTrim(cFilPed) +  "' "
        cQySc5 +="  AND SC5.C5_NUM   ='" + AllTrim(cNumPed) +  "' "
        cQySc5 :=ChangeQuery(cQySc5)
        If Select("TSC5") > 0
            TSC5->(dbCloseArea())
        EndIf
        TcQuery cQySc5 New Alias TSC5

        dbSelectArea("TSC5")

        If TSC5->(!Eof())
            cCod := GetSXENum("ZA7","ZA7_CODIGO")
            
            dbSelectArea("ZA7")
            ZA7->(dbSetOrder(1))
            While ZA7->(dbSeek(xFilial("ZA7") + cCod))
                cCod := GetSXENum("ZA7","ZA7_CODIGO")
            EndDo
    
            RecLock("ZA7",.T.)
                ZA7->ZA7_FILIAL := AllTrim(cFilPed)
                ZA7->ZA7_CODIGO := cCod
                ZA7->ZA7_PEDIDO := AllTrim(cNumPed)
                ZA7->ZA7_CLIENT := AllTrim(TSC5->C5_CLIENTE)
                ZA7->ZA7_LOJA   := AllTrim(TSC5->C5_LOJACLI)
                ZA7->ZA7_NOME   := POSICIONE("SA1",1,xFilial("SA1")+TSC5->C5_CLIENTE+TSC5->C5_LOJACLI,"A1_NOME")
                ZA7->ZA7_EMISSA := SToD(TSC5->C5_EMISSAO)
                ZA7->ZA7_TPFRET := AllTrim(TSC5->C5_TPFRETE)
                ZA7->ZA7_STATUS := "2"
                ZA7->ZA7_TIPEXP := AllTrim(TSC5->C5_YTPEXP)
                ZA7->ZA7_ENTCLI := AllTrim(TSC5->C5_CLIENT)
                ZA7->ZA7_LOJENT := AllTrim(TSC5->C5_LOJAENT)
                ZA7->ZA7_NOMENT := POSICIONE("SA1",1,xFilial("SA1")+TSC5->C5_CLIENT+TSC5->C5_LOJAENT,"A1_NOME")
                ZA7->ZA7_TRANSP := AllTrim(TSC5->C5_YTRANSP)
                ZA7->ZA7_NMTRP  := POSICIONE("SA4",1,xFilial("SA4")+TSC5->C5_YTRANSP,"A4_NOME")
                ZA7->ZA7_CODVEN := AllTrim(TSC5->C5_VEND1)  
                ZA7->ZA7_NMVEND := POSICIONE("SA3",1,xFilial("SA3")+TSC5->C5_VEND1,"A3_NOME")
                ZA7->ZA7_NF     := AllTrim(cNotaFis)
                ZA7->ZA7_OBSPED := TSC5->OBS
            ZA7->(MsUnLock())
        
            cQySc6 :="SELECT  "
            cQySc6 +="  SC6.C6_FILIAL , "
            cQySc6 +="  SC6.C6_ITEM   , "
            cQySc6 +="  SC6.C6_PRODUTO, "
            cQySc6 +="  SC6.C6_LOCAL, "
            cQySc6 +="  SC6.C6_UM,  "
            cQySc6 +="  SC6.C6_QTDVEN "
            cQySc6 +="FROM " +RetSqlName("SC6") +  " SC6 "
            cQySc6 +="WHERE SC6.D_E_L_E_T_= '' "
            cQySc6 +="  AND SC6.C6_FILIAL='" + AllTrim(cFilPed) +  "' "
            cQySc6 +="  AND SC6.C6_NUM   ='" + AllTrim(cNumPed) +  "' "
            cQySc6 :=ChangeQuery(cQySc6)
            If Select("TSC6") > 0
                TSC6->(dbCloseArea())
            EndIf
            TcQuery cQySc6 New Alias TSC6

            dbSelectArea("TSC6")

            If TSC6->(Eof())
                DisarmTransaction()
                RollBackSX8()
            Else
                ConfirmSX8()

                dbSelectArea("ZA8")
                ZA8->(dbSetOrder(1))
                While TSC6->(!Eof())
                    RecLock("ZA8",.T.)
                        ZA8->ZA8_FILIAL := AllTrim(cFilPed)
                        ZA8->ZA8_CODIGO := ZA7->ZA7_CODIGO
                        ZA8->ZA8_PEDIDO := AllTrim(cNumPed)
                        ZA8->ZA8_ITEM   := AllTrim(TSC6->C6_ITEM)
                        ZA8->ZA8_PROD   := AllTrim(TSC6->C6_PRODUTO)
                        ZA8->ZA8_UM     := AllTrim(TSC6->C6_UM)
                        ZA8->ZA8_LOCAL  := AllTrim(TSC6->C6_LOCAL)
                        ZA8->ZA8_DESC   := POSICIONE("SB1",1,xFilial("SB1")+TSC6->C6_PRODUTO,"B1_DESC")
                        ZA8->ZA8_QTDPED := TSC6->C6_QTDVEN 
                        ZA8->ZA8_STATUS := "2"
                    ZA8->(MsUnLock())

                    TSC6->(dbSkip())
                EndDo
            EndIf

            TSC6->(dbCloseArea())              
        EndIf 

        TSC5->(dbCloseArea())

    End Transaction

    FwRestArea(aArea)

Return
