//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"


WSRESTFUL CONSULTA_SF2 DESCRIPTION ''
    //Atributos
    WSDATA id         AS STRING
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
 
    //M√©todos
    WSMETHOD GET ID    DESCRIPTION 'Retorna o registro pesquisado'  WSSYNTAX '/CONSULTA_SF2/get_id?{id}'                       PATH 'get_id'  PRODUCES APPLICATION_JSON
    WSMETHOD GET ALL   DESCRIPTION 'Retorna todos os registros'     WSSYNTAX '/CONSULTA_SF2/get_all?{updated_at, limit, page}' PATH 'get_all' PRODUCES APPLICATION_JSON
    WSMETHOD GET TUDO  DESCRIPTION 'Retorna os registros com stamp' WSSYNTAX '/CONSULTA_SF2/tudo?{updated_at, limit, page}'    PATH 'tudo'    PRODUCES APPLICATION_JSON
END WSRESTFUL



WSMETHOD GET ID WSRECEIVE id WSSERVICE CONSULTA_SF2
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SF2'

    //Se o id estiver vazio
    If Empty(::id)
        //SetRestFault(500, 'Falha ao consultar o registro') //caso queira usar esse comando, voc√™ n√£o poder√° usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'ID001'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else
        DbSelectArea(cAliasWS)
        (cAliasWS)->(DbSetOrder(1))

        //Se n√£o encontrar o registro
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            //SetRestFault(500, 'Falha ao consultar ID') //caso queira usar esse comando, voc√™ n√£o poder√° usar outros retornos, como os abaixo
            Self:setStatus(500) 
            jResponse['errorId']  := 'ID002'
            jResponse['error']    := 'ID n√£o encontrado'
            jResponse['solution'] := 'C√≥digo ID n√£o encontrado na tabela ' + cAliasWS
        Else
            //Define o retorno
            jResponse['emissao'] := (cAliasWS)->F2_EMISSAO 
            jResponse['filial'] := (cAliasWS)->F2_FILIAL 
            jResponse['chvnfe'] := (cAliasWS)->F2_CHVNFE 
            jResponse['doc'] := (cAliasWS)->F2_DOC 
            jResponse['serie'] := (cAliasWS)->F2_SERIE 
            jResponse['cliente'] := (cAliasWS)->F2_CLIENTE 
            jResponse['loja'] := (cAliasWS)->F2_LOJA 
            jResponse['tipocli'] := (cAliasWS)->F2_TIPOCLI 
            jResponse['vend1'] := (cAliasWS)->F2_VEND1 
            jResponse['fimp'] := (cAliasWS)->F2_FIMP 
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet



WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SF2
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local oRegistro
    Local cAliasWS   := 'SF2'

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE " + CRLF
    cQueryTab += "     TAB.D_E_L_E_T_ = '' " + CRLF
    If ! Empty(::updated_at)
        cQueryTab += "     AND ((CASE WHEN SUBSTRING(F2_USERLGA, 03, 1) != ' ' THEN " + CRLF
        cQueryTab += "        CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(F2_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(F2_USERLGA,16,1)) - 50)),'19960101'),112) " + CRLF
        cQueryTab += "        ELSE '' " + CRLF
        cQueryTab += "     END) >= '" + StrTran(::updated_at, '-', '') + "') " + CRLF
    EndIf
    cQueryTab += " ORDER BY " + CRLF
    cQueryTab += "     TABREC " + CRLF
    TCQuery cQueryTab New Alias 'QRY_TAB'

    //Se n√£o encontrar registros
    If QRY_TAB->(EoF())
        //SetRestFault(500, 'Falha ao consultar registros') //caso queira usar esse comando, voc√™ n√£o poder√° usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) n√£o encontrado(s)'
        jResponse['solution'] := 'A consulta de registros n√£o retornou nenhuma informa√ß√£o'
    Else
        jResponse['objects'] := {}

        //Conta o total de registros
        Count To nTotal
        QRY_TAB->(DbGoTop())

        //O tamanho do retorno, ser√° o limit, se ele estiver definido
        If ! Empty(::limit)
            nTamanho := ::limit
        EndIf

        //Pegando total de p√°ginas
        nPags := NoRound(nTotal / nTamanho, 0)
        nPags += Iif(nTotal % nTamanho != 0, 1, 0)
        
        //Se vier p√°gina
        If ! Empty(::page)
            nPagina := ::page
        EndIf

        //Se a p√°gina vier zerada ou negativa ou for maior que o m√°ximo, ser√° 1 
        If nPagina <= 0 .Or. nPagina > nPags
            nPagina := 1
        EndIf

        //Se a p√°gina for diferente de 1, pula os registros
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
            
            //Se ultrapassar o limite, encerra o la√ßo
            If nAtual > nTamanho
                Exit
            EndIf

            //Posiciona o registro e adiciona no retorno
            DbSelectArea(cAliasWS)
            (cAliasWS)->(DbGoTo(QRY_TAB->TABREC))
            
            oRegistro := JsonObject():New()
            oRegistro['emissao'] := (cAliasWS)->F2_EMISSAO 
            oRegistro['filial'] := (cAliasWS)->F2_FILIAL 
            oRegistro['chvnfe'] := (cAliasWS)->F2_CHVNFE 
            oRegistro['doc'] := (cAliasWS)->F2_DOC 
            oRegistro['serie'] := (cAliasWS)->F2_SERIE 
            oRegistro['cliente'] := (cAliasWS)->F2_CLIENTE 
            oRegistro['loja'] := (cAliasWS)->F2_LOJA 
            oRegistro['tipocli'] := (cAliasWS)->F2_TIPOCLI 
            oRegistro['vend1'] := (cAliasWS)->F2_VEND1 
            oRegistro['fimp'] := (cAliasWS)->F2_FIMP 
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet


WSMETHOD GET TUDO WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SF2
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
    Local cAliasWS   := 'SF2'

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

    //Se n„o encontrar registros
    If QRY_TAB->(EoF())
        //SetRestFault(500, 'Falha ao consultar registros') //caso queira usar esse comando, vocÍ n„o poder· usar outros retornos, como os abaixo
        Self:setStatus(404) 
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) n„o encontrado(s)'
        jResponse['solution'] := 'A consulta de registros n„o retornou nenhuma informaÁ„o'
    Else
        jResponse['objects'] := {}

        //Conta o total de registros
        Count To nTotal
        QRY_TAB->(DbGoTop())

        //O tamanho do retorno, ser· o limit, se ele estiver definido
        If ! Empty(::limit)
            nTamanho := ::limit
        EndIf

        //Pegando total de p·ginas
        nPags := NoRound(nTotal / nTamanho, 0)
        nPags += Iif(nTotal % nTamanho != 0, 1, 0)
        
        //Se vier p·gina
        If ! Empty(::page)
            nPagina := ::page
        EndIf

        //Se a p·gina vier zerada ou negativa ou for maior que o m·ximo, ser· 1 
        If nPagina <= 0 .Or. nPagina > nPags
            nPagina := 1
        EndIf

        //Se a p·gina for diferente de 1, pula os registros
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
            
            //Se ultrapassar o limite, encerra o laÁo
            If nAtual > nTamanho
                Exit
            EndIf

            //Posiciona o registro e adiciona no retorno
            DbSelectArea(cAliasWS)
            (cAliasWS)->(DbGoTo(QRY_TAB->TABREC))
            
            oRegistro := JsonObject():New()
oRegistro['F2_DOC']      := (cAliasWS)->F2_DOC
oRegistro['F2_SERIE']    := (cAliasWS)->F2_SERIE
oRegistro['F2_CLIENTE']  := (cAliasWS)->F2_CLIENTE
oRegistro['F2_LOJA']     := (cAliasWS)->F2_LOJA
oRegistro['F2_COND']     := (cAliasWS)->F2_COND
oRegistro['F2_DUPL']     := (cAliasWS)->F2_DUPL
oRegistro['F2_EMISSAO']  := (cAliasWS)->F2_EMISSAO
oRegistro['F2_EST']      := (cAliasWS)->F2_EST
oRegistro['F2_FRETE']    := (cAliasWS)->F2_FRETE
oRegistro['F2_SEGURO']   := (cAliasWS)->F2_SEGURO
oRegistro['F2_ICMFRET']  := (cAliasWS)->F2_ICMFRET
oRegistro['F2_TIPOCLI']  := (cAliasWS)->F2_TIPOCLI
oRegistro['F2_VALBRUT']  := (cAliasWS)->F2_VALBRUT
oRegistro['F2_VALICM']   := (cAliasWS)->F2_VALICM
oRegistro['F2_BASEICM']  := (cAliasWS)->F2_BASEICM
oRegistro['F2_NFORI']    := (cAliasWS)->F2_NFORI
oRegistro['F2_DESCONT']  := (cAliasWS)->F2_DESCONT
oRegistro['F2_SERIORI']  := (cAliasWS)->F2_SERIORI
oRegistro['F2_TIPO']     := (cAliasWS)->F2_TIPO
oRegistro['F2_ESPECI1']  := (cAliasWS)->F2_ESPECI1
oRegistro['F2_ESPECI3']  := (cAliasWS)->F2_ESPECI3
oRegistro['F2_ESPECI4']  := (cAliasWS)->F2_ESPECI4
oRegistro['F2_VOLUME1']  := (cAliasWS)->F2_VOLUME1
oRegistro['F2_VOLUME2']  := (cAliasWS)->F2_VOLUME2
oRegistro['F2_VOLUME3']  := (cAliasWS)->F2_VOLUME3
oRegistro['F2_VOLUME4']  := (cAliasWS)->F2_VOLUME4
oRegistro['F2_TRANSP']   := (cAliasWS)->F2_TRANSP
oRegistro['F2_REDESP']   := (cAliasWS)->F2_REDESP
oRegistro['F2_VEND3']    := (cAliasWS)->F2_VEND3
oRegistro['F2_VEND5']    := (cAliasWS)->F2_VEND5
oRegistro['F2_OK']       := (cAliasWS)->F2_OK
oRegistro['F2_FIMP']     := (cAliasWS)->F2_FIMP
oRegistro['F2_DTLANC']   := (cAliasWS)->F2_DTLANC
oRegistro['F2_DTREAJ']   := (cAliasWS)->F2_DTREAJ
oRegistro['F2_REAJUST']  := (cAliasWS)->F2_REAJUST
oRegistro['F2_DTBASE0']  := (cAliasWS)->F2_DTBASE0
oRegistro['F2_DTBASE1']  := (cAliasWS)->F2_DTBASE1
oRegistro['F2_FILIAL']   := (cAliasWS)->F2_FILIAL
oRegistro['F2_VALFAT']   := (cAliasWS)->F2_VALFAT
oRegistro['F2_BASIMP6']  := (cAliasWS)->F2_BASIMP6
oRegistro['F2_HORA']     := (cAliasWS)->F2_HORA
oRegistro['F2_NFCUPOM']  := (cAliasWS)->F2_NFCUPOM
oRegistro['F2_VALINSS']  := (cAliasWS)->F2_VALINSS
oRegistro['F2_VALCOFI']  := (cAliasWS)->F2_VALCOFI
oRegistro['F2_VALPIS']   := (cAliasWS)->F2_VALPIS
oRegistro['F2_BASEINS']  := (cAliasWS)->F2_BASEINS
oRegistro['F2_SEQCAR']   := (cAliasWS)->F2_SEQCAR
oRegistro['F2_LOJAREM']  := (cAliasWS)->F2_LOJAREM
oRegistro['F2_VALPS3']   := (cAliasWS)->F2_VALPS3
oRegistro['F2_CODA1U']   := (cAliasWS)->F2_CODA1U
oRegistro['F2_TIPORET']  := (cAliasWS)->F2_TIPORET
oRegistro['F2_HORNFE']   := (cAliasWS)->F2_HORNFE
oRegistro['F2_STATUS']   := (cAliasWS)->F2_STATUS
oRegistro['F2_CHVNFE']   := (cAliasWS)->F2_CHVNFE
oRegistro['F2_DTDIGIT']  := (cAliasWS)->F2_DTDIGIT
            oRegistro['F2_XVEND1']   := (cAliasWS)->F2_XVEND1
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
