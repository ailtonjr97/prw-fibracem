//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"


/*/{Protheus.doc} WSRESTFUL CONSULTA_SF4

@author everson
@since 16/05/2024
@version 1.0
@type wsrestful
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

WSRESTFUL CONSULTA_SF4 DESCRIPTION ''
    //Atributos
    WSDATA id         AS STRING
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
 
    //M�todos
    WSMETHOD GET    ID     DESCRIPTION 'Retorna o registro pesquisado' WSSYNTAX '/CONSULTA_SF4/get_id?{id}'                       PATH 'get_id'        PRODUCES APPLICATION_JSON
    WSMETHOD GET    ALL    DESCRIPTION 'Retorna todos os registros'    WSSYNTAX '/CONSULTA_SF4/get_all?{updated_at, limit, page}' PATH 'get_all'       PRODUCES APPLICATION_JSON
END WSRESTFUL

/*/{Protheus.doc} WSMETHOD GET ID
Busca registro via ID
@author everson
@since 16/05/2024
@version 1.0
@type method
@param id, Caractere, String que ser� pesquisada atrav�s do MsSeek
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

WSMETHOD GET ID WSRECEIVE id WSSERVICE CONSULTA_SF4
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SF4'

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
            jResponse['filial'] := (cAliasWS)->F4_FILIAL 
            jResponse['codigo'] := (cAliasWS)->F4_CODIGO 
            jResponse['tipo'] := (cAliasWS)->F4_TIPO 
            jResponse['duplic'] := (cAliasWS)->F4_DUPLIC 
            jResponse['estoque'] := (cAliasWS)->F4_ESTOQUE 
            jResponse['cf'] := (cAliasWS)->F4_CF 
            jResponse['cfext'] := (cAliasWS)->F4_CFEXT 
            jResponse['texto'] := (cAliasWS)->F4_TEXTO 
            jResponse['consumo'] := (cAliasWS)->F4_CONSUMO 
            jResponse['tipoper'] := (cAliasWS)->F4_TIPOPER 
            jResponse['msblql'] := (cAliasWS)->F4_MSBLQL 
            jResponse['tesenv'] := (cAliasWS)->F4_TESENV 
            jResponse['tranfil'] := (cAliasWS)->F4_TRANFIL 
            jResponse['cforig'] := (cAliasWS)->F4_CFORIG 
            jResponse['xctdeb'] := (cAliasWS)->F4_XCTDEB 
            jResponse['xctcre'] := (cAliasWS)->F4_XCTCRE 
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

/*/{Protheus.doc} WSMETHOD GET ALL
Busca todos os registros atrav�s de pagina��o
@author everson
@since 16/05/2024
@version 1.0
@type method
@param updated_at, Caractere, Data de altera��o no formato string 'YYYY-MM-DD' (somente se tiver o campo USERLGA / USERGA na tabela)
@param limit, Num�rico, Limite de registros que ir� vir (por exemplo trazer apenas 100 registros)
@param page, Num�rico, N�mero da p�gina que ir� buscar (se existir 1000 registros dividido por 100 ter� 10 p�ginas de pesquisa)
@obs Codigo gerado automaticamente pelo Autumn Code Maker

    Poderia ser usado o FWAdapterBaseV2(), mas em algumas vers�es antigas n�o existe essa funcionalidade
    ent�o a pagina��o foi feita manualmente

@see http://autumncodemaker.com
/*/

WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SF4
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local oRegistro
    Local cAliasWS   := 'SF4'  



    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "    TAB.R_E_C_D_E_L_ AS RECDEL, TAB.R_E_C_N_O_ AS TABREC  " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF

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
oRegistro['F4_FILIAL']   := (cAliasWS)->F4_FILIAL
oRegistro['F4_CODIGO']   := (cAliasWS)->F4_CODIGO
oRegistro['F4_TIPO']     := (cAliasWS)->F4_TIPO
oRegistro['F4_DUPLIC']   := (cAliasWS)->F4_DUPLIC
oRegistro['F4_ESTOQUE']  := (cAliasWS)->F4_ESTOQUE
oRegistro['F4_CF']       := (cAliasWS)->F4_CF
oRegistro['F4_CFEXT']    := (cAliasWS)->F4_CFEXT
oRegistro['F4_TEXTO']    := (cAliasWS)->F4_TEXTO
oRegistro['F4_CONSUMO']  := (cAliasWS)->F4_CONSUMO
oRegistro['F4_TIPOPER']  := (cAliasWS)->F4_TIPOPER
oRegistro['F4_MSBLQL']   := (cAliasWS)->F4_MSBLQL
oRegistro['F4_TESENV']   := (cAliasWS)->F4_TESENV
oRegistro['F4_TRANFIL']  := (cAliasWS)->F4_TRANFIL
oRegistro['F4_CFORIG']   := (cAliasWS)->F4_CFORIG
oRegistro['F4_XCTDEB']   := (cAliasWS)->F4_XCTDEB
oRegistro['F4_XCTCRE']   := (cAliasWS)->F4_XCTCRE
oRegistro['S_T_A_M_P_']   := ''
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
