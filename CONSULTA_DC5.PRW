//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} WSRESTFUL CONSULTA_DC5

@author everson
@since 06/11/2023
@version 1.0
@type wsrestful
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

WSRESTFUL CONSULTA_DC5 DESCRIPTION ''
    //Atributos
    WSDATA id         AS STRING
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
 
    //Métodos
    WSMETHOD GET    ID     DESCRIPTION 'Retorna o registro pesquisado' WSSYNTAX '/CONSULTA_DC5/get_id?{id}'                       PATH 'get_id'        PRODUCES APPLICATION_JSON
    WSMETHOD GET    ALL    DESCRIPTION 'Retorna todos os registros'    WSSYNTAX '/CONSULTA_DC5/get_all?{updated_at, limit, page}' PATH 'get_all'       PRODUCES APPLICATION_JSON
END WSRESTFUL

/*/{Protheus.doc} WSMETHOD GET ID
Busca registro via ID
@author everson
@since 06/11/2023
@version 1.0
@type method
@param id, Caractere, String que será pesquisada através do MsSeek
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

WSMETHOD GET ID WSRECEIVE id WSSERVICE CONSULTA_DC5
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'DC5'

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
            jResponse['filial'] := (cAliasWS)->DC5_FILIAL 
            jResponse['servic'] := (cAliasWS)->DC5_SERVIC 
            jResponse['desser'] := (cAliasWS)->DC5_DESSER 
            jResponse['tipo'] := (cAliasWS)->DC5_TIPO 
            jResponse['ordem'] := (cAliasWS)->DC5_ORDEM 
            jResponse['tarefa'] := (cAliasWS)->DC5_TAREFA 
            jResponse['destar'] := (cAliasWS)->DC5_DESTAR 
            jResponse['sertms'] := (cAliasWS)->DC5_SERTMS 
            jResponse['operac'] := (cAliasWS)->DC5_OPERAC 
            jResponse['dessvt'] := (cAliasWS)->DC5_DESSVT 
            jResponse['desope'] := (cAliasWS)->DC5_DESOPE 
            jResponse['tiptra'] := (cAliasWS)->DC5_TIPTRA 
            jResponse['destpt'] := (cAliasWS)->DC5_DESTPT 
            jResponse['catser'] := (cAliasWS)->DC5_CATSER 
            jResponse['doctms'] := (cAliasWS)->DC5_DOCTMS 
            jResponse['desdoc'] := (cAliasWS)->DC5_DESDOC 
            jResponse['segper'] := (cAliasWS)->DC5_SEGPER 
            jResponse['funexe'] := (cAliasWS)->DC5_FUNEXE 
            jResponse['tpsele'] := (cAliasWS)->DC5_TPSELE 
            jResponse['serope'] := (cAliasWS)->DC5_SEROPE 
            jResponse['dseope'] := (cAliasWS)->DC5_DSEOPE 
            jResponse['tabseg'] := (cAliasWS)->DC5_TABSEG 
            jResponse['tptseg'] := (cAliasWS)->DC5_TPTSEG 
            jResponse['desc1'] := (cAliasWS)->DC5_DESC1 
            jResponse['desc2'] := (cAliasWS)->DC5_DESC2 
            jResponse['desc3'] := (cAliasWS)->DC5_DESC3 
            jResponse['desc4'] := (cAliasWS)->DC5_DESC4 
            jResponse['tiprat'] := (cAliasWS)->DC5_TIPRAT 
            jResponse['tpexec'] := (cAliasWS)->DC5_TPEXEC 
            jResponse['utsubs'] := (cAliasWS)->DC5_UTSUBS 
            jResponse['utisdc'] := (cAliasWS)->DC5_UTISDC 
            jResponse['nature'] := (cAliasWS)->DC5_NATURE 
            jResponse['blqlot'] := (cAliasWS)->DC5_BLQLOT 
            jResponse['cofexp'] := (cAliasWS)->DC5_COFEXP 
            jResponse['libped'] := (cAliasWS)->DC5_LIBPED 
            jResponse['blqsrv'] := (cAliasWS)->DC5_BLQSRV 
            jResponse['mntvol'] := (cAliasWS)->DC5_MNTVOL 
            jResponse['updend'] := (cAliasWS)->DC5_UPDEND 
            jResponse['updprd'] := (cAliasWS)->DC5_UPDPRD 
            jResponse['dissep'] := (cAliasWS)->DC5_DISSEP 
            jResponse['mntexc'] := (cAliasWS)->DC5_MNTEXC 
            jResponse['bxesto'] := (cAliasWS)->DC5_BXESTO 
            jResponse['impeti'] := (cAliasWS)->DC5_IMPETI 
            jResponse['mltati'] := (cAliasWS)->DC5_MLTATI 
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

/*/{Protheus.doc} WSMETHOD GET ALL
Busca todos os registros através de paginação
@author everson
@since 06/11/2023
@version 1.0
@type method
@param updated_at, Caractere, Data de alteração no formato string 'YYYY-MM-DD' (somente se tiver o campo USERLGA / USERGA na tabela)
@param limit, Numérico, Limite de registros que irá vir (por exemplo trazer apenas 100 registros)
@param page, Numérico, Número da página que irá buscar (se existir 1000 registros dividido por 100 terá 10 páginas de pesquisa)
@obs Codigo gerado automaticamente pelo Autumn Code Maker

    Poderia ser usado o FWAdapterBaseV2(), mas em algumas versões antigas não existe essa funcionalidade
    então a paginação foi feita manualmente

@see http://autumncodemaker.com
/*/

WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_DC5
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local oRegistro
    Local cAliasWS   := 'DC5'

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE " + CRLF
    cQueryTab += "     TAB.D_E_L_E_T_ = '' " + CRLF
    
    //Abaixo esta sendo feito o filtro com o campo de log de alteração (LGA), porém desde Maio de 2023, pode apresentar divergências
    // então você pode substituir o campo 'DC5_USERGA' por S_T_A_M_P_, I_N_S_D_T_ ou outro campo de data da tabela
    If ! Empty(::updated_at)
        cQueryTab += "     AND ((CASE WHEN SUBSTRING(DC5_USERGA, 03, 1) != ' ' THEN " + CRLF
        cQueryTab += "        CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(DC5_USERGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(DC5_USERGA,16,1)) - 50)),'19960101'),112) " + CRLF
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
            oRegistro['filial'] := (cAliasWS)->DC5_FILIAL 
            oRegistro['servic'] := (cAliasWS)->DC5_SERVIC 
            oRegistro['desser'] := (cAliasWS)->DC5_DESSER 
            oRegistro['tipo'] := (cAliasWS)->DC5_TIPO 
            oRegistro['ordem'] := (cAliasWS)->DC5_ORDEM 
            oRegistro['tarefa'] := (cAliasWS)->DC5_TAREFA 
            oRegistro['destar'] := (cAliasWS)->DC5_DESTAR 
            oRegistro['sertms'] := (cAliasWS)->DC5_SERTMS 
            oRegistro['operac'] := (cAliasWS)->DC5_OPERAC 
            oRegistro['dessvt'] := (cAliasWS)->DC5_DESSVT 
            oRegistro['desope'] := (cAliasWS)->DC5_DESOPE 
            oRegistro['tiptra'] := (cAliasWS)->DC5_TIPTRA 
            oRegistro['destpt'] := (cAliasWS)->DC5_DESTPT 
            oRegistro['catser'] := (cAliasWS)->DC5_CATSER 
            oRegistro['doctms'] := (cAliasWS)->DC5_DOCTMS 
            oRegistro['desdoc'] := (cAliasWS)->DC5_DESDOC 
            oRegistro['segper'] := (cAliasWS)->DC5_SEGPER 
            oRegistro['funexe'] := (cAliasWS)->DC5_FUNEXE 
            oRegistro['tpsele'] := (cAliasWS)->DC5_TPSELE 
            oRegistro['serope'] := (cAliasWS)->DC5_SEROPE 
            oRegistro['dseope'] := (cAliasWS)->DC5_DSEOPE 
            oRegistro['tabseg'] := (cAliasWS)->DC5_TABSEG 
            oRegistro['tptseg'] := (cAliasWS)->DC5_TPTSEG 
            oRegistro['desc1'] := (cAliasWS)->DC5_DESC1 
            oRegistro['desc2'] := (cAliasWS)->DC5_DESC2 
            oRegistro['desc3'] := (cAliasWS)->DC5_DESC3 
            oRegistro['desc4'] := (cAliasWS)->DC5_DESC4 
            oRegistro['tiprat'] := (cAliasWS)->DC5_TIPRAT 
            oRegistro['tpexec'] := (cAliasWS)->DC5_TPEXEC 
            oRegistro['utsubs'] := (cAliasWS)->DC5_UTSUBS 
            oRegistro['utisdc'] := (cAliasWS)->DC5_UTISDC 
            oRegistro['nature'] := (cAliasWS)->DC5_NATURE 
            oRegistro['blqlot'] := (cAliasWS)->DC5_BLQLOT 
            oRegistro['cofexp'] := (cAliasWS)->DC5_COFEXP 
            oRegistro['libped'] := (cAliasWS)->DC5_LIBPED 
            oRegistro['blqsrv'] := (cAliasWS)->DC5_BLQSRV 
            oRegistro['mntvol'] := (cAliasWS)->DC5_MNTVOL 
            oRegistro['updend'] := (cAliasWS)->DC5_UPDEND 
            oRegistro['updprd'] := (cAliasWS)->DC5_UPDPRD 
            oRegistro['dissep'] := (cAliasWS)->DC5_DISSEP 
            oRegistro['mntexc'] := (cAliasWS)->DC5_MNTEXC 
            oRegistro['bxesto'] := (cAliasWS)->DC5_BXESTO 
            oRegistro['impeti'] := (cAliasWS)->DC5_IMPETI 
            oRegistro['mltati'] := (cAliasWS)->DC5_MLTATI 
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet
