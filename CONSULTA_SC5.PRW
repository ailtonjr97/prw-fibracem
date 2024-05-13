//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"


WSRESTFUL CONSULTA_SC5 DESCRIPTION ''
    //Atributos
    WSDATA id           AS STRING
    WSDATA updated_at   AS STRING
    WSDATA limit        AS INTEGER
    WSDATA page         AS INTEGER
    WSDATA filial       AS STRING
    WSDATA num          AS STRING
    WSDATA campo        AS STRING
    WSDATA booleano     AS STRING
    WSDATA hora         AS STRING
    WSDATA campo_hora   AS STRING
    WSDATA logado       AS STRING
    WSDATA campo_logado AS STRING
    WSDATA pedido       AS STRING
    WSDATA data_ent     as STRING
    WSDATA vendedor     as STRING
    WSDATA pcampo       as STRING
    WSDATA scampo       as STRING
    WSDATA pvalor       as STRING
    WSDATA svalor       as STRING
 
    //Métodos
    WSMETHOD GET ID           DESCRIPTION 'Retorna o registro pesquisado'        WSSYNTAX '/CONSULTA_SC5/get_id?{id}'                                                                                             PATH 'get_id'         PRODUCES APPLICATION_JSON
    WSMETHOD GET ALL          DESCRIPTION 'Retorna todos os registros'           WSSYNTAX '/CONSULTA_SC5/get_all?{updated_at, limit, page}'                                                                       PATH 'get_all'        PRODUCES APPLICATION_JSON
    WSMETHOD GET TRACK_ORDER  DESCRIPTION 'Retorna registros para o Track Order' WSSYNTAX '/CONSULTA_SC5/get_track?{updated_at, limit, page, pedido, data_ent, filial, vendedor, pcampo, scampo, pvalor, svalor}' PATH 'get_track'      PRODUCES APPLICATION_JSON
    WSMETHOD PUT UPDATE       DESCRIPTION 'Atualização de registro'              WSSYNTAX '/CONSULTA_SC5/update'                                                                                                  PATH 'update'         PRODUCES APPLICATION_JSON
    WSMETHOD PUT MUDA_SEPCD   DESCRIPTION 'Faz update no campo C5_XSEPCD'        WSSYNTAX '/CONSULTA_SC5/update_xsepcd?{filial, num}'                                                                             PATH 'update_xsepcd'  PRODUCES APPLICATION_JSON
    WSMETHOD PUT MUDA_XLIBCOM DESCRIPTION 'Faz update no campo C5_XLIBCOM'       WSSYNTAX '/CONSULTA_SC5/update_xlibcom?{filial, num}'                                                                            PATH 'update_xlibcom' PRODUCES APPLICATION_JSON
    WSMETHOD PUT ALTERA_CAMPO DESCRIPTION 'Faz update no campo selecionado'      WSSYNTAX '/CONSULTA_SC5/update_campo?{filial, num, campo, booleano, hora, logado, campo_hora, campo_logado}'                     PATH 'update_campo'   PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD GET ID WSRECEIVE id WSSERVICE CONSULTA_SC5
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SC5'

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
            jResponse['nota'] := (cAliasWS)->C5_NOTA 
            jResponse['tpfrete'] := (cAliasWS)->C5_TPFRETE 
            jResponse['condpag'] := (cAliasWS)->C5_CONDPAG 
            jResponse['tipocli'] := (cAliasWS)->C5_TIPOCLI 
            jResponse['blq'] := (cAliasWS)->C5_BLQ 
            jResponse['liberok'] := (cAliasWS)->C5_LIBEROK 
            jResponse['lojacli'] := (cAliasWS)->C5_LOJACLI 
            jResponse['vend1'] := (cAliasWS)->C5_VEND1 
            jResponse['cliente'] := (cAliasWS)->C5_CLIENTE 
            jResponse['tipo'] := (cAliasWS)->C5_TIPO 
            jResponse['num'] := (cAliasWS)->C5_NUM 
            jResponse['emissao'] := (cAliasWS)->C5_EMISSAO 
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet


WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SC5
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
    Local cAliasWS   := 'SC5'

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
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
            oRegistro['nota']       := (cAliasWS)->C5_NOTA 
            oRegistro['tpfrete']    := (cAliasWS)->C5_TPFRETE 
            oRegistro['condpag']    := (cAliasWS)->C5_CONDPAG 
            oRegistro['tipocli']    := (cAliasWS)->C5_TIPOCLI 
            oRegistro['blq']        := (cAliasWS)->C5_BLQ 
            oRegistro['liberok']    := (cAliasWS)->C5_LIBEROK 
            oRegistro['lojacli']    := (cAliasWS)->C5_LOJACLI 
            oRegistro['vend1']      := (cAliasWS)->C5_VEND1 
            oRegistro['cliente']    := (cAliasWS)->C5_CLIENTE 
            oRegistro['tipo']       := (cAliasWS)->C5_TIPO 
            oRegistro['num']        := (cAliasWS)->C5_NUM 
            oRegistro['emissao']    := (cAliasWS)->C5_EMISSAO 
            oRegistro['xflagtr']    := (cAliasWS)->C5_XFLAGTR 
            oRegistro['filial']     := (cAliasWS)->C5_FILIAL 
            oRegistro['xpedtr']     := (cAliasWS)->C5_XPEDTR 
            oRegistro['condpag']    := (cAliasWS)->C5_CONDPAG
            oRegistro['C5_FRETE']   := (cAliasWS)->C5_FRETE
            oRegistro['C5_XGRPVEN'] := (cAliasWS)->C5_XGRPVEN
            oRegistro['C5_XCARTEI'] := (cAliasWS)->C5_XCARTEI
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

WSMETHOD GET TRACK_ORDER WSRECEIVE updated_at, limit, page, pedido, data_ent, filial, vendedor, pcampo, scampo, pvalor, svalor WSSERVICE CONSULTA_SC5
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10000
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local data       := ''
    Local nPedido    := ''
    Local nData_ent  := ''
    Local nFilial    := ''
    Local oRegistro
    Local cAliasWS   := 'SC5'
    Local nvendedor  := ''
    Local lpcampo    := 'C5_XSEPCD'
    Local lscampo    := 'C5_XLIBCOM'
    Local lpvalor     := 'F'
    Local lsvalor     := 'F'

    If ! Empty(::pvalor)
        lpvalor := ::pvalor
    EndIf

    If ! Empty(::svalor)
        lsvalor := ::svalor
    EndIf

    If ! Empty(::pcampo)
        lpcampo := ::pcampo
    EndIf

    If ! Empty(::scampo)
        lscampo := ::scampo
    EndIf

    If ! Empty(::updated_at)
        data := ::updated_at
    EndIf

    If ! Empty(::pedido)
        nPedido := ::pedido
    EndIf

    If ! Empty(::data_ent)
        nData_ent := ::data_ent
    EndIf

    If ! Empty(::filial)
        nFilial := ::filial
    EndIf

    If ! Empty(::vendedor)
        nvendedor := ::vendedor
    EndIf

    //Efetua a busca dos registros
    cQueryTab := " SELECT TAB.C5_XPEDTR, TAB.C5_FILIAL,TAB.C5_CLIENTE , TAB.C5_NUM, TAB.C5_XSEPCD, TAB.C5_XLIBCOM, TAB.C5_XLIBFAT, TAB.C5_XFATURD, TAB.C5_XLIBEXP, TAB.C5_XEXPEDI," + CRLF
    cQueryTab += " TAB.C5_XNSEPCD, TAB.C5_XHSEPCD, TAB.C5_XHLIBCO, TAB.C5_XNLIBCO, TAB.C5_XHLIBFA, TAB.C5_XNLIBFA, TAB.C5_XHFATUR, TAB.C5_XNFATUR, TAB.C5_FECENT," + CRLF
    cQueryTab += " TAB.C5_XHLIBEX, TAB.C5_XNLIBEX, TAB.C5_XHEXPED, TAB.C5_XNEXPED, TAB.C5_VEND1, TAB.C5_LOJACLI," + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC, TAB.R_E_C_D_E_L_ AS RECDEL, TAB.S_T_A_M_P_ AS STAMP" + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    If ! Empty(data)
        cQueryTab += " WHERE S_T_A_M_P_ >= CONVERT(date,'" + data + "',103) AND TAB.C5_NUM like '%"+nPedido+"%' AND TAB.C5_FECENT like '%"+nData_ent+"%' AND TAB.C5_FILIAL like '%"+nFilial+"%' " + CRLF
    EndIf
    If Empty(data)
        cQueryTab += " WHERE TAB.C5_NUM like '%"+nPedido+"%' AND TAB.C5_FECENT like '%"+nData_ent+"%' AND TAB.C5_FILIAL like '%"+nFilial+"%' AND TAB.C5_VEND1 like '%"+nvendedor+"%' AND TAB."+lpcampo+" = '"+lpvalor+"' AND TAB."+lscampo+" = '"+lsvalor+"'" + CRLF
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
            oRegistro['C5_FILIAL']  := (cAliasWS)->C5_FILIAL
            oRegistro['C5_NUM']     := (cAliasWS)->C5_NUM 
            oRegistro['C5_CLIENTE'] := (cAliasWS)->C5_CLIENTE             
            oRegistro['C5_XSEPCD']  := (cAliasWS)->C5_XSEPCD
            oRegistro['C5_XNSEPCD'] := (cAliasWS)->C5_XNSEPCD
            oRegistro['C5_XHSEPCD'] := (cAliasWS)->C5_XHSEPCD
            oRegistro['C5_XLIBCOM'] := (cAliasWS)->C5_XLIBCOM
            oRegistro['C5_XHLIBCO'] := (cAliasWS)->C5_XHLIBCO
            oRegistro['C5_XNLIBCO'] := (cAliasWS)->C5_XNLIBCO
            oRegistro['C5_XLIBFAT'] := (cAliasWS)->C5_XLIBFAT
            oRegistro['C5_XHLIBFA'] := (cAliasWS)->C5_XHLIBFA
            oRegistro['C5_XNLIBFA'] := (cAliasWS)->C5_XNLIBFA
            oRegistro['C5_XFATURD'] := (cAliasWS)->C5_XFATURD
            oRegistro['C5_XHFATUR'] := (cAliasWS)->C5_XHFATUR
            oRegistro['C5_XNFATUR'] := (cAliasWS)->C5_XNFATUR
            oRegistro['C5_XLIBEXP'] := (cAliasWS)->C5_XLIBEXP
            oRegistro['C5_XHLIBEX'] := (cAliasWS)->C5_XHLIBEX
            oRegistro['C5_XNLIBEX'] := (cAliasWS)->C5_XNLIBEX
            oRegistro['C5_XEXPEDI'] := (cAliasWS)->C5_XEXPEDI
            oRegistro['C5_XHEXPED'] := (cAliasWS)->C5_XHEXPED
            oRegistro['C5_XNEXPED'] := (cAliasWS)->C5_XNEXPED
            oRegistro['C5_XPEDTR']  := (cAliasWS)->C5_XPEDTR            
            oRegistro['C5_FECENT']  := (cAliasWS)->C5_FECENT
            oRegistro['C5_VEND1']   := (cAliasWS)->C5_VEND1
            oRegistro['C5_LOJACLI'] := (cAliasWS)->C5_LOJACLI
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

/*/{Protheus.doc} WSMETHOD PUT UPDATE
Atualiza o registro na tabela
@author everson
@since 05/07/2023
@version 1.0
@param id, Caractere, String que será pesquisada através do MsSeek
@obs Codigo gerado automaticamente pelo Autumn Code Maker

    Abaixo um exemplo do JSON que deverá vir no body
    * 1: Para campos do tipo Numérico, informe o valor sem usar as aspas
    * 2: Para campos do tipo Data, informe uma string no padrão 'YYYY-MM-DD'

    {
        "nota": "conteudo",
        "tpfrete": "conteudo",
        "condpag": "conteudo",
        "tipocli": "conteudo",
        "blq": "conteudo",
        "liberok": "conteudo",
        "lojacli": "conteudo",
        "vend1": "conteudo",
        "cliente": "conteudo",
        "tipo": "conteudo",
        "num": "conteudo",
        "emissao": "conteudo"
    }

@see http://autumncodemaker.com
/*/

WSMETHOD PUT UPDATE WSRECEIVE id WSSERVICE CONSULTA_SC5
    Local lRet              := .T.
    Local aDados            := {}
    Local jJson             := Nil
    Local cJson             := Self:GetContent()
    Local cError            := ''
    Local nLinha            := 0
    Local cDirLog           := '\x_logs\'
    Local cArqLog           := ''
    Local cErrorLog         := ''
    Local aLogAuto          := {}
    Local nCampo            := 0
    Local jResponse         := JsonObject():New()
    Local cAliasWS          := 'SC5'
    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.

    //Se não existir a pasta de logs, cria
    IF ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIF    

    //Definindo o conteúdo como JSON, e pegando o content e dando um parse para ver se a estrutura está ok
    Self:SetContentType('application/json')
    jJson  := JsonObject():New()
    cError := jJson:FromJson(cJson)

    //Se o id estiver vazio
    If Empty(::id)
        //SetRestFault(500, 'Falha ao consultar o registro') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'UPD006'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else
        DbSelectArea(cAliasWS)
        (cAliasWS)->(DbSetOrder(1))

        //Se não encontrar o registro
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            //SetRestFault(500, 'Falha ao consultar ID') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
            Self:setStatus(500) 
            jResponse['errorId']  := 'UPD007'
            jResponse['error']    := 'ID não encontrado'
            jResponse['solution'] := 'Código ID não encontrado na tabela ' + cAliasWS
        Else
 
            //Se tiver algum erro no Parse, encerra a execução
            If ! Empty(cError)
                //SetRestFault(500, 'Falha ao obter JSON') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
                Self:setStatus(500) 
                jResponse['errorId']  := 'UPD008'
                jResponse['error']    := 'Parse do JSON'
                jResponse['solution'] := 'Erro ao fazer o Parse do JSON'


            Else
		         DbSelectArea(cAliasWS)
                
		         //Adiciona os dados do ExecAuto
		         aAdd(aDados, {'C5_NOTA',   jJson:GetJsonObject('nota'),   Nil})
		         aAdd(aDados, {'C5_TPFRETE',   jJson:GetJsonObject('tpfrete'),   Nil})
		         aAdd(aDados, {'C5_CONDPAG',   jJson:GetJsonObject('condpag'),   Nil})
		         aAdd(aDados, {'C5_TIPOCLI',   jJson:GetJsonObject('tipocli'),   Nil})
		         aAdd(aDados, {'C5_BLQ',   jJson:GetJsonObject('blq'),   Nil})
		         aAdd(aDados, {'C5_LIBEROK',   jJson:GetJsonObject('liberok'),   Nil})
		         aAdd(aDados, {'C5_LOJACLI',   jJson:GetJsonObject('lojacli'),   Nil})
		         aAdd(aDados, {'C5_VEND1',   jJson:GetJsonObject('vend1'),   Nil})
		         aAdd(aDados, {'C5_CLIENTE',   jJson:GetJsonObject('cliente'),   Nil})
		         aAdd(aDados, {'C5_TIPO',   jJson:GetJsonObject('tipo'),   Nil})
		         aAdd(aDados, {'C5_NUM',   jJson:GetJsonObject('num'),   Nil})
		         aAdd(aDados, {'C5_EMISSAO',   jJson:GetJsonObject('emissao'),   Nil})
		         
		         //Percorre os dados do execauto
		         For nCampo := 1 To Len(aDados)
		         	//Se o campo for data, retira os hifens e faz a conversão
		         	If GetSX3Cache(aDados[nCampo][1], 'X3_TIPO') == 'D'
		         		aDados[nCampo][2] := StrTran(aDados[nCampo][2], '-', '')
		         		aDados[nCampo][2] := sToD(aDados[nCampo][2])
		         	EndIf
		         Next

		         //Chama a atualização automática
		         MsExecAuto({|x, y| MATA410(x, y)}, aDados, 4)

		         //Se houve erro, gera um arquivo de log dentro do diretório da protheus data
		         If lMsErroAuto
		         	//Monta o texto do Error Log que será salvo
		         	cErrorLog   := ''
		         	aLogAuto    := GetAutoGrLog()
		         	For nLinha := 1 To Len(aLogAuto)
		         		cErrorLog += aLogAuto[nLinha] + CRLF
		         	Next nLinha

		            //Grava o arquivo de log
		            cArqLog := 'CONSULTA_SC5_New_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
		            MemoWrite(cDirLog + cArqLog, cErrorLog)

		            //Define o retorno para o WebService
		            //SetRestFault(500, cErrorLog) //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
		            Self:setStatus(500) 
		            jResponse['errorId']  := 'UPD009'
		            jResponse['error']    := 'Erro na atualização do registro'
		            jResponse['solution'] := 'Nao foi possivel incluir o registro, foi gerado um arquivo de log em ' + cDirLog + cArqLog + ' '
		            lRet := .F.

		         //Senão, define o retorno
		         Else
		         	jResponse['note']     := 'Registro incluido com sucesso'
		         EndIf

		     EndIf
		 EndIf
    EndIf

    //Define o retorno
    Self:SetResponse(jResponse:toJSON())
Return lRet

WSMETHOD PUT MUDA_SEPCD WSRECEIVE filial, num WSSERVICE CONSULTA_SC5
    Local lRet       := .T.    
    Local cQryUpd    := ''

    Begin Transaction    
      //Monta o Update
      cQryUpd := " UPDATE " + RetSqlName("SC5") + " "
      cQryUpd += " SET C5_XSEPCD = 'T' "
      cQryUpd += " WHERE "
      cQryUpd += "C5_FILIAL = '" + ::filial+ "' AND C5_NUM = '" + ::num + "'"

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

WSMETHOD PUT MUDA_XLIBCOM WSRECEIVE filial, num WSSERVICE CONSULTA_SC5
    Local lRet       := .T.    
    Local cQryUpd    := ''

    Begin Transaction    
      //Monta o Update
      cQryUpd := " UPDATE " + RetSqlName("SC5") + " "
      cQryUpd += " SET C5_XLIBCOM = 'T' "
      cQryUpd += " WHERE "
      cQryUpd += "C5_FILIAL = '" + ::filial + "' AND C5_NUM = '" + ::num + "'"

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

WSMETHOD PUT ALTERA_CAMPO WSRECEIVE filial, num, campo, booleano, hora, logado, campo_hora, campo_logado WSSERVICE CONSULTA_SC5
    Local lRet       := .T.    
    Local cQryUpd    := ''

    Begin Transaction    
      //Monta o Update
      cQryUpd := " UPDATE " + RetSqlName("SC5") + " "
      cQryUpd += " SET "+::campo+" = '"+::booleano+"', "+::campo_hora+" = '"+::hora+"', "+::campo_logado+" = '"+::logado+"' "
      cQryUpd += " WHERE "
      cQryUpd += "C5_FILIAL = '" + ::filial + "' AND C5_NUM = '" + ::num + "'"

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
