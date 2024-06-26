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
 
    //M�todos
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
        //SetRestFault(500, 'Falha ao consultar o registro') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'ID001'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else
        DbSelectArea(cAliasWS)
        (cAliasWS)->(DbSetOrder(1))

        //Se n�o encontrar o registro
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            //SetRestFault(500, 'Falha ao consultar ID') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
            Self:setStatus(500) 
            jResponse['errorId']  := 'ID002'
            jResponse['error']    := 'ID n�o encontrado'
            jResponse['solution'] := 'C�digo ID n�o encontrado na tabela ' + cAliasWS
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

    //Se n�o encontrar registros
    If QRY_TAB->(EoF())
        //SetRestFault(500, 'Falha ao consultar registros') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) n�o encontrado(s)'
        jResponse['solution'] := 'A consulta de registros n�o retornou nenhuma informa��o'
    Else
        jResponse['objects'] := {}

        //Conta o total de registros
        Count To nTotal
        QRY_TAB->(DbGoTop())

        //O tamanho do retorno, ser� o limit, se ele estiver definido
        If ! Empty(::limit)
            nTamanho := ::limit
        EndIf

        //Pegando total de p�ginas
        nPags := NoRound(nTotal / nTamanho, 0)
        nPags += Iif(nTotal % nTamanho != 0, 1, 0)
        
        //Se vier p�gina
        If ! Empty(::page)
            nPagina := ::page
        EndIf

        //Se a p�gina vier zerada ou negativa ou for maior que o m�ximo, ser� 1 
        If nPagina <= 0 .Or. nPagina > nPags
            nPagina := 1
        EndIf

        //Se a p�gina for diferente de 1, pula os registros
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
            
            //Se ultrapassar o limite, encerra o la�o
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

    //Se n�o encontrar registros
    If QRY_TAB->(EoF())
        //SetRestFault(500, 'Falha ao consultar registros') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
        Self:setStatus(404) 
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) n�o encontrado(s)'
        jResponse['solution'] := 'A consulta de registros n�o retornou nenhuma informa��o'
    Else
        jResponse['objects'] := {}

        //Conta o total de registros
        Count To nTotal
        QRY_TAB->(DbGoTop())

        //O tamanho do retorno, ser� o limit, se ele estiver definido
        If ! Empty(::limit)
            nTamanho := ::limit
        EndIf

        //Pegando total de p�ginas
        nPags := NoRound(nTotal / nTamanho, 0)
        nPags += Iif(nTotal % nTamanho != 0, 1, 0)
        
        //Se vier p�gina
        If ! Empty(::page)
            nPagina := ::page
        EndIf

        //Se a p�gina vier zerada ou negativa ou for maior que o m�ximo, ser� 1 
        If nPagina <= 0 .Or. nPagina > nPags
            nPagina := 1
        EndIf

        //Se a p�gina for diferente de 1, pula os registros
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
            
            //Se ultrapassar o limite, encerra o la�o
            If nAtual > nTamanho
                Exit
            EndIf

            //Posiciona o registro e adiciona no retorno
            DbSelectArea(cAliasWS)
            (cAliasWS)->(DbGoTo(QRY_TAB->TABREC))
            
            oRegistro := JsonObject():New()
oRegistro['D2_FILIAL']   := (cAliasWS)->D2_FILIAL
oRegistro['D2_ITEM']     := (cAliasWS)->D2_ITEM
oRegistro['D2_COD']      := (cAliasWS)->D2_COD
oRegistro['D2_UM']       := (cAliasWS)->D2_UM
oRegistro['D2_QUANT']    := (cAliasWS)->D2_QUANT
oRegistro['D2_PRCVEN']   := (cAliasWS)->D2_PRCVEN
oRegistro['D2_TOTAL']    := (cAliasWS)->D2_TOTAL
oRegistro['D2_VALIPI']   := (cAliasWS)->D2_VALIPI
oRegistro['D2_VALICM']   := (cAliasWS)->D2_VALICM
oRegistro['D2_TES']      := (cAliasWS)->D2_TES
oRegistro['D2_CF']       := (cAliasWS)->D2_CF
oRegistro['D2_IPI']      := (cAliasWS)->D2_IPI
oRegistro['D2_PICM']     := (cAliasWS)->D2_PICM
oRegistro['D2_OP']       := (cAliasWS)->D2_OP
oRegistro['D2_PEDIDO']   := (cAliasWS)->D2_PEDIDO
oRegistro['D2_ITEMPV']   := (cAliasWS)->D2_ITEMPV
oRegistro['D2_CLIENTE']  := (cAliasWS)->D2_CLIENTE
oRegistro['D2_LOJA']     := (cAliasWS)->D2_LOJA
oRegistro['D2_DOC']      := (cAliasWS)->D2_DOC
oRegistro['D2_SERIE']    := (cAliasWS)->D2_SERIE
oRegistro['D2_GRUPO']    := (cAliasWS)->D2_GRUPO
oRegistro['D2_TP']       := (cAliasWS)->D2_TP
oRegistro['D2_EMISSAO']  := (cAliasWS)->D2_EMISSAO
oRegistro['D2_CUSTO1']   := (cAliasWS)->D2_CUSTO1
oRegistro['D2_PRUNIT']   := (cAliasWS)->D2_PRUNIT
oRegistro['D2_EST']      := (cAliasWS)->D2_EST
oRegistro['D2_TIPO']     := (cAliasWS)->D2_TIPO
oRegistro['D2_NFORI']    := (cAliasWS)->D2_NFORI
oRegistro['D2_SERIORI']  := (cAliasWS)->D2_SERIORI
oRegistro['D2_QTDEDEV']  := (cAliasWS)->D2_QTDEDEV
oRegistro['D2_VALDEV']   := (cAliasWS)->D2_VALDEV
oRegistro['D2_ORIGLAN']  := (cAliasWS)->D2_ORIGLAN
oRegistro['D2_BRICMS']   := (cAliasWS)->D2_BRICMS
oRegistro['D2_BASEICM']  := (cAliasWS)->D2_BASEICM
oRegistro['D2_ICMSRET']  := (cAliasWS)->D2_ICMSRET
oRegistro['D2_CLASFIS']  := (cAliasWS)->D2_CLASFIS
oRegistro['D2_BASIMP5']  := (cAliasWS)->D2_BASIMP5
oRegistro['D2_BASIMP6']  := (cAliasWS)->D2_BASIMP6
oRegistro['D2_VALIMP5']  := (cAliasWS)->D2_VALIMP5
oRegistro['D2_VALIMP6']  := (cAliasWS)->D2_VALIMP6
oRegistro['D2_ALQIMP5']  := (cAliasWS)->D2_ALQIMP5
oRegistro['D2_ALQIMP6']  := (cAliasWS)->D2_ALQIMP6
oRegistro['D2_BASEIPI']  := (cAliasWS)->D2_BASEIPI
oRegistro['D2_SEGURO']   := (cAliasWS)->D2_SEGURO
oRegistro['D2_VALFRE']   := (cAliasWS)->D2_VALFRE
oRegistro['D2_DESPESA']  := (cAliasWS)->D2_DESPESA
oRegistro['D2_VALBRUT']  := (cAliasWS)->D2_VALBRUT
oRegistro['D2_BSFCPST']  := (cAliasWS)->D2_BSFCPST
oRegistro['D2_VFECPST']  := (cAliasWS)->D2_VFECPST

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
