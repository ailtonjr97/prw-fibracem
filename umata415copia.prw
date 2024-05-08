#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

User Function M415COPIA()
    lRet := .T.
    Local aArea    := GetArea() //Salvando a área atual
 
 
    DBSelectArea("FA2")
    FA2->(DBSetOrder(1))
 
    FA2->(DBSeek(xFilial("FA2")+"000001"))

    If(FA2->FA2_STATUS == .T.)
        If SCJ->CJ_TPFRETE == 'C'
            Alert('Frete nao pode ser CIF na copia do orcamento.')
            lRet := .F.
        Else
            lRet := .T.
        EndIf
    Else
        lRet := .T.
    EndIf

    RestArea(aArea)
Return(lRet)
