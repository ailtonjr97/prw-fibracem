//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"



WSRESTFUL CONSULTA_SA3 DESCRIPTION 'Retorna vendedores'
    //Atributos
    WSDATA id         AS STRING
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
    WSDATA num        AS STRING
    WSDATA fts        AS STRING 
    WSDATA valor      AS STRING
    WSDATA transp     AS STRING 
    WSDATA empresa    AS STRING
    WSDATA stamp      AS STRING
    WSDATA codigo     AS STRING
    WSDATA nome       AS STRING
    WSDATA email       AS STRING
    //Métodos
    WSMETHOD GET     ID      DESCRIPTION 'Retorna o registro pesquisado'     WSSYNTAX '/CONSULTA_SA3/get_id?{updated_at}'                                                PATH 'get_id'  PRODUCES APPLICATION_JSON
    WSMETHOD GET     COD     DESCRIPTION 'Retorna A3_COD do ultimo vendedor' WSSYNTAX '/CONSULTA_SA3/get_cod?{updated_at}'                                               PATH 'get_cod' PRODUCES APPLICATION_JSON
    WSMETHOD GET     ALL     DESCRIPTION 'Retorna todos os registros'        WSSYNTAX '/CONSULTA_SA3/get_all?{updated_at, limit, page, updated_at, codigo, nome, email}' PATH 'get_all' PRODUCES APPLICATION_JSON
    WSMETHOD PUT     UPDATE  DESCRIPTION 'Edita vendedor'                    WSSYNTAX '/CONSULTA_SA3/update'                                                             PATH 'update'  PRODUCES APPLICATION_JSON
    WSMETHOD DELETE  REMOVE  DESCRIPTION 'Exclui vendedor'                   WSSYNTAX '/CONSULTA_SA3/delete'                                                             PATH 'delete'  PRODUCES APPLICATION_JSON
    WSMETHOD POST    INSERT  DESCRIPTION 'Cria vendedor'                     WSSYNTAX '/CONSULTA_SA3/insert'                                                             PATH 'insert'  PRODUCES APPLICATION_JSON
    WSMETHOD GET     TUDO    DESCRIPTION 'Retorna os registros com stamp'    WSSYNTAX '/CONSULTA_SA3/tudo?{updated_at, limit, page}'                                     PATH 'tudo'    PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD GET ID WSRECEIVE id, empresa WSSERVICE CONSULTA_SA3
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SA3'
    Local nEmpresa   := ''

        If ! Empty(::empresa)
            nEmpresa := ::empresa
        EndIf
    //Se o id estiver vazio
    If Empty(::id)
        //SetRestFault(500, 'Falha ao consultar o registro') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'ID001'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else
        DbSelectArea(cAliasWS)
        (cAliasWS)->(DbSetOrder(1))

        //Se não encontrar o registro
        If ! (cAliasWS)->(MsSeek(nEmpresa + ::id))
            //SetRestFault(500, 'Falha ao consultar ID') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
            Self:setStatus(500) 
            jResponse['errorId']  := 'ID002'
            jResponse['error']    := 'ID não encontrado'
            jResponse['solution'] := 'Código ID não encontrado na tabela ' + cAliasWS
        Else

            //Define o retorno
            jResponse['filial'] := (cAliasWS)->A3_FILIAL

        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

WSMETHOD GET COD WSRECEIVE cod WSSERVICE CONSULTA_SA3
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local a3Cod      := ''
    Local a3Nome     := ''
    Local a3Email    := ''
    Local data       := ''
    Local oRegistro
    Local cAliasWS   := 'SA3'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf
    If ! Empty(::codigo)
        a3Cod := ::codigo
    EndIf
    If ! Empty(::nome)
        a3Nome := ::nome
    EndIf
    If ! Empty(::email)
        a3Email := ::email
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT TOP 1 A3_COD, TAB.R_E_C_N_O_ AS TABREC FROM " + RetSQLName(cAliasWS) + " TAB ORDER by TABREC desc " + CRLF
    TCQuery cQueryTab New Alias 'QRY_TAB'

    //Se não encontrar registros
    If QRY_TAB->(EoF())
        //SetRestFault(500, 'Falha ao consultar registros') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
        Self:setStatus(404) 
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) não encontrado(s)'
        jResponse['solution'] := 'A consulta de registros não retornou nenhuma informação'
    Else
        jResponse['objects'] := {}

        //Conta o total de registros
        Count To nTotal
        QRY_TAB->(DbGoTop())

        //O tamanho do retorno, será o limit, se ele estiver definido
        If ! Empty(::limit)
            nTamanho := ::limit
        EndIf

        //Pegando total de páginas
        nPags := NoRound(nTotal / nTamanho, 0)
        nPags += Iif(nTotal % nTamanho != 0, 1, 0)
        
        //Se vier página
        If ! Empty(::page)
            nPagina := ::page
        EndIf

        //Se a página vier zerada ou negativa ou for maior que o máximo, será 1 
        If nPagina <= 0 .Or. nPagina > nPags
            nPagina := 1
        EndIf

        //Se a página for diferente de 1, pula os registros
        If nPagina != 1
            QRY_TAB->(DbSkip((nPagina-1) * nTamanho))
        EndIf

        //Adiciona os dados para a meta
        jJsonMeta := JsonObject():New()
        jJsonMeta['total']         := nTotal
        jJsonMeta['current_page']  := nPagina
        jJsonMeta['total_page']    := nPags
        jJsonMeta['total_items']   := nTamanho
        jResponse['meta'] := jJsonMeta

        //Percorre os registros
        While ! QRY_TAB->(EoF())
            nAtual++
            
            //Se ultrapassar o limite, encerra o laço
            If nAtual > nTamanho
                Exit
            EndIf

            //Posiciona o registro e adiciona no retorno
            DbSelectArea(cAliasWS)
            (cAliasWS)->(DbGoTo(QRY_TAB->TABREC))
            
            oRegistro := JsonObject():New()
            oRegistro['cod'] := (cAliasWS)->A3_COD
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet



WSMETHOD GET ALL WSRECEIVE limit, page, codigo, nome, email WSSERVICE CONSULTA_SA3
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local a3Cod      := ''
    Local a3Nome     := ''
    Local a3Email    := ''
    Local data       := ''
    Local oRegistro
    Local cAliasWS   := 'SA3'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf
    If ! Empty(::codigo)
        a3Cod := ::codigo
    EndIf
    If ! Empty(::nome)
        a3Nome := ::nome
    EndIf
    If ! Empty(::email)
        a3Email := ::email
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC, TAB.R_E_C_D_E_L_ AS RECDEL " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    If ! Empty(data)
        cQueryTab += " WHERE S_T_A_M_P_ >= CONVERT(date,'" + data + "',103)" + CRLF
    EndIf
    If Empty(data)
        cQueryTab += " WHERE A3_COD LIKE '%" + a3Cod + "%'" + CRLF
        cQueryTab += " AND A3_NOME LIKE '%" + a3Nome + "%'" + CRLF
        cQueryTab += " AND A3_EMAIL LIKE '%" + a3Email + "%'" + CRLF
        cQueryTab += " AND TAB.R_E_C_D_E_L_ = 0" + CRLF
    EndIf
    cQueryTab += " ORDER BY " + CRLF
    cQueryTab += "     TABREC " + CRLF
    TCQuery cQueryTab New Alias 'QRY_TAB'

    //Se não encontrar registros
    If QRY_TAB->(EoF())
        //SetRestFault(500, 'Falha ao consultar registros') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
        Self:setStatus(404) 
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) não encontrado(s)'
        jResponse['solution'] := 'A consulta de registros não retornou nenhuma informação'
    Else
        jResponse['objects'] := {}

        //Conta o total de registros
        Count To nTotal
        QRY_TAB->(DbGoTop())

        //O tamanho do retorno, será o limit, se ele estiver definido
        If ! Empty(::limit)
            nTamanho := ::limit
        EndIf

        //Pegando total de páginas
        nPags := NoRound(nTotal / nTamanho, 0)
        nPags += Iif(nTotal % nTamanho != 0, 1, 0)
        
        //Se vier página
        If ! Empty(::page)
            nPagina := ::page
        EndIf

        //Se a página vier zerada ou negativa ou for maior que o máximo, será 1 
        If nPagina <= 0 .Or. nPagina > nPags
            nPagina := 1
        EndIf

        //Se a página for diferente de 1, pula os registros
        If nPagina != 1
            QRY_TAB->(DbSkip((nPagina-1) * nTamanho))
        EndIf

        //Adiciona os dados para a meta
        jJsonMeta := JsonObject():New()
        jJsonMeta['total']         := nTotal
        jJsonMeta['current_page']  := nPagina
        jJsonMeta['total_page']    := nPags
        jJsonMeta['total_items']   := nTamanho
        jResponse['meta'] := jJsonMeta

        //Percorre os registros
        While ! QRY_TAB->(EoF())
            nAtual++
            
            //Se ultrapassar o limite, encerra o laço
            If nAtual > nTamanho
                Exit
            EndIf

            //Posiciona o registro e adiciona no retorno
            DbSelectArea(cAliasWS)
            (cAliasWS)->(DbGoTo(QRY_TAB->TABREC))
            
            oRegistro := JsonObject():New()
            oRegistro['filial'] := (cAliasWS)->A3_FILIAL
            oRegistro['cod'] := (cAliasWS)->A3_COD
            oRegistro['nome'] := (cAliasWS)->A3_NOME 
            oRegistro['nreduz'] := (cAliasWS)->A3_NREDUZ
            oRegistro['end'] := (cAliasWS)->A3_END
            oRegistro['bairro'] := (cAliasWS)->A3_BAIRRO
            oRegistro['mun'] := (cAliasWS)->A3_MUN
            oRegistro['est'] := (cAliasWS)->A3_EST
            oRegistro['cep'] := (cAliasWS)->A3_CEP
            oRegistro['dddtel'] := (cAliasWS)->A3_DDDTEL
            oRegistro['tel'] := (cAliasWS)->A3_TEL
            oRegistro['email'] := (cAliasWS)->A3_EMAIL
            oRegistro['R_E_C_N_O_'] := QRY_TAB->TABREC
            oRegistro['R_E_C_D_E_L_'] := QRY_TAB->RECDEL
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

WSMETHOD PUT UPDATE WSRECEIVE WSRESTFUL CONSULTA_SA3
Local lRet      := .T.
Local aArea     := GetArea()
Local oJson
Local cJson     := Self:GetContent()
Local cError    := ''
Local nOpc      := 4 //Número 4 indica update
Local aSA3Auto := {}
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

    aAdd(aSA3Auto, {"A3_FILIAL", AllTrim(oJson:GetJsonObject('A3_FILIAL')), nil})
    aAdd(aSA3Auto, {"A3_COD"   , AllTrim(oJson:GetJsonObject('A3_COD')), nil})
    aAdd(aSA3Auto, {"A3_NOME"  , AllTrim(oJson:GetJsonObject('A3_NOME')), nil})
    aAdd(aSA3Auto, {"A3_EMAIL"  , AllTrim(oJson:GetJsonObject('A3_EMAIL')), nil})
    aAdd(aSA3Auto, {"A3_END"  , AllTrim(oJson:GetJsonObject('A3_END')), nil})
    aAdd(aSA3Auto, {"A3_BAIRRO"  , AllTrim(oJson:GetJsonObject('A3_BAIRRO')), nil})
    aAdd(aSA3Auto, {"A3_MUN"  , AllTrim(oJson:GetJsonObject('A3_MUN')), nil})
    aAdd(aSA3Auto, {"A3_EST"  , AllTrim(oJson:GetJsonObject('A3_EST')), nil})
    aAdd(aSA3Auto, {"A3_CEP"  , AllTrim(oJson:GetJsonObject('A3_CEP')), nil})
    aAdd(aSA3Auto, {"A3_DDDTEL"  , AllTrim(oJson:GetJsonObject('A3_DDDTEL')), nil})
    aAdd(aSA3Auto, {"A3_TEL"  , AllTrim(oJson:GetJsonObject('A3_TEL')), nil})
    //aAdd(aAI0Auto,{"AI0_CODCLI",     AllTrim(oJson:GetJsonObject('AI0_CODCLI'))   ,        NIL})


    MSExecAuto({|x,y,z|mata040(x,y,z)},aSA3Auto,nOpc)
    
    IF lMsErroAuto
        self:setStatus(404)
        self:setResponse(GetAutoGRLog())
        lRet := .T.
    ELSE
        Self:SetResponse("Alterado com sucesso. ")
    EndIF 

    EndIf    
    
EndIf

RestArea(aArea)
FreeObj(oJson)
 
Return

WSMETHOD DELETE REMOVE WSRECEIVE WSRESTFUL CONSULTA_SA3
Local lRet      := .T.
Local aArea     := GetArea()
Local oJson
Local cJson     := Self:GetContent()
Local cError    := ''
Local nOpc      := 5 //Número 5 indica delete
Local aSA3Auto := {}
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

    aAdd(aSA3Auto, {"A3_FILIAL", AllTrim(oJson:GetJsonObject('A3_FILIAL')), nil})
    aAdd(aSA3Auto, {"A3_COD"   , AllTrim(oJson:GetJsonObject('A3_COD')), nil})
    //aAdd(aAI0Auto,{"AI0_CODCLI",     AllTrim(oJson:GetJsonObject('AI0_CODCLI'))   ,        NIL})


    MSExecAuto({|x,y,z|mata040(x,y,z)},aSA3Auto,nOpc)
    
    IF lMsErroAuto
        self:setStatus(404)
        self:setResponse("Erro ao excluir" + GetAutoGRLog())
        lRet := .T.
    ELSE
        Self:SetResponse("Excluído com sucesso. ")
    EndIF 

    EndIf    
    
EndIf

RestArea(aArea)
FreeObj(oJson)
 
Return

WSMETHOD POST INSERT WSRECEIVE WSRESTFUL CONSULTA_SA3
Local lRet      := .T.
Local aArea     := GetArea()
Local oJson
Local cJson     := Self:GetContent()
Local cError    := ''
Local nOpc      := 3 //Número 3 indica insert
Local aSA3Auto := {}
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

    aAdd(aSA3Auto, {"A3_FILIAL", "0101", nil})
    aAdd(aSA3Auto, {"A3_COD", AllTrim(oJson:GetJsonObject('A3_COD')), nil})
    aAdd(aSA3Auto, {"A3_NOME", AllTrim(oJson:GetJsonObject('A3_NOME')), nil})
    aAdd(aSA3Auto, {"A3_MSBLQL", "2", nil})
    aAdd(aSA3Auto, {"A3_GERASE2", "F", nil})
    aAdd(aSA3Auto, {"A3_COMIS", 0, nil})
    aAdd(aSA3Auto, {"A3_ALEMISS", 0, nil})
    aAdd(aSA3Auto, {"A3_ALEMISS", 0, nil})
    aAdd(aSA3Auto, {"A3_QTCONTA", 0, nil})
    aAdd(aSA3Auto, {"A3_ACREFIN", "N", nil})
    aAdd(aSA3Auto, {"A3_DIA", 0, nil})
    aAdd(aSA3Auto, {"A3_PERDESC", 0, nil})
    aAdd(aSA3Auto, {"A3_DIARESE", 0, nil})
    aAdd(aSA3Auto, {"A3_SINCTAF", "S", nil})
    aAdd(aSA3Auto, {"A3_SINCAGE", "S", nil})
    aAdd(aSA3Auto, {"A3_SINCCON", "S", nil})
    aAdd(aSA3Auto, {"A3_PERAGE", "A", nil})
    aAdd(aSA3Auto, {"A3_PERTAF", "A", nil})
    aAdd(aSA3Auto, {"A3_TIMEMIN", "30", nil})
    aAdd(aSA3Auto, {"A3_NIVEL", 0, nil})
    aAdd(aSA3Auto, {"A3_BIAGEND", "2", nil})
    aAdd(aSA3Auto, {"A3_BITAREF", "2", nil})
    aAdd(aSA3Auto, {"A3_BICONT", "2", nil})
    aAdd(aSA3Auto, {"A3_BASEIR", "1", nil})
    aAdd(aSA3Auto, {"A3_HAND", "1", nil})
    aAdd(aSA3Auto, {"A3_MODTRF", "1", nil})
    aAdd(aSA3Auto, {"A3_XCOMISP", "1", nil})
    //aAdd(aAI0Auto,{"AI0_CODCLI",     AllTrim(oJson:GetJsonObject('AI0_CODCLI'))   ,        NIL})


    MSExecAuto({|x,y,z|mata040(x,y,z)},aSA3Auto,nOpc)
    
    IF lMsErroAuto
        self:setStatus(404)
        self:setResponse(GetAutoGRLog())
        lRet := .T.
    ELSE
        Self:SetResponse("Criado com sucesso.")
    EndIF 

    EndIf    
    
EndIf

RestArea(aArea)
FreeObj(oJson)
 
Return

WSMETHOD GET TUDO WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SA3
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 1000000
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local data       := ''
    Local oRegistro
    Local cAliasWS   := 'SA3'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT" + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC, TAB.R_E_C_D_E_L_ AS RECDEL, TAB.S_T_A_M_P_ AS STAMP" + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    If ! Empty(data)
        cQueryTab += " WHERE S_T_A_M_P_ >= CONVERT(date,'" + data + "',103)" + CRLF
    EndIf
    cQueryTab += " ORDER BY " + CRLF
    cQueryTab += "     TABREC DESC" + CRLF
    TCQuery cQueryTab New Alias 'QRY_TAB'

    //Se nÃƒÂ£o encontrar registros
    If QRY_TAB->(EoF())
        //SetRestFault(500, 'Falha ao consultar registros') //caso queira usar esse comando, vocÃƒÂª nÃƒÂ£o poderÃƒÂ¡ usar outros retornos, como os abaixo
        Self:setStatus(404) 
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) nÃƒÂ£o encontrado(s)'
        jResponse['solution'] := 'A consulta de registros nÃƒÂ£o retornou nenhuma informaÃƒÂ§ÃƒÂ£o'
    Else
        jResponse['objects'] := {}

        //Conta o total de registros
        Count To nTotal
        QRY_TAB->(DbGoTop())

        //O tamanho do retorno, serÃƒÂ¡ o limit, se ele estiver definido
        If ! Empty(::limit)
            nTamanho := ::limit
        EndIf

        //Pegando total de pÃƒÂ¡ginas
        nPags := NoRound(nTotal / nTamanho, 0)
        nPags += Iif(nTotal % nTamanho != 0, 1, 0)
        
        //Se vier pÃƒÂ¡gina
        If ! Empty(::page)
            nPagina := ::page
        EndIf

        //Se a pÃƒÂ¡gina vier zerada ou negativa ou for maior que o mÃƒÂ¡ximo, serÃƒÂ¡ 1 
        If nPagina <= 0 .Or. nPagina > nPags
            nPagina := 1
        EndIf

        //Se a pÃƒÂ¡gina for diferente de 1, pula os registros
        If nPagina != 1
            QRY_TAB->(DbSkip((nPagina-1) * nTamanho))
        EndIf

        //Adiciona os dados para a meta
        jJsonMeta := JsonObject():New()
        jJsonMeta['total']         := nTotal
        jJsonMeta['current_page']  := nPagina
        jJsonMeta['total_page']    := nPags
        jJsonMeta['total_items']   := nTamanho
        jResponse['meta'] := jJsonMeta

        //Percorre os registros
        While ! QRY_TAB->(EoF())
            nAtual++
            
            //Se ultrapassar o limite, encerra o laÃƒÂ§o
            If nAtual > nTamanho
                Exit
            EndIf

            //Posiciona o registro e adiciona no retorno
            DbSelectArea(cAliasWS)
            (cAliasWS)->(DbGoTo(QRY_TAB->TABREC))
            
            oRegistro := JsonObject():New()
            oRegistro['A3_FILIAL'   ]   := (cAliasWS)->A3_FILIAL
            oRegistro['A3_COD'      ]   := (cAliasWS)->A3_COD
            oRegistro['A3_NOME'     ]   := (cAliasWS)->A3_NOME
            oRegistro['A3_NREDUZ'   ]   := (cAliasWS)->A3_NREDUZ
            oRegistro['A3_END'      ]   := (cAliasWS)->A3_END
            oRegistro['A3_BAIRRO'   ]   := (cAliasWS)->A3_BAIRRO
            oRegistro['A3_MUN'      ]   := (cAliasWS)->A3_MUN
            oRegistro['S_T_A_M_P_'  ]   := QRY_TAB->STAMP
            oRegistro['R_E_C_N_O_'  ]   := QRY_TAB->TABREC
            oRegistro['R_E_C_D_E_L_']   := QRY_TAB->RECDEL
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet
