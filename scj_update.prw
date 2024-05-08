#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
 
WSRESTFUL orcamentos DESCRIPTION "Api REST para consulta de pedidos de venda"
 
    WSDATA page AS INTEGER OPTIONAL
    WSDATA pageSize AS INTEGER OPTIONAL
    WSDATA num AS STRING OPTIONAL
 
    WSMETHOD PUT    putSales  DESCRIPTION 'Edita orçamento'        WSSYNTAX '/update/v2/orcamentos' PATH '/update/v2/orcamentos' PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD PUT putSales WSRECEIVE WSRESTFUL orcamentos
Local lRet      := .T.
Local aArea     := GetArea()
Local aCabec
Local aItens    := {}
Local aLinha    := {}
Local oJson
Local oItems
Local cJson     := Self:GetContent()
Local cError    := ''
Local nX        := 0
Local cAlias    := ''
Local nOpc      := 4
 
Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
 
Self:SetContentType("application/json")
oJson   := JsonObject():New()
cError  := oJson:FromJson(cJson)
IF !Empty(cError)
    SetRestFault(500,'Parser Json Error')
    lRet    := .F.
elseif Empty(self:num)
    num := "000160"
Else
    cAlias := 'SCJ'
    DbSelectArea(cAlias)
    (cAlias)->(dbSetOrder(1))
    IF ((cAlias)->(dbSeek(FWxFilial(cAlias)+PadR(oJson:GetJsonObject('NUM'),TamSX3("CJ_NUM")[1]))))
        aCabec  := {}
        aItens  := {}
        aAdd(aCabec,{"CJ_NUM",     AllTrim(oJson:GetJsonObject('NUM'))   ,        NIL})
        aAdd(aCabec,{"CJ_CST_FTS",     AllTrim(oJson:GetJsonObject('CST_FTS'))   ,        NIL}) 

        MsExecAuto({|x, y, z| mata415(x, y, z)},aCabec,aItens,nOpc)
        IF lMsErroAuto
            self:setStatus(404)
            self:setResponse(GetAutoGRLog())
            lRet := .T.
        ELSE
            Self:SetResponse("Alterado com sucesso.")
        EndIF
    ELSE
        self:setStatus(404)
        self:setResponse('{"ERROR":"Pedido '+self:num+' não localizado "}')
        lRet := .T.
    EndIF
EndIf
 
RestArea(aArea)
FreeObj(oJson)
 
Return(lRet)
