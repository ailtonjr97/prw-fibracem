//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"



WSRESTFUL CONSULTA_PRO DESCRIPTION ''
    //Atributos
    WSDATA id         AS STRING
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
 
    //Métodos
    WSMETHOD GET ID          DESCRIPTION 'Retorna o registro pesquisado'        WSSYNTAX '/CONSULTA_PRO/get_id?{id}'                         PATH 'get_id'    PRODUCES APPLICATION_JSON
    WSMETHOD GET ALL         DESCRIPTION 'Retorna todos os registros'           WSSYNTAX '/CONSULTA_PRO/get_all?{updated_at, limit, page}'   PATH 'get_all'   PRODUCES APPLICATION_JSON
    WSMETHOD GET TRACK_ORDER DESCRIPTION 'Retorna registros para o Track Order' WSSYNTAX '/CONSULTA_PRO/get_track?{updated_at, limit, page}' PATH 'get_track' PRODUCES APPLICATION_JSON
END WSRESTFUL



WSMETHOD GET ID WSRECEIVE id WSSERVICE CONSULTA_PRO
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SB1'

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
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            //SetRestFault(500, 'Falha ao consultar ID') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
            Self:setStatus(500) 
            jResponse['errorId']  := 'ID002'
            jResponse['error']    := 'ID não encontrado'
            jResponse['solution'] := 'Código ID não encontrado na tabela ' + cAliasWS
        Else
            //Define o retorno
            jResponse['cod'] := (cAliasWS)->B1_COD 
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet



WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_PRO
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local oRegistro
    Local cAliasWS   := 'SB1'

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE " + CRLF
    cQueryTab += "     TAB.D_E_L_E_T_ = '' " + CRLF
    If ! Empty(::updated_at)
        cQueryTab += "     AND ((CASE WHEN SUBSTRING(B1_USERLGA, 03, 1) != ' ' THEN " + CRLF
        cQueryTab += "        CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(B1_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(B1_USERLGA,16,1)) - 50)),'19960101'),112) " + CRLF
        cQueryTab += "        ELSE '' " + CRLF
        cQueryTab += "     END) >= '" + StrTran(::updated_at, '-', '') + "') " + CRLF
    EndIf
    cQueryTab += " ORDER BY " + CRLF
    cQueryTab += "     TABREC " + CRLF
    TCQuery cQueryTab New Alias 'QRY_TAB'

    //Se não encontrar registros
    If QRY_TAB->(EoF())
        //SetRestFault(500, 'Falha ao consultar registros') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
        Self:setStatus(500) 
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
            oRegistro['cod'] := (cAliasWS)->B1_COD 
            oRegistro['tipo'] := (cAliasWS)->B1_TIPO 
            oRegistro['um'] := (cAliasWS)->B1_UM 
            oRegistro['grupo'] := (cAliasWS)->B1_GRUPO 
            oRegistro['peso'] := (cAliasWS)->B1_PESO 
            oRegistro['urev'] := (cAliasWS)->B1_UREV 
            oRegistro['desc'] := (cAliasWS)->B1_DESC 
            oRegistro['pesbru'] := (cAliasWS)->B1_PESBRU 
            oRegistro['B1_X_FAMIL'] := (cAliasWS)->B1_X_FAMIL 
            oRegistro['B1_XDESCFA'] := (cAliasWS)->B1_XDESCFA 
            oRegistro['B1_X_SUBFA'] := (cAliasWS)->B1_X_SUBFA
            oRegistro['B1_XDESSUB'] := (cAliasWS)->B1_XDESSUB 
            oRegistro['B1_XDESCFA'] := (cAliasWS)->B1_XDESCFA

            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

WSMETHOD GET TRACK_ORDER WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_PRO
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10000
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local data       := ''
    Local oRegistro
    Local cAliasWS   := 'SB1'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT TAB.B1_FILIAL,TAB.B1_X_SUBFA,TAB.B1_XDESSUB,TAB.B1_XDESCFA,TAB.B1_X_FAMIL, TAB.B1_COD, TAB.B1_DESC, TAB.B1_TIPO, TAB.B1_UM, TAB.B1_GRUPO, TAB.B1_PESO, TAB.B1_UREV, TAB.B1_PESBRU," + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC, TAB.R_E_C_D_E_L_ AS RECDEL, TAB.S_T_A_M_P_ AS STAMP" + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    If ! Empty(data)
        cQueryTab += " WHERE S_T_A_M_P_ >= CONVERT(date,'" + data + "',103)" + CRLF
    EndIf
    cQueryTab += " ORDER BY " + CRLF
    cQueryTab += "     TABREC DESC" + CRLF
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
            //SELECT TAB.B1_FILIAL, TAB.B1_COD, TAB.B1_DESC, TAB.B1_TIPO, TAB.B1_UM, TAB.B1_GRUPO, TAB.B1_PESO, TAB.B1_UREV, TAB.B1_PESBRU,
            oRegistro := JsonObject():New()
            oRegistro['B1_FILIAL']      := (cAliasWS)->B1_FILIAL
            oRegistro['B1_COD']         := (cAliasWS)->B1_COD
            oRegistro['B1_DESC']        := (cAliasWS)->B1_DESC
            oRegistro['B1_TIPO']        := (cAliasWS)->B1_TIPO
            oRegistro['B1_UM']          := (cAliasWS)->B1_UM
            oRegistro['B1_GRUPO']       := (cAliasWS)->B1_GRUPO
            oRegistro['B1_PESO']        := (cAliasWS)->B1_PESO
            oRegistro['B1_UREV']        := (cAliasWS)->B1_UREV
            oRegistro['B1_PESBRU']      := (cAliasWS)->B1_PESBRU
            oRegistro['B1_X_FAMIL']     := (cAliasWS)->B1_X_FAMIL 
            oRegistro['B1_XDESCFA']     := (cAliasWS)->B1_XDESCFA 
            oRegistro['B1_X_SUBFA']     := (cAliasWS)->B1_X_SUBFA
            oRegistro['B1_XDESSUB']     := (cAliasWS)->B1_XDESSUB 
            oRegistro['S_T_A_M_P_']     := QRY_TAB->STAMP
            oRegistro['R_E_C_N_O_']     := QRY_TAB->TABREC
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
