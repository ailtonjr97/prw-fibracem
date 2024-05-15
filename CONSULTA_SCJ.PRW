//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"



WSRESTFUL CONSULTA_SCJ DESCRIPTION 'Retorna proposta comercial'
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
    WSDATA filial     AS STRING
    WSDATA numero     AS STRING
    WSDATA dt_emissao AS STRING
    WSDATA cliente    AS STRING
    WSDATA loja       AS STRING

    //Métodos
    WSMETHOD GET    ID            DESCRIPTION 'Retorna o registro pesquisado'       WSSYNTAX '/CONSULTA_SCJ/get_id?{id, empresa}'                                                      PATH 'get_id'     PRODUCES APPLICATION_JSON
    WSMETHOD GET    ALL           DESCRIPTION 'Retorna todos os registros'          WSSYNTAX '/CONSULTA_SCJ/get_all?{updated_at, limit, page}'                                         PATH 'get_all'    PRODUCES APPLICATION_JSON
    WSMETHOD GET    INTEGRADOR    DESCRIPTION 'Retorna registros para o integrador' WSSYNTAX '/CONSULTA_SCJ/integrador?{updated_at, limit, page, filial, numero, dt_emissao, cliente}' PATH 'integrador' PRODUCES APPLICATION_JSON
    WSMETHOD PUT    UPDATE_CST    DESCRIPTION 'Faz update proposta na coluna cst'   WSSYNTAX '/CONSULTA_SCJ/update_cst?{num, fts,valor, transp}'                                       PATH 'update_cst' PRODUCES APPLICATION_JSON
    WSMETHOD GET    UNICO         DESCRIPTION 'Retorn um unico orcamento'           WSSYNTAX '/CONSULTA_SCJ/unico?{filial, numero, cliente, loja}'                                     PATH 'unico'      PRODUCES APPLICATION_JSON
    WSMETHOD PUT    VIRA_FOB      DESCRIPTION 'Zera o frete e vira FOB'             WSSYNTAX '/CONSULTA_SCJ/vira_fob?{numero, filial}'                                                 PATH 'vira_fob'   PRODUCES APPLICATION_JSON
    WSMETHOD PUT    VIRA_CIF      DESCRIPTION 'Zera o frete e vira CIF'             WSSYNTAX '/CONSULTA_SCJ/vira_cif?{numero, filial}'                                                 PATH 'vira_cif'   PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD GET ID WSRECEIVE id, empresa WSSERVICE CONSULTA_SCJ
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SCJ'
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
            jResponse['filial'] := (cAliasWS)->CJ_FILIAL 
            jResponse['num'] := (cAliasWS)->CJ_NUM 
            jResponse['emissao'] := (cAliasWS)->CJ_EMISSAO 
            jResponse['cliente'] := (cAliasWS)->CJ_CLIENTE 
            jResponse['loja'] := (cAliasWS)->CJ_LOJA 
            jResponse['client'] := (cAliasWS)->CJ_CLIENT 
            jResponse['lojaent'] := (cAliasWS)->CJ_LOJAENT 
            jResponse['condpag'] := (cAliasWS)->CJ_CONDPAG 
            jResponse['tabela'] := (cAliasWS)->CJ_TABELA 
            jResponse['status'] := (cAliasWS)->CJ_STATUS 
            jResponse['frete'] := (cAliasWS)->CJ_FRETE 
            jResponse['valida'] := (cAliasWS)->CJ_VALIDA 
            jResponse['xtransp'] := (cAliasWS)->CJ_XTRANSP 
            jResponse['tpfrete'] := (cAliasWS)->CJ_TPFRETE 
            jResponse['tipocli'] := (cAliasWS)->CJ_TIPOCLI 
            jResponse['xentreg'] := (cAliasWS)->CJ_XENTREG 
            jResponse['xvend1'] := (cAliasWS)->CJ_XVEND1 
            jResponse['xobs'] := (cAliasWS)->CJ_XOBS 
            jResponse['xestado'] := (cAliasWS)->CJ_XESTADO 
            jResponse['xpvkorp'] := (cAliasWS)->CJ_XPVKORP
            jResponse['xfreimp'] := (cAliasWS)->CJ_XFREIMP  
            jResponse['CJCSTFTS'] := (cAliasWS)->CJ_CST_FTS        
            jResponse['solution'] := 'FWxFilial: ' + FWxFilial(cAliasWS)

        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet



WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SCJ
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local oRegistro
    Local cAliasWS   := 'SCJ'

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE " + CRLF
    cQueryTab += "     TAB.D_E_L_E_T_ = '' " + CRLF
    
    //Abaixo esta sendo feito o filtro com o campo de log de alteração (LGA), porém desde Maio de 2023, pode apresentar divergências
    // então você pode substituir o campo 'CJ_USERLGA' por S_T_A_M_P_, I_N_S_D_T_ ou outro campo de data da tabela
    If ! Empty(::updated_at)
        cQueryTab += "     AND ((CASE WHEN SUBSTRING(CJ_USERLGA, 03, 1) != ' ' THEN " + CRLF
        cQueryTab += "        CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(CJ_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(CJ_USERLGA,16,1)) - 50)),'19960101'),112) " + CRLF
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
            oRegistro['filial'] := (cAliasWS)->CJ_FILIAL 
            oRegistro['num'] := (cAliasWS)->CJ_NUM 
            oRegistro['emissao'] := (cAliasWS)->CJ_EMISSAO 
            oRegistro['cliente'] := (cAliasWS)->CJ_CLIENTE 
            oRegistro['loja'] := (cAliasWS)->CJ_LOJA 
            oRegistro['client'] := (cAliasWS)->CJ_CLIENT 
            oRegistro['lojaent'] := (cAliasWS)->CJ_LOJAENT 
            oRegistro['condpag'] := (cAliasWS)->CJ_CONDPAG 
            oRegistro['tabela'] := (cAliasWS)->CJ_TABELA 
            oRegistro['status'] := (cAliasWS)->CJ_STATUS 
            oRegistro['frete'] := (cAliasWS)->CJ_FRETE 
            oRegistro['valida'] := (cAliasWS)->CJ_VALIDA 
            oRegistro['xtransp'] := (cAliasWS)->CJ_XTRANSP 
            oRegistro['tpfrete'] := (cAliasWS)->CJ_TPFRETE 
            oRegistro['tipocli'] := (cAliasWS)->CJ_TIPOCLI 
            oRegistro['xentreg'] := (cAliasWS)->CJ_XENTREG 
            oRegistro['xvend1'] := (cAliasWS)->CJ_XVEND1 
            oRegistro['xobs'] := (cAliasWS)->CJ_XOBS 
            oRegistro['xestado'] := (cAliasWS)->CJ_XESTADO 
            oRegistro['xpvkorp'] := (cAliasWS)->CJ_XPVKORP 
            oRegistro['xfreimp'] := (cAliasWS)->CJ_XFREIMP 
            oRegistro['cst_fts'] := (cAliasWS)->CJ_CST_FTS 
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet




WSMETHOD PUT UPDATE_CST WSRECEIVE num, fts, valor, transp WSSERVICE CONSULTA_SCJ
    Local lRet       := .T.
    Local nnum       := ''
    Local nfts       := '' 
    Local nvalor     := ''
    Local ntransp    := ''     
    Local cQryUpd    := ''   
    //Local cQueryTab  := ''


    Begin Transaction
    If ! Empty(::num)
        nnum := ::num
    EndIf
    If ! Empty(::fts)
        nfts := ::fts
    EndIf    
    If ! Empty(::valor)
        nvalor := ::valor
    EndIf  
    If ! Empty(::transp)
        ntransp := ::transp
    EndIf      
      //Monta o Update
      cQryUpd := " UPDATE " + RetSqlName("SCJ") + " "
      cQryUpd += "     SET CJ_CST_FTS = '"+nfts+"' "
      cQryUpd += "    , CJ_XTRANSP = '"+ntransp+"' "      
      cQryUpd += "    , CJ_XFRESIM = '"+nvalor+"' " 
      cQryUpd += "    , CJ_XFREIMP = '"+nvalor+"' "       
      cQryUpd += "    , CJ_TPFRETE = 'C' "          
      cQryUpd += "    , CJ_FRETE   = '"+nvalor+"' "             
      cQryUpd += " WHERE "
      cQryUpd += "      CJ_NUM = '"+nnum+"' "

       Self:SetResponse("OK! nfts: "+nfts+" nnum:  "+nnum+"nvalor:  "+nvalor+" ntransp:  "+ntransp+" ")
       Self:SetResponse("OK! QUERY: "+cQryUpd+" ")

    //Tenta executar o update
       nErro := TcSqlExec(cQryUpd)

     //Se houve erro, mostra a mensagem e cancela a transação
      If nErro != 0
        Self:SetResponse("OK! nfts: "+nfts+" nnum:  "+nnum+"nvalor:  "+nvalor+" ntransp:  "+ntransp+" ")
        Self:SetResponse("ERRO! "+nErro)
        Self:SetResponse("OK! QUERY: "+cQryUpd+" ")
        MsgStop("Erro na execução da query: "+TcSqlError(), "Atenção")
        DisarmTransaction()
      EndIf
    End Transaction

Return lRet

WSMETHOD GET INTEGRADOR WSRECEIVE updated_at, limit, page, filial, numero, dt_emissao, cliente WSSERVICE CONSULTA_SCJ
    Local lRet            := .T.
    Local jResponse       := JsonObject():New()
    Local cQueryTab       := ''
    Local nTamanho        := 10000
    Local nTotal          := 0
    Local nPags           := 0
    Local nPagina         := 0
    Local nAtual          := 0
    Local data            := ''
    Local nFilial         := ''
    Local nNumero         := ''
    Local nDataEmissao    := ''
    Local nCliente        := ''
    Local oRegistro
    Local cAliasWS        := 'SCJ'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf

    If ! Empty(::filial)
        nFilial := ::filial
    EndIf

    If ! Empty(::numero)
        nNumero := ::numero
    EndIf

    If ! Empty(::dt_emissao)
        nDataEmissao := ::dt_emissao
    EndIf

    If ! Empty(::cliente)
        nCliente := ::cliente
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT TAB.CJ_FILIAL, TAB.CJ_NUM, TAB.CJ_EMISSAO, TAB.CJ_CLIENTE, CJ_LOJA," + CRLF
    cQueryTab += " TAB.R_E_C_N_O_ AS TABREC, TAB.R_E_C_D_E_L_ AS RECDEL, TAB.S_T_A_M_P_ AS STAMP" + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE TAB.CJ_FILIAL like '%"+nFilial+"%' AND TAB.CJ_NUM like '%"+nNumero+"%' AND TAB.CJ_EMISSAO like '%"+nDataEmissao+"%' AND TAB.CJ_CLIENTE like '%"+nCliente+"%' " + CRLF
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
            oRegistro['CJ_FILIAL']    := (cAliasWS)->CJ_FILIAL
            oRegistro['CJ_NUM']       := (cAliasWS)->CJ_NUM
            oRegistro['CJ_EMISSAO']   := (cAliasWS)->CJ_EMISSAO
            oRegistro['CJ_CLIENTE']   := (cAliasWS)->CJ_CLIENTE
            oRegistro['CJ_LOJA']      := (cAliasWS)->CJ_LOJA
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

WSMETHOD GET UNICO WSRECEIVE filial, numero, cliente, loja WSSERVICE CONSULTA_SCJ
    Local lRet            := .T.
    Local jResponse       := JsonObject():New()
    Local cQueryTab       := ''
    Local nTamanho        := 10000
    Local nTotal          := 0
    Local nPags           := 0
    Local nPagina         := 0
    Local nAtual          := 0
    Local data            := ''
    Local oRegistro
    Local cAliasWS        := 'SCJ'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += " TAB.R_E_C_N_O_ AS TABREC, TAB.R_E_C_D_E_L_ AS RECDEL, TAB.S_T_A_M_P_ AS STAMP" + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE TAB.CJ_FILIAL = '"+::filial+"' AND TAB.CJ_NUM = '"+::numero+"' AND TAB.CJ_CLIENTE = '"+::cliente+"' AND TAB.CJ_LOJA = '"+::loja+"' " + CRLF
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
            oRegistro['CJ_FILIAL']    := (cAliasWS)->CJ_FILIAL
            oRegistro['CJ_NUM']     := (cAliasWS)->CJ_NUM
            oRegistro['CJ_EMISSAO'] := (cAliasWS)->CJ_EMISSAO
            oRegistro['CJ_CLIENTE']  := (cAliasWS)->CJ_CLIENTE
            oRegistro['CJ_PROSPE']  := (cAliasWS)->CJ_PROSPE
            oRegistro['CJ_LOJA']    := (cAliasWS)->CJ_LOJA
            oRegistro['CJ_CLIENT']  := (cAliasWS)->CJ_CLIENT
            oRegistro['CJ_LOJAENT'] := (cAliasWS)->CJ_LOJAENT
            oRegistro['CJ_CONDPAG'] := (cAliasWS)->CJ_CONDPAG
            oRegistro['CJ_XESTADO'] := (cAliasWS)->CJ_XESTADO
            oRegistro['CJ_XPVKORP'] := (cAliasWS)->CJ_XPVKORP
            oRegistro['CJ_TABELA']  := (cAliasWS)->CJ_TABELA
            oRegistro['CJ_TIPOCLI'] := (cAliasWS)->CJ_TIPOCLI
            oRegistro['CJ_TPFRETE'] := (cAliasWS)->CJ_TPFRETE
            oRegistro['CJ_XFREIMP'] := (cAliasWS)->CJ_XFREIMP
            oRegistro['CJ_PROSPE']  := (cAliasWS)->CJ_PROSPE
            oRegistro['CJ_LOJPRO']  := (cAliasWS)->CJ_LOJPRO
            oRegistro['CJ_CST_FTS'] := (cAliasWS)->CJ_CST_FTS
            oRegistro['CJ_XFREMA']  := (cAliasWS)->CJ_XFREMA
            oRegistro['CJ_XFRESIM'] := (cAliasWS)->CJ_XFRESIM
            oRegistro['CJ_XTRANSP'] := (cAliasWS)->CJ_XTRANSP
            oRegistro['CJ_TIPLIB']  := (cAliasWS)->CJ_TIPLIB
            oRegistro['CJ_DESC1']   := (cAliasWS)->CJ_DESC1
            oRegistro['CJ_COTCLI']  := (cAliasWS)->CJ_COTCLI
            oRegistro['CJ_FRETE']   := (cAliasWS)->CJ_FRETE
            oRegistro['CJ_SEGURO']  := (cAliasWS)->CJ_SEGURO
            oRegistro['CJ_DESPESA'] := (cAliasWS)->CJ_DESPESA
            oRegistro['CJ_FRETAUT'] := (cAliasWS)->CJ_FRETAUT
            oRegistro['CJ_VALIDA']  := (cAliasWS)->CJ_VALIDA
            oRegistro['CJ_MOEDA']   := (cAliasWS)->CJ_MOEDA
            oRegistro['CJ_TPCARGA'] := (cAliasWS)->CJ_TPCARGA
            oRegistro['CJ_DESCONT'] := (cAliasWS)->CJ_DESCONT
            oRegistro['CJ_XENTREG'] := (cAliasWS)->CJ_XENTREG
            oRegistro['CJ_LOGUSL']  := (cAliasWS)->CJ_LOGUSL
            oRegistro['CJ_XUSRINC'] := (cAliasWS)->CJ_XUSRINC
            oRegistro['CJ_XPERCEN'] := (cAliasWS)->CJ_XPERCEN
            oRegistro['CJ_PROPOST'] := (cAliasWS)->CJ_PROPOST
            oRegistro['CJ_XVALPER'] := (cAliasWS)->CJ_XVALPER
            oRegistro['CJ_XFORMA']  := (cAliasWS)->CJ_XFORMA
            oRegistro['CJ_XMOTREJ'] := (cAliasWS)->CJ_XMOTREJ
            oRegistro['CJ_NROPOR']  := (cAliasWS)->CJ_NROPOR
            oRegistro['CJ_XVEND1']  := (cAliasWS)->CJ_XVEND1
            oRegistro['CJ_XVEND2']  := (cAliasWS)->CJ_XVEND2
            oRegistro['CJ_XUSRLIB'] := (cAliasWS)->CJ_XUSRLIB
            oRegistro['CJ_REVISA']  := (cAliasWS)->CJ_REVISA
            oRegistro['CJ_XVEND3']  := (cAliasWS)->CJ_XVEND3
            oRegistro['CJ_TXMOEDA'] := (cAliasWS)->CJ_TXMOEDA
            oRegistro['CJ_XVEND4']  := (cAliasWS)->CJ_XVEND4
            oRegistro['CJ_INDPRES'] := (cAliasWS)->CJ_INDPRES
            oRegistro['CJ_XVEND5']  := (cAliasWS)->CJ_XVEND5
            oRegistro['CJ_CODA1U']  := (cAliasWS)->CJ_CODA1U
            oRegistro['CJ_XREDESP'] := (cAliasWS)->CJ_XREDESP
            oRegistro['CJ_XOBS']    := (cAliasWS)->CJ_XOBS
            oRegistro['S_T_A_M_P_']   := QRY_TAB->STAMP
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

WSMETHOD PUT VIRA_FOB WSRECEIVE numero, filial WSSERVICE CONSULTA_SCJ
    Local lRet          := .T.
    Local cNumero       := ''
    Local cFilial       := ''   

    Begin Transaction
    If ! Empty(::numero)
        cNumero := ::numero
    EndIf
    
    If ! Empty(::filial)
        cFilial := ::filial
    EndIf
    
      //Monta o Update
      cQryUpd := " UPDATE " + RetSqlName("SCJ") + " "
      cQryUpd += "     SET CJ_CST_FTS = '0' "    
      cQryUpd += "    , CJ_XFRESIM = 0 " 
      cQryUpd += "    , CJ_XFREIMP = 0 "
      cQryUpd += "    , CJ_XFREMA = 0 "        
      cQryUpd += "    , CJ_TPFRETE = 'F' "          
      cQryUpd += "    , CJ_FRETE   = 0 "             
      cQryUpd += " WHERE "
      cQryUpd += "      CJ_FILIAL = '"+cFilial+"' AND CJ_NUM = '"+cNumero+"' "

       Self:SetResponse("OK!")

    //Tenta executar o update
       nErro := TcSqlExec(cQryUpd)

     //Se houve erro, mostra a mensagem e cancela a transação
      If nErro != 0
        Self:SetResponse("ERRO! "+nErro)
        MsgStop("Erro na execução da query: "+TcSqlError(), "Atenção")
        DisarmTransaction()
      EndIf
    End Transaction

Return lRet

WSMETHOD PUT VIRA_CIF WSRECEIVE numero, filial WSSERVICE CONSULTA_SCJ
    Local lRet          := .T.
    Local cNumero       := ''
    Local cFilial       := ''   

    Begin Transaction
    If ! Empty(::numero)
        cNumero := ::numero
    EndIf
    
    If ! Empty(::filial)
        cFilial := ::filial
    EndIf
    
      //Monta o Update
      cQryUpd := " UPDATE " + RetSqlName("SCJ") + " "
      cQryUpd += "     SET CJ_CST_FTS = '0' "    
      cQryUpd += "    , CJ_XFRESIM = 0 " 
      cQryUpd += "    , CJ_XFREIMP = 0 "
      cQryUpd += "    , CJ_XFREMA = 0 "        
      cQryUpd += "    , CJ_TPFRETE = 'C' "          
      cQryUpd += "    , CJ_FRETE   = 0 "             
      cQryUpd += " WHERE "
      cQryUpd += "      CJ_FILIAL = '"+cFilial+"' AND CJ_NUM = '"+cNumero+"' "

       Self:SetResponse("OK!")

    //Tenta executar o update
       nErro := TcSqlExec(cQryUpd)

     //Se houve erro, mostra a mensagem e cancela a transação
      If nErro != 0
        Self:SetResponse("ERRO! "+nErro)
        MsgStop("Erro na execução da query: "+TcSqlError(), "Atenção")
        DisarmTransaction()
      EndIf
    End Transaction

Return lRet
