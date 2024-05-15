//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"



WSRESTFUL CONSULTA_SD2 DESCRIPTION ''
    //Atributos
    WSDATA id         AS STRING
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
 
    //Métodos
    WSMETHOD GET ID   DESCRIPTION 'Retorna o registro pesquisado'        WSSYNTAX '/CONSULTA_SD2/get_id?{id}'                       PATH 'get_id'  PRODUCES APPLICATION_JSON
    WSMETHOD GET ALL  DESCRIPTION 'Retorna todos os registros'           WSSYNTAX '/CONSULTA_SD2/get_all?{updated_at, limit, page}' PATH 'get_all' PRODUCES APPLICATION_JSON
    WSMETHOD GET TUDO DESCRIPTION 'Retorna todos os registros com stamp' WSSYNTAX '/CONSULTA_SD2/tudo?{updated_at, limit, page}'    PATH 'tudo'    PRODUCES APPLICATION_JSON
END WSRESTFUL



WSMETHOD GET ID WSRECEIVE id WSSERVICE CONSULTA_SD2
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SD2'

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
            jResponse['loja'] := (cAliasWS)->D2_LOJA 
            jResponse['filial'] := (cAliasWS)->D2_FILIAL 
            jResponse['doc'] := (cAliasWS)->D2_DOC 
            jResponse['serie'] := (cAliasWS)->D2_SERIE 
            jResponse['cliente'] := (cAliasWS)->D2_CLIENTE 
            jResponse['item'] := (cAliasWS)->D2_ITEM 
            jResponse['cod'] := (cAliasWS)->D2_COD 
            jResponse['um'] := (cAliasWS)->D2_UM 
            jResponse['pedido'] := (cAliasWS)->D2_PEDIDO 
            jResponse['tipo'] := (cAliasWS)->D2_TIPO 
            jResponse['origlan'] := (cAliasWS)->D2_ORIGLAN 
            jResponse['tes'] := (cAliasWS)->D2_TES 
            jResponse['cf'] := (cAliasWS)->D2_CF 
            jResponse['quant'] := (cAliasWS)->D2_QUANT 
            jResponse['prunit'] := (cAliasWS)->D2_PRUNIT 
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet


WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SD2
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local oRegistro
    Local cAliasWS   := 'SD2'

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE " + CRLF
    cQueryTab += "     TAB.D_E_L_E_T_ = '' " + CRLF
    If ! Empty(::updated_at)
        cQueryTab += "     AND ((CASE WHEN SUBSTRING(D2_USERLGA, 03, 1) != ' ' THEN " + CRLF
        cQueryTab += "        CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(D2_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(D2_USERLGA,16,1)) - 50)),'19960101'),112) " + CRLF
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
            oRegistro['loja'] := (cAliasWS)->D2_LOJA 
            oRegistro['filial'] := (cAliasWS)->D2_FILIAL 
            oRegistro['doc'] := (cAliasWS)->D2_DOC 
            oRegistro['serie'] := (cAliasWS)->D2_SERIE 
            oRegistro['cliente'] := (cAliasWS)->D2_CLIENTE 
            oRegistro['item'] := (cAliasWS)->D2_ITEM 
            oRegistro['cod'] := (cAliasWS)->D2_COD 
            oRegistro['um'] := (cAliasWS)->D2_UM 
            oRegistro['pedido'] := (cAliasWS)->D2_PEDIDO 
            oRegistro['tipo'] := (cAliasWS)->D2_TIPO 
            oRegistro['origlan'] := (cAliasWS)->D2_ORIGLAN 
            oRegistro['tes'] := (cAliasWS)->D2_TES 
            oRegistro['cf'] := (cAliasWS)->D2_CF 
            oRegistro['quant'] := (cAliasWS)->D2_QUANT 
            oRegistro['prunit'] := (cAliasWS)->D2_PRUNIT 
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

WSMETHOD GET TUDO WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SD2
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
    Local cAliasWS   := 'SD2'

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
            oRegistro['filial'] := (cAliasWS)->D2_FILIAL 
            oRegistro['item'] := (cAliasWS)->D2_ITEM 
            oRegistro['cod'] := (cAliasWS)->D2_COD 
            oRegistro['um'] := (cAliasWS)->D2_UM 
            oRegistro['quant'] := (cAliasWS)->D2_QUANT 
            oRegistro['prcven'] := (cAliasWS)->D2_PRCVEN 
            oRegistro['total'] := (cAliasWS)->D2_TOTAL 
            oRegistro['valipi'] := (cAliasWS)->D2_VALIPI 
            oRegistro['valicm'] := (cAliasWS)->D2_VALICM 
            oRegistro['tes'] := (cAliasWS)->D2_TES 
            oRegistro['cf'] := (cAliasWS)->D2_CF 
            oRegistro['ipi'] := (cAliasWS)->D2_IPI 
            oRegistro['picm'] := (cAliasWS)->D2_PICM 
            oRegistro['op'] := (cAliasWS)->D2_OP 
            oRegistro['pedido'] := (cAliasWS)->D2_PEDIDO 
            oRegistro['itempv'] := (cAliasWS)->D2_ITEMPV 
            oRegistro['cliente'] := (cAliasWS)->D2_CLIENTE 
            oRegistro['loja'] := (cAliasWS)->D2_LOJA 
            oRegistro['doc'] := (cAliasWS)->D2_DOC 
            oRegistro['serie'] := (cAliasWS)->D2_SERIE 
            oRegistro['grupo'] := (cAliasWS)->D2_GRUPO 
            oRegistro['tp'] := (cAliasWS)->D2_TP 
            oRegistro['emissao'] := (cAliasWS)->D2_EMISSAO 
            oRegistro['custo1'] := (cAliasWS)->D2_CUSTO1 
            oRegistro['prunit'] := (cAliasWS)->D2_PRUNIT 
            oRegistro['est'] := (cAliasWS)->D2_EST 
            oRegistro['tipo'] := (cAliasWS)->D2_TIPO 
            oRegistro['nfori'] := (cAliasWS)->D2_NFORI 
            oRegistro['seriori'] := (cAliasWS)->D2_SERIORI 
            oRegistro['qtdedev'] := (cAliasWS)->D2_QTDEDEV 
            oRegistro['valdev'] := (cAliasWS)->D2_VALDEV 
            oRegistro['origlan'] := (cAliasWS)->D2_ORIGLAN 
            oRegistro['bricms'] := (cAliasWS)->D2_BRICMS 
            oRegistro['baseicm'] := (cAliasWS)->D2_BASEICM 
            oRegistro['icmsret'] := (cAliasWS)->D2_ICMSRET 
            oRegistro['clasfis'] := (cAliasWS)->D2_CLASFIS 
            oRegistro['basimp5'] := (cAliasWS)->D2_BASIMP5 
            oRegistro['basimp6'] := (cAliasWS)->D2_BASIMP6 
            oRegistro['valimp5'] := (cAliasWS)->D2_VALIMP5 
            oRegistro['valimp6'] := (cAliasWS)->D2_VALIMP6 
            oRegistro['alqimp5'] := (cAliasWS)->D2_ALQIMP5 
            oRegistro['alqimp6'] := (cAliasWS)->D2_ALQIMP6 
            oRegistro['baseipi'] := (cAliasWS)->D2_BASEIPI 
            oRegistro['seguro'] := (cAliasWS)->D2_SEGURO 
            oRegistro['valfre'] := (cAliasWS)->D2_VALFRE 
            oRegistro['despesa'] := (cAliasWS)->D2_DESPESA 
            oRegistro['valbrut'] := (cAliasWS)->D2_VALBRUT 
            oRegistro['bsfcpst'] := (cAliasWS)->D2_BSFCPST 
            oRegistro['vfecpst'] := (cAliasWS)->D2_VFECPST 
            oRegistro['S_T_A_M_P_']   := QRY_TAB->STAMP
            oRegistro['R_E_C_N_O_']   := QRY_TAB->TABREC
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
