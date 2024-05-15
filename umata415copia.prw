#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

User Function M415COPIA()
    lRet := .T.
    Local aArea    := GetArea() //Salvando a área atual
 
 
    DBSelectArea("FA1")
    FA1->(DBSetOrder(1))
 
    FA1->(DBSeek(xFilial("FA1")+"000001"))

    If(FA1->FA1_STATUS == .T.)
        If SCJ->CJ_TPFRETE == 'C'
            Alert('Frete nao pode ser CIF na copia do orcamento. (000001)')
            lRet := .F.
        Else
            lRet := .T.
        EndIf
    Else
        lRet := .T.
    EndIf

    RestArea(aArea)
Return(lRet)
