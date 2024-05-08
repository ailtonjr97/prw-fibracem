#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#include "rwmake.ch"
#include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"
 
/*/{Protheus.doc} User Function orcamentos_2
    (Api REST para consulta de pedidos de venda)
    @type  Function
    @author Leandro Lemos
    @since 08/05/2020
    @version P12 
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    https://tdn.totvs.com/pages/releaseview.action?pageId=6784012
 
Data        Analista        Altera��o
20/092020   Leandro Lemos   POST - Alterado tratamento do retorno de erros, removido tratamento para numera��o dos pedidos, 
                            o campo C5_NUM ja tem GETSXENUM() no iniciador 
                            Adicionado verbo PUT
    /*/
 
WSRESTFUL orcamentos_2 DESCRIPTION "Api REST para consulta de pedidos de venda"
 
    WSDATA page AS INTEGER OPTIONAL
    WSDATA pageSize AS INTEGER OPTIONAL
    WSDATA cSalesOrder AS STRING OPTIONAL
 
    WSMETHOD PUT    putSales  DESCRIPTION 'Edita or�amento'        WSSYNTAX '/api/v4/salesorder' PATH '/api/v4/salesorder' PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD PUT putSales WSRECEIVE WSRESTFUL orcamentos_2
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
 
// vari�vel de controle interno da rotina automatica que informa se houve erro durante o processamento
Private lMsErroAuto := .F.
// for�a a grava��o das informa��es de erro em array para manipula��o da grava��o ao inv�s de gravar direto no arquivo tempor�rio 
Private lAutoErrNoFile := .T.
 
//Definindo o conte�do como JSON, e pegando o content e dando um parse para ver se a estrutura est� ok
Self:SetContentType("application/json")
oJson   := JsonObject():New()
cError  := oJson:FromJson(cJson)
//Se tiver algum erro no Parse, encerra a execu��o
IF !Empty(cError)
    SetRestFault(500,'Parser Json Error')
    lRet    := .F.
elseif Empty(self:cSalesOrder)
    cSalesOrder := "000876"
Else
    cAlias := 'SCJ'
    //Antes de iniciar � validade se o cliente ou fornecedor existe
    DbSelectArea(cAlias)
    (cAlias)->(dbSetOrder(1))
    //Se  o pedido existir entra no loop
    IF ((cAlias)->(dbSeek(FWxFilial(cAlias)+PadR(oJson:GetJsonObject('NUM'),TamSX3("CJ_NUM")[1]))))
        aCabec  := {}
        aItens  := {}
        /*
        N-> Pedidos Normais.
        B-> Apres. Fornec. qdo material p/Benef.
        */
        //Numera��o removida para gera��o automatica da rotina
        //O inicializador padr�o do campo C5_NUM j� tenha a fun��o GetSXENum()
        aAdd(aCabec,{"CJ_CST_FTS",     AllTrim(oJson:GetJsonObject('CST_FTS'))   ,        NIL})
 

        //Chama a inclus�o autom�tica de pedido de venda
        MsExecAuto({|x, y| mata410(x, y)},aCabec,nOpc)
        //Caso haja erro inicia o tratamento e retorno do mensagem
        IF lMsErroAuto
            cErro := u_retErroAuto(GetAutoGRLog())
            self:setStatus(404)
            self:setResponse(cErro)
            lRet := .T.
        ELSE
            cJsonRet := '{"NUM":"' + SCJ->CJ_NUM + '"';
                + ',"RETURN":true';
                + ',"MESSAGE":"Alterado com sucesso."}'
            Self:SetResponse(cJsonRet)
        EndIF
    ELSE
        self:setStatus(404)
        self:setResponse('{"ERROR":"Pedido '+self:cSalesOrder+' n�o localizado "}')
        lRet := .T.
    EndIF
EndIf
 
RestArea(aArea)
FreeObj(oJson)
 
Return(lRet)
