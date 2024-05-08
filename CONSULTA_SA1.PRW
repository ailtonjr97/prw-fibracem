//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} WSRESTFUL CONSULTA_SA1
@author everson
@since 05/07/2023
@version 1.0
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/


WSRESTFUL CONSULTA_SA1 DESCRIPTION ''
    //Atributos
    WSDATA id         AS STRING
    WSDATA loja       AS STRING
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
 
    //M√©todos
    WSMETHOD GET ID      DESCRIPTION 'Retorna o registro pesquisado'        WSSYNTAX '/CONSULTA_SA1/get_id?{id}'                                              PATH 'get_id'  PRODUCES APPLICATION_JSON
    WSMETHOD GET ALL     DESCRIPTION 'Retorna todos os registros'           WSSYNTAX '/CONSULTA_SA1/get_all?{updated_at, limit, page}'                        PATH 'get_all' PRODUCES APPLICATION_JSON
    WSMETHOD GET TUDO    DESCRIPTION 'Retorna todos os registros com stamp' WSSYNTAX '/CONSULTA_SA1/tudo?{updated_at, limit, page, pedido, data_ent, filial}' PATH 'tudo'    PRODUCES APPLICATION_JSON
    WSMETHOD GET ID_LOJA DESCRIPTION 'Retorna um unico registro com stamp'  WSSYNTAX '/CONSULTA_SA1/unico?{updated_at, limit, page, id, loja}'                PATH 'unico'   PRODUCES APPLICATION_JSON
END WSRESTFUL


/*/{Protheus.doc} WSMETHOD GET ID
Busca registro via ID
@author everson
@since 05/07/2023
@version 1.0
@param id, Caractere, String que ser√° pesquisada atrav√©s do MsSeek
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

WSMETHOD GET ID WSRECEIVE id WSSERVICE CONSULTA_SA1
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SA1'

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
            jResponse['cod'] := (cAliasWS)->A1_COD 
            jResponse['nome'] := (cAliasWS)->A1_NOME 
            jResponse['cod_mun'] := (cAliasWS)->A1_COD_MUN 
            jResponse['mun'] := (cAliasWS)->A1_MUN 
            jResponse['nreduz'] := (cAliasWS)->A1_NREDUZ 
            jResponse['grpven'] := (cAliasWS)->A1_GRPVEN 
            jResponse['loja'] := (cAliasWS)->A1_LOJA 
            jResponse['end'] := (cAliasWS)->A1_END 
            jResponse['codpais'] := (cAliasWS)->A1_CODPAIS 
            jResponse['est'] := (cAliasWS)->A1_EST 
            jResponse['cep'] := (cAliasWS)->A1_CEP 
            jResponse['tipo'] := (cAliasWS)->A1_TIPO 
            jResponse['cgc'] := (cAliasWS)->A1_CGC 
            jResponse['filial'] := (cAliasWS)->A1_FILIAL    
            jResponse['xcartei'] := (cAliasWS)->A1_XCARTEI            
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

/*/{Protheus.doc} WSMETHOD GET ALL
Busca todos os registros atrav√©s de pagina√ß√£o
@author everson
@since 05/07/2023
@version 1.0
@param updated_at, Caractere, Data de altera√ß√£o no formato string 'YYYY-MM-DD' (somente se tiver o campo USERLGA / USERGA na tabela)
@param limit, Num√©rico, Limite de registros que ir√° vir (por exemplo trazer apenas 100 registros)
@param page, Num√©rico, N√∫mero da p√°gina que ir√° buscar (se existir 1000 registros dividido por 100 ter√° 10 p√°ginas de pesquisa)
@obs Codigo gerado automaticamente pelo Autumn Code Maker

    Poderia ser usado o FWAdapterBaseV2(), mas em algumas vers√µes antigas n√£o existe essa funcionalidade
    ent√£o a pagina√ß√£o foi feita manualmente

@see http://autumncodemaker.com
/*/

WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SA1
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local oRegistro
    Local cAliasWS   := 'SA1'

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE " + CRLF
    cQueryTab += "     TAB.D_E_L_E_T_ = '' " + CRLF
    If ! Empty(::updated_at)
        cQueryTab += "     AND ((CASE WHEN SUBSTRING(A1_USERLGA, 03, 1) != ' ' THEN " + CRLF
        cQueryTab += "        CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(A1_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(A1_USERLGA,16,1)) - 50)),'19960101'),112) " + CRLF
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
            oRegistro['cod'] := (cAliasWS)->A1_COD 
            oRegistro['nome'] := (cAliasWS)->A1_NOME 
            oRegistro['cod_mun'] := (cAliasWS)->A1_COD_MUN 
            oRegistro['mun'] := (cAliasWS)->A1_MUN 
            oRegistro['nreduz'] := (cAliasWS)->A1_NREDUZ 
            oRegistro['grpven'] := (cAliasWS)->A1_GRPVEN 
            oRegistro['loja'] := (cAliasWS)->A1_LOJA 
            oRegistro['end'] := (cAliasWS)->A1_END 
            oRegistro['codpais'] := (cAliasWS)->A1_CODPAIS 
            oRegistro['est'] := (cAliasWS)->A1_EST 
            oRegistro['cep'] := (cAliasWS)->A1_CEP 
            oRegistro['tipo'] := (cAliasWS)->A1_TIPO 
            oRegistro['cgc'] := (cAliasWS)->A1_CGC 
            oRegistro['filial'] := (cAliasWS)->A1_FILIAL 
            oRegistro['xcartei'] := (cAliasWS)->A1_XCARTEI
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

WSMETHOD GET TUDO WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SA1
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
    Local cAliasWS   := 'SA1'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT TAB.A1_VEND, TAB.A1_COD, TAB.A1_NOME, TAB.A1_COD_MUN, TAB.A1_MUN, TAB.A1_NREDUZ, TAB.A1_GRPVEN, TAB.A1_LOJA," + CRLF
    cQueryTab += " TAB.A1_END, TAB.A1_CODPAIS, TAB.A1_EST, TAB.A1_CEP, TAB.A1_TIPO, TAB.A1_CGC, TAB.A1_FILIAL, TAB.A1_XCARTEI," + CRLF
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

            //cQueryTab := " SELECT TAB.A1_VEND, TAB.A1_COD, TAB.A1_NOME, TAB.A1_COD_MUN, TAB.A1_MUN, TAB.A1_NREDUZ, TAB.A1_GRPVEN, TAB.A1_LOJA," + CRLF
            //cQueryTab += " TAB.A1_END, TAB.A1_CODPAIS, TAB.A1_EST, TAB.A1_CEP, TAB.A1_TIPO, TAB.A1_CGC, TAB.A1_FILIAL, TAB.A1_XCARTEI," + CRLF
            
            oRegistro := JsonObject():New()
            oRegistro['A1_VEND']      := (cAliasWS)->A1_VEND
            oRegistro['A1_COD']       := (cAliasWS)->A1_COD
            oRegistro['A1_NOME']      := (cAliasWS)->A1_NOME
            oRegistro['A1_COD_MUN']   := (cAliasWS)->A1_COD_MUN
            oRegistro['A1_MUN']       := (cAliasWS)->A1_MUN
            oRegistro['A1_NREDUZ']    := (cAliasWS)->A1_NREDUZ
            oRegistro['A1_GRPVEN']    := (cAliasWS)->A1_GRPVEN
            oRegistro['A1_LOJA']      := (cAliasWS)->A1_LOJA
            oRegistro['A1_END']       := (cAliasWS)->A1_END
            oRegistro['A1_CODPAIS']   := (cAliasWS)->A1_CODPAIS
            oRegistro['A1_EST']       := (cAliasWS)->A1_EST
            oRegistro['A1_CEP']       := (cAliasWS)->A1_CEP
            oRegistro['A1_TIPO']      := (cAliasWS)->A1_TIPO
            oRegistro['A1_CGC']       := (cAliasWS)->A1_CGC
            oRegistro['A1_FILIAL']    := (cAliasWS)->A1_FILIAL
            oRegistro['A1_XCARTEI']   := (cAliasWS)->A1_XCARTEI
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

WSMETHOD GET ID_LOJA WSRECEIVE updated_at, limit, page, id, loja WSSERVICE CONSULTA_SA1
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
    Local cAliasWS   := 'SA1'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf


    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC, TAB.R_E_C_D_E_L_ AS RECDEL, TAB.S_T_A_M_P_ AS STAMP" + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE TAB.A1_COD = '"+::id+"' AND TAB.A1_LOJA = '"+::loja+"' " + CRLF
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

            //cQueryTab := " SELECT TAB.A1_VEND, TAB.A1_COD, TAB.A1_NOME, TAB.A1_COD_MUN, TAB.A1_MUN, TAB.A1_NREDUZ, TAB.A1_GRPVEN, TAB.A1_LOJA," + CRLF
            //cQueryTab += " TAB.A1_END, TAB.A1_CODPAIS, TAB.A1_EST, TAB.A1_CEP, TAB.A1_TIPO, TAB.A1_CGC, TAB.A1_FILIAL, TAB.A1_XCARTEI," + CRLF
            
            oRegistro := JsonObject():New()
            oRegistro['A1_VEND']      := (cAliasWS)->A1_VEND
            oRegistro['A1_COD']       := (cAliasWS)->A1_COD
            oRegistro['A1_NOME']      := (cAliasWS)->A1_NOME
            oRegistro['A1_COD_MUN']   := (cAliasWS)->A1_COD_MUN
            oRegistro['A1_MUN']       := (cAliasWS)->A1_MUN
            oRegistro['A1_NREDUZ']    := (cAliasWS)->A1_NREDUZ
            oRegistro['A1_GRPVEN']    := (cAliasWS)->A1_GRPVEN
            oRegistro['A1_LOJA']      := (cAliasWS)->A1_LOJA
            oRegistro['A1_END']       := (cAliasWS)->A1_END
            oRegistro['A1_CODPAIS']   := (cAliasWS)->A1_CODPAIS
            oRegistro['A1_EST']       := (cAliasWS)->A1_EST
            oRegistro['A1_CEP']       := (cAliasWS)->A1_CEP
            oRegistro['A1_TIPO']      := (cAliasWS)->A1_TIPO
            oRegistro['A1_CGC']       := (cAliasWS)->A1_CGC
            oRegistro['A1_FILIAL']    := (cAliasWS)->A1_FILIAL
            oRegistro['A1_XCARTEI']   := (cAliasWS)->A1_XCARTEI
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
