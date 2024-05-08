#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


WSRESTFUL CONSULTA_SC6 DESCRIPTION ''
    //Atributos
    WSDATA id         AS STRING
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
    WSDATA filial     AS STRING
    WSDATA num        AS STRING
    WSDATA item       AS STRING
    WSDATA produto    AS STRING
    WSDATA hora       AS STRING
    WSDATA logado     AS STRING
 
    //Métodos
    WSMETHOD GET ID           DESCRIPTION 'Retorna o registro pesquisado'    WSSYNTAX '/CONSULTA_SC6/get_id?{id}'                                              PATH 'get_id'        PRODUCES APPLICATION_JSON
    WSMETHOD GET ALL          DESCRIPTION 'Retorna todos os registros'       WSSYNTAX '/CONSULTA_SC6/get_all?{updated_at, limit, page}'                        PATH 'get_all'       PRODUCES APPLICATION_JSON
    WSMETHOD GET TRACK_ORDER  DESCRIPTION 'Retorna registros pro tack order' WSSYNTAX '/CONSULTA_SC6/get_track?{updated_at, limit, page}'                      PATH 'get_track'     PRODUCES APPLICATION_JSON
    WSMETHOD PUT UPDATE_SEPCD DESCRIPTION 'Faz update no campo C6_XSEPCD'    WSSYNTAX '/CONSULTA_SC6/update_xsepcd?{filial, num, item, produto, hora, logado}' PATH 'update_xsepcd' PRODUCES APPLICATION_JSON
    WSMETHOD GET GET_SEPCD    DESCRIPTION 'Retorna somente C6_XSEPCD'        WSSYNTAX '/CONSULTA_SC6/get_xsepcd?{filial, num}'                                 PATH 'get_xsepcd'    PRODUCES APPLICATION_JSON
END WSRESTFUL



WSMETHOD GET ID WSRECEIVE id WSSERVICE CONSULTA_SC6
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SC6'

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
            jResponse['loja'] := (cAliasWS)->C6_LOJA 
            jResponse['num'] := (cAliasWS)->C6_NUM 
            jResponse['item'] := (cAliasWS)->C6_ITEM 
            jResponse['produto'] := (cAliasWS)->C6_PRODUTO 
            jResponse['qtdven'] := (cAliasWS)->C6_QTDVEN 
            jResponse['qtdent'] := (cAliasWS)->C6_QTDENT 
            jResponse['prcven'] := (cAliasWS)->C6_PRCVEN 
            jResponse['descont'] := (cAliasWS)->C6_DESCONT 
            jResponse['valor'] := (cAliasWS)->C6_VALOR 
            jResponse['oper'] := (cAliasWS)->C6_OPER 
            jResponse['tes'] := (cAliasWS)->C6_TES 
            jResponse['cf'] := (cAliasWS)->C6_CF 
            jResponse['cli'] := (cAliasWS)->C6_CLI 
            jResponse['entreg'] := (cAliasWS)->C6_ENTREG 
            jResponse['datfat'] := (cAliasWS)->C6_DATFAT 
            jResponse['nota'] := (cAliasWS)->C6_NOTA 
            jResponse['blq'] := (cAliasWS)->C6_BLQ 
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet



WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SC6
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local data       := ''
    Local oRegistro
    Local cAliasWS   := 'SC6'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC, TAB.R_E_C_D_E_L_ AS RECDEL, TAB.S_T_A_M_P_ AS STAMP" + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    If ! Empty(data)
        cQueryTab += " WHERE TAB.S_T_A_M_P_ >= CONVERT(date,'" + data + "',103)" + CRLF
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
            oRegistro['loja']           := (cAliasWS)->C6_LOJA 
            oRegistro['num']            := (cAliasWS)->C6_NUM 
            oRegistro['item']           := (cAliasWS)->C6_ITEM 
            oRegistro['produto']        := (cAliasWS)->C6_PRODUTO 
            oRegistro['qtdven']         := (cAliasWS)->C6_QTDVEN 
            oRegistro['qtdent']         := (cAliasWS)->C6_QTDENT 
            oRegistro['prcven']         := (cAliasWS)->C6_PRCVEN 
            oRegistro['descont']        := (cAliasWS)->C6_DESCONT 
            oRegistro['valor']          := (cAliasWS)->C6_VALOR 
            oRegistro['oper']           := (cAliasWS)->C6_OPER 
            oRegistro['tes']            := (cAliasWS)->C6_TES 
            oRegistro['cf']             := (cAliasWS)->C6_CF 
            oRegistro['cli']            := (cAliasWS)->C6_CLI 
            oRegistro['entreg']         := (cAliasWS)->C6_ENTREG 
            oRegistro['datfat']         := (cAliasWS)->C6_DATFAT 
            oRegistro['nota']           := (cAliasWS)->C6_NOTA 
            oRegistro['blq']            := (cAliasWS)->C6_BLQ 
            oRegistro['filial']         := (cAliasWS)->C6_FILIAL
            oRegistro['C6_NUMORC']      := (cAliasWS)->C6_NUMORC
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

WSMETHOD GET TRACK_ORDER WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SC6
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
    Local cAliasWS   := 'SC6'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT TAB.C6_FILIAL, TAB.C6_PRODUTO, TAB.C6_NUM, TAB.C6_ITEM, TAB.C6_QTDVEN, TAB.C6_XSEPCD, TAB.C6_DESCRI, TAB.C6_XHSEPCD, TAB.C6_XNSEPCD," + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC, TAB.R_E_C_D_E_L_ AS RECDEL, TAB.S_T_A_M_P_ AS STAMP" + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    If ! Empty(data)
        cQueryTab += " WHERE S_T_A_M_P_ >= CONVERT(date,'" + data + "',103)" + CRLF
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
            oRegistro['C6_FILIAL'] := (cAliasWS)->C6_FILIAL 
            oRegistro['C6_PRODUTO'] := (cAliasWS)->C6_PRODUTO 
            oRegistro['C6_NUM'] := (cAliasWS)->C6_NUM
            oRegistro['C6_ITEM'] := (cAliasWS)->C6_ITEM 
            oRegistro['C6_QTDVEN'] := (cAliasWS)->C6_QTDVEN 
            oRegistro['C6_XSEPCD'] := (cAliasWS)->C6_XSEPCD
            oRegistro['C6_DESCRI'] := (cAliasWS)->C6_DESCRI
            oRegistro['C6_XHSEPCD'] := (cAliasWS)->C6_XHSEPCD
            oRegistro['C6_XNSEPCD'] := (cAliasWS)->C6_XNSEPCD
            oRegistro['S_T_A_M_P_'] := QRY_TAB->STAMP
            oRegistro['R_E_C_N_O_'] := QRY_TAB->TABREC
            oRegistro['R_E_C_D_E_L_'] := QRY_TAB->RECDEL           
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

WSMETHOD PUT UPDATE_SEPCD WSRECEIVE filial, num, item, produto, hora, logado WSSERVICE CONSULTA_SC6
    Local lRet       := .T.    
    Local cQryUpd    := ''

    Begin Transaction    
      //Monta o Update
      cQryUpd := " UPDATE " + RetSqlName("SC6") + " "
      cQryUpd += " SET C6_XSEPCD = 'T', "
      cQryUpd += " C6_XHSEPCD = '"+::hora+"', C6_XNSEPCD = '"+::logado+"' " 
      cQryUpd += " WHERE "
      cQryUpd += "C6_FILIAL = '" + ::filial+ "' AND C6_NUM = '" + ::num + "' AND C6_ITEM = '" + ::item +"' AND C6_PRODUTO = '" + ::produto +"'"

      Self:SetResponse("Query:" + cQryUpd)

    //Tenta executar o update
       nErro := TcSqlExec(cQryUpd)

     //Se houve erro, mostra a mensagem e cancela a transação
      If nErro != 0
        Self:setStatus(500) 
        Self:SetResponse("ERRO! "+nErro+ "Query:" + cQryUpd)
      Else
            Self:setStatus(200) 
            Self:SetResponse("OK!")
      EndIf
    End Transaction

Return lRet

WSMETHOD GET GET_SEPCD WSRECEIVE filial, num WSSERVICE CONSULTA_SC6
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
    Local cAliasWS   := 'SC6'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT TAB.C6_XSEPCD, " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC, TAB.R_E_C_D_E_L_ AS RECDEL, TAB.S_T_A_M_P_ AS STAMP" + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    If ! Empty(data)
        cQueryTab += " WHERE S_T_A_M_P_ >= CONVERT(date,'" + data + "',103)" + CRLF
        cQueryTab += " AND TAB.C6_FILIAL = '" + ::filial + "' AND TAB.C6_NUM = '"+ ::num +"'" + CRLF
    EndIf
    cQueryTab += "WHERE TAB.C6_FILIAL = '" + ::filial + "' AND TAB.C6_NUM = '"+ ::num +"'" + CRLF
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
            oRegistro['C6_XSEPCD'] := (cAliasWS)->C6_XSEPCD 
            oRegistro['S_T_A_M_P_'] := QRY_TAB->STAMP
            oRegistro['R_E_C_N_O_'] := QRY_TAB->TABREC
            oRegistro['R_E_C_D_E_L_'] := QRY_TAB->RECDEL           
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet
