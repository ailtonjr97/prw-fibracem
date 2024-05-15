#Include "TOTVS.ch"
#INCLUDE "PROTHEUS.CH"

User Function A010TOK()
Local lExecuta := .T.
Local aArea    := GetArea() //Salvando a área atual

DBSelectArea("FA1")
FA1->(DBSetOrder(1))

FA1->(DBSeek(xFilial("FA1")+"000002"))

If(FA1->FA1_STATUS == .T.)
    If(RetCodUsr() != '000009')
        If(RetCodUsr() != '000142')
            If(RetCodUsr() != '000030')
                Alert("Usuário sem autorização para alterar produto. (000002)")
                lExecuta := .F.
            Endif
        Endif
    Endif
Else
    lExecuta := .T.
EndIf

RestArea(aArea)

Return (lExecuta)
