//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"



WSRESTFUL STATUS DESCRIPTION 'Status se Protheus está em modo exclusivo'

    WSMETHOD GET API DESCRIPTION 'Retorna o registro' WSSYNTAX '/status' PATH 'status' PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET API WSSERVICE STATUS
    Local lRet       := .T.
    
    Self:setStatus(200) 
    Self:SetResponse('Ok')
Return lRet
