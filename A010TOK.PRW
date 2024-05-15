#Include "TOTVS.ch"
#INCLUDE "PROTHEUS.CH"

User Function A010TOK()
Local lExecuta := .T.
Local aArea    := GetArea() //Salvando a área atual

DBSelectArea("FA1")
FA1->(DBSetOrder(1))

FA1->(DBSeek(xFilial("FA1")+"000002"))

If(FA1->FA1_STATUS == .T.)
    If(RetCodUsr() != '000009') //Elaine Ribeiro
        If(RetCodUsr() != '000142') //Amanda Garcia
            If(RetCodUsr() != '000030') //Eduardo Souza
                If(RetCodUsr() != '000007') //Fernando Gonçalves
                    If(RetCodUsr() != '000288') //Luany Santos
                        Alert("Usuário sem autorização para alterar produto. (000002)")
                        lExecuta := .F.
                    Endif
                Endif
            Endif
        Endif
    Endif
Else
    lExecuta := .T.
EndIf

RestArea(aArea)

Return (lExecuta)
