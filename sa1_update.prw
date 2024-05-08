#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
 
WSRESTFUL updateSa1 DESCRIPTION "API Rest para CRUD na SA1 Clientes."
 
    WSDATA page AS INTEGER OPTIONAL
    WSDATA pageSize AS INTEGER OPTIONAL
    WSDATA cod AS STRING OPTIONAL
 
    WSMETHOD PUT    putClientes  DESCRIPTION 'Edita clientes'        WSSYNTAX '/update/sa1' PATH '/update/sa1' PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD PUT putClientes WSRECEIVE WSRESTFUL updateSa1
Local lRet      := .T.
Local aArea     := GetArea()
Local oJson
Local cJson     := Self:GetContent()
Local cError    := ''
Local nOpc      := 4 //Número 4 indica update
Local aSA1Auto := {}
Local aAI0Auto := {}
 
Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
 
Self:SetContentType("application/json")
oJson   := JsonObject():New()
cError  := oJson:FromJson(cJson)
IF !Empty(cError)
    SetRestFault(500,'Parser Json Error')
    lRet    := .F.
Else

    If lRet
    
    //----------------------------------
    // Dados do Cliente
    //----------------------------------
    aAdd(aSA1Auto,{"A1_COD",     AllTrim(oJson:GetJsonObject('A1_COD'))   ,        NIL})
    aAdd(aSA1Auto,{"A1_NOME",     AllTrim(oJson:GetJsonObject('A1_NOME'))   ,        NIL})
    
    //---------------------------------------------------------
    // Dados do Complemento do Cliente
    //---------------------------------------------------------
    aAdd(aAI0Auto,{"AI0_CODCLI",     AllTrim(oJson:GetJsonObject('AI0_CODCLI'))   ,        NIL})
    
    //------------------------------------
    // Chamada para cadastrar o cliente.
    //------------------------------------
    MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpc, {}) //Colocar aAI0Auto ao invés do objeto vazio {} para alterar dados complementares do cliente.
    
    IF lMsErroAuto
        self:setStatus(404)
        self:setResponse("ERRO AO ALTERAR" + GetAutoGRLog())
        lRet := .T.
    ELSE
        Self:SetResponse("Alterado com sucesso. " + oJson:GetJsonObject('A1_COD'))
    EndIF 

    EndIf    
    
EndIf

RestArea(aArea)
FreeObj(oJson)
 
Return
