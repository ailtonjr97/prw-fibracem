//Bibliotecas
#Include "Protheus.ch"

User Function FIBTRAVAS()
    Local aArea    := GetArea()
    Local aAreaFA1  := FA1->(GetArea())
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
        AxCadastro('FA1', 'Travas', cDelOk, cFunTOk)
    EndIf
 
    RestArea(aAreaFA1)
    RestArea(aArea)
Return
