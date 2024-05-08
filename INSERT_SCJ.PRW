//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} WSRESTFUL INSERT_CSJ

@author everson
@since 27/02/2024
@version 1.0
@type wsrestful
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

WSRESTFUL INSERT_CSJ DESCRIPTION ''
    //Métodos
    WSMETHOD PUT    putSales DESCRIPTION 'Atualização de registro'       WSSYNTAX '/INSERT_CSJ/update'                            PATH 'update'        PRODUCES SalesOrder
END WSRESTFUL

/*/{Protheus.doc} WSMETHOD PUT UPDATE
Atualiza o registro na tabela
@author everson
@since 27/02/2024
@version 1.0
@type method
@param id, Caractere, String que será pesquisada através do MsSeek
@obs Codigo gerado automaticamente pelo Autumn Code Maker

    Abaixo um exemplo do JSON que deverá vir no body
    * 1: Para campos do tipo Numérico, informe o valor sem usar as aspas
    * 2: Para campos do tipo Data, informe uma string no padrão 'YYYY-MM-DD'

    {
        "cst_fts": "conteudo"
    }

@see http://autumncodemaker.com
/*/
WSMETHOD PUT putSales WSRECEIVE WSRESTFUL INSERT_CSJ
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
 
// variável de controle interno da rotina automatica que informa se houve erro durante o processamento
Private lMsErroAuto := .F.
// força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile := .T.
 
//Definindo o conteúdo como JSON, e pegando o content e dando um parse para ver se a estrutura está ok
Self:SetContentType("application/json")
oJson   := JsonObject():New()
cError  := oJson:FromJson(cJson)
//Se tiver algum erro no Parse, encerra a execução
IF !Empty(cError)
    SetRestFault(500,'Parser Json Error')
    lRet    := .F.
elseif Empty(self:cSalesOrder)
    self:setStatus(404)
    self:setResponse('{"ERROR":"Pedido não informado "}')
Else
    cAlias := 'SC5'
    //Antes de iniciar é validade se o cliente ou fornecedor existe
    DbSelectArea(cAlias)
    (cAlias)->(dbSetOrder(1))
    //Se  o pedido existir entra no loop
    IF ((cAlias)->(dbSeek(FWxFilial(cAlias)+PadR(oJson:GetJsonObject('NUM'),TamSX3("C5_NUM")[1]))))
        aCabec  := {}
        aItens  := {}
        /*
        N-> Pedidos Normais.
        B-> Apres. Fornec. qdo material p/Benef.
        */
        //Numeração removida para geração automatica da rotina
        //O inicializador padrão do campo C5_NUM já tenha a função GetSXENum()
        aAdd(aCabec,{"C5_NUM",      AllTrim(oJson:GetJsonObject('NUM'))   ,         NIL})
        aAdd(aCabec,{"C5_TIPO",     AllTrim(oJson:GetJsonObject('TIPO'))   ,        NIL})
        aAdd(aCabec,{"C5_CLIENTE",  AllTrim(oJson:GetJsonObject('CLIENTE')),        NIL})
        aAdd(aCabec,{"C5_LOJACLI",  AllTrim(oJson:GetJsonObject('LOJACLI')),        NIL})
        aAdd(aCabec,{"C5_CLIENT",   AllTrim(oJson:GetJsonObject('CLIENTE')),        NIL})
        aAdd(aCabec,{"C5_LOJAENT",  AllTrim(oJson:GetJsonObject('LOJACLI')),        NIL})
        aAdd(aCabec,{"C5_TPFRETE",  AllTrim(oJson:GetJsonObject('TPFRETE')),        NIL})
        aAdd(aCabec,{"C5_CONDPAG",  AllTrim(oJson:GetJsonObject('CONDPAG')),        NIL})
        aAdd(aCabec,{"C5_MENNOTA",  AllTrim(oJson:GetJsonObject('MENNOTA')),        NIL})
        aAdd(aCabec,{"C5_NATUREZ",  AllTrim(oJson:GetJsonObject('NATUREZ')),        NIL})
 
        //Busca os itens no JSON, percorre eles e adiciona no array da SC6
        oItems  := oJson:GetJsonObject('ITENS')
        For nX  := 1 To Len (oItems)
            aLinha  := {}
            aadd(aLinha,{"LINPOS",     "C6_ITEM",                                               AllTrim(oItems[nX]:GetJsonObject('ITEM')),})
            aadd(aLinha,{"AUTDELETA",  "N",                                                     Nil})
            aAdd(aLinha,{"C6_PRODUTO",  AllTrim(oItems[nX]:GetJsonObject('PRODUTO')),           NIL})
            aAdd(aLinha,{"C6_QTDVEN",   oItems[nX]:GetJsonObject('QTDVEN'),                     NIL})
            aAdd(aLinha,{"C6_PRCVEN",   oItems[nX]:GetJsonObject('PRCVEN'),                     NIL})
            aAdd(aLinha,{"C6_VALOR",    oItems[nX]:GetJsonObject('VALOR'),                      NIL})
            aAdd(aLinha,{"C6_TES",      AllTrim(oItems[nX]:GetJsonObject('TES')),               NIL})
            aAdd(aLinha,{"C6_ENTREG",   (ddatabase +30),                                        NIL})
            //Campos opcionais
            IIF(!EMPTY(oItems[nX]:GetJsonObject('CONTA')),  aAdd(aLinha,{"C6_CONTA",     AllTrim(oItems[nX]:GetJsonObject('CONTA')),         NIL}),)
            IIF(!EMPTY(oItems[nX]:GetJsonObject('CC')),     aAdd(aLinha,{"C6_CC",        AllTrim(oItems[nX]:GetJsonObject('CC')),            NIL}),'')
            //Só grava os dados de projeto se for enviado projeto, tarefa e edt
            IF (!EMPTY(oItems[nX]:GetJsonObject('PROJPMS')) .and. !EMPTY(oItems[nX]:GetJsonObject('REVISAO')) .and. !EMPTY(oItems[nX]:GetJsonObject('TASKPMS')))
                aAdd(aLinha,{"C6_PROJPMS",   AllTrim(oItems[nX]:GetJsonObject('PROJPMS')),       NIL})
                aAdd(aLinha,{"C6_REVISAO",    AllTrim(oItems[nX]:GetJsonObject('REVISAO')),      NIL})
                aAdd(aLinha,{"C6_TASKPMS",   AllTrim(oItems[nX]:GetJsonObject('TASKPMS')),       NIL})
            EndIF
 
            aAdd(aItens,aLinha)
 
        Next nX
        //Chama a inclusão automática de pedido de venda
        MsExecAuto({|x, y, z| mata410(x, y, z)},aCabec,aItens,nOpc)
        //Caso haja erro inicia o tratamento e retorno do mensagem
        IF lMsErroAuto
            cErro := u_retErroAuto(GetAutoGRLog())
            self:setStatus(404)
            self:setResponse(cErro)
            lRet := .T.
        ELSE
            cJsonRet := '{"NUM":"' + SC5->C5_NUM + '"';
                + ',"RETURN":true';
                + ',"MESSAGE":"Alterado com sucesso."}'
            Self:SetResponse(cJsonRet)
        EndIF
    ELSE
        self:setStatus(404)
        self:setResponse('{"ERROR":"Pedido '+self:cSalesOrder+' não localizado "}')
        lRet := .T.
    EndIF
EndIf
 
RestArea(aArea)
FreeObj(oJson)
 
Return(lRet)
