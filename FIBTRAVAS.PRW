//Bibliotecas
#Include "Protheus.ch"

User Function FIBTRAVAS()
    Local aArea    := GetArea()
    Local aAreaFA2  := FA2->(GetArea())
    Local cDelOk   := ".T."
    Local cFunTOk  := ".T."
 

    If(RetCodUsr() != '000019')
        If(RetCodUsr() != '000004')
            If(RetCodUsr() != '000023')
                msgInfo("Acesso exclusivo para administradores")
                Return 0
            EndIf

        EndIf
    Else
        AxCadastro('FA2', 'Travas', cDelOk, cFunTOk)
    EndIf
 
    RestArea(aAreaFA2)
    RestArea(aArea)
Return
