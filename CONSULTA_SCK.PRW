//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} WSRESTFUL CONSULTA_SCK
Retorna itens da proposta
@author everson
@since 19/02/2024
@version 1.0
@type wsrestful
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

WSRESTFUL CONSULTA_SCK DESCRIPTION 'Retorna itens da proposta'
    //Atributos
    WSDATA idN        AS STRING
    WSDATA filial     AS STRING
    WSDATA id         AS STRING    
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
 
    //Métodos
    WSMETHOD GET    ID     DESCRIPTION 'Retorna o registro pesquisado' WSSYNTAX '/CONSULTA_SCK/get_id?{id}'                       PATH 'get_id'        PRODUCES APPLICATION_JSON
    WSMETHOD GET    ALL    DESCRIPTION 'Retorna todos os registros'    WSSYNTAX '/CONSULTA_SCK/get_all?{updated_at, limit, page}' PATH 'get_all'       PRODUCES APPLICATION_JSON
    WSMETHOD GET    ALLID  DESCRIPTION 'Retorna todos os registros do id'    WSSYNTAX '/CONSULTA_SCK/get_all_id?{updated_at ,idN , limit, page, filial}' PATH 'get_all_id'       PRODUCES APPLICATION_JSON    
END WSRESTFUL

/*/{Protheus.doc} WSMETHOD GET ID
Busca registro via ID
@author everson
@since 19/02/2024
@version 1.0
@type method
@param id, Caractere, String que será pesquisada através do MsSeek
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

WSMETHOD GET ID WSRECEIVE id WSSERVICE CONSULTA_SCK
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SCK'

    //Se o id estiver vazio
    If Empty(::id)
        //SetRestFault(500, 'Falha ao consultar o registro') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'ID001'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else
        DbSelectArea(cAliasWS)
        (cAliasWS)->(DbSetOrder(3))

        //Se não encontrar o registro
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            //SetRestFault(500, 'Falha ao consultar ID') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
            Self:setStatus(500) 
            jResponse['errorId']  := 'ID002'
            jResponse['error']    := 'ID não encontrado'
            jResponse['solution'] := 'Código ID não encontrado na tabela ' + cAliasWS
        Else
            //Define o retorno
            jResponse['filial'] := (cAliasWS)->CK_FILIAL 
            jResponse['item'] := (cAliasWS)->CK_ITEM 
            jResponse['produto'] := (cAliasWS)->CK_PRODUTO 
            jResponse['um'] := (cAliasWS)->CK_UM 
            jResponse['qtdven'] := (cAliasWS)->CK_QTDVEN 
            jResponse['prcven'] := (cAliasWS)->CK_PRCVEN 
            jResponse['valor'] := (cAliasWS)->CK_VALOR 
            jResponse['oper'] := (cAliasWS)->CK_OPER 
            jResponse['tes'] := (cAliasWS)->CK_TES 
            jResponse['loja'] := (cAliasWS)->CK_LOJA 
            jResponse['descont'] := (cAliasWS)->CK_DESCONT 
            jResponse['valdesc'] := (cAliasWS)->CK_VALDESC 
            jResponse['pedcli'] := (cAliasWS)->CK_PEDCLI 
            jResponse['descri'] := (cAliasWS)->CK_DESCRI 
            jResponse['prunit'] := (cAliasWS)->CK_PRUNIT 
            jResponse['numpv'] := (cAliasWS)->CK_NUMPV 
            jResponse['obs'] := (cAliasWS)->CK_OBS 
            jResponse['entreg'] := (cAliasWS)->CK_ENTREG 
            jResponse['cotcli'] := (cAliasWS)->CK_COTCLI 
            jResponse['itecli'] := (cAliasWS)->CK_ITECLI 
            jResponse['opc'] := (cAliasWS)->CK_OPC 
            jResponse['clasfis'] := (cAliasWS)->CK_CLASFIS 
            jResponse['filven'] := (cAliasWS)->CK_FILVEN 
            jResponse['filent'] := (cAliasWS)->CK_FILENT 
            jResponse['contrat'] := (cAliasWS)->CK_CONTRAT 
            jResponse['projpms'] := (cAliasWS)->CK_PROJPMS 
            jResponse['edtpms'] := (cAliasWS)->CK_EDTPMS 
            jResponse['taskpms'] := (cAliasWS)->CK_TASKPMS 
            jResponse['comis1'] := (cAliasWS)->CK_COMIS1 
            jResponse['propost'] := (cAliasWS)->CK_PROPOST 
            jResponse['itempro'] := (cAliasWS)->CK_ITEMPRO 
            jResponse['nverpms'] := (cAliasWS)->CK_NVERPMS 
            jResponse['dt1ven'] := (cAliasWS)->CK_DT1VEN 
            jResponse['itemgrd'] := (cAliasWS)->CK_ITEMGRD 
            jResponse['tpprod'] := (cAliasWS)->CK_TPPROD 
            jResponse['fcicod'] := (cAliasWS)->CK_FCICOD 
            jResponse['vlimpor'] := (cAliasWS)->CK_VLIMPOR 
            jResponse['mopc'] := (cAliasWS)->CK_MOPC 
            jResponse['xprazin'] := (cAliasWS)->CK_XPRAZIN 
            jResponse['xentreg'] := (cAliasWS)->CK_XENTREG 
            jResponse['xrotina'] := (cAliasWS)->CK_XROTINA 
            jResponse['xpedcom'] := (cAliasWS)->CK_XPEDCOM 
            jResponse['xitpcom'] := (cAliasWS)->CK_XITPCOM 
            jResponse['xmotprc'] := (cAliasWS)->CK_XMOTPRC 
            jResponse['cknum'] := (cAliasWS)->CK_NUM             
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

/*/{Protheus.doc} WSMETHOD GET ALL
Busca todos os registros através de paginação
@author everson
@since 19/02/2024
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

WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE CONSULTA_SCK
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local oRegistro
    Local cAliasWS   := 'SCK'

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE " + CRLF
    cQueryTab += "     TAB.D_E_L_E_T_ = '' " + CRLF
    
    //Abaixo esta sendo feito o filtro com o campo de log de alteração (LGA), porém desde Maio de 2023, pode apresentar divergências
    // então você pode substituir o campo 'CK_USERLGA' por S_T_A_M_P_, I_N_S_D_T_ ou outro campo de data da tabela
    If ! Empty(::updated_at)
        cQueryTab += "     AND ((CASE WHEN SUBSTRING(CK_USERLGA, 03, 1) != ' ' THEN " + CRLF
        cQueryTab += "        CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(CK_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(CK_USERLGA,16,1)) - 50)),'19960101'),112) " + CRLF
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
            oRegistro['filial'] := (cAliasWS)->CK_FILIAL 
            oRegistro['item'] := (cAliasWS)->CK_ITEM 
            oRegistro['produto'] := (cAliasWS)->CK_PRODUTO 
            oRegistro['um'] := (cAliasWS)->CK_UM 
            oRegistro['qtdven'] := (cAliasWS)->CK_QTDVEN 
            oRegistro['prcven'] := (cAliasWS)->CK_PRCVEN 
            oRegistro['valor'] := (cAliasWS)->CK_VALOR 
            oRegistro['oper'] := (cAliasWS)->CK_OPER 
            oRegistro['tes'] := (cAliasWS)->CK_TES 
            oRegistro['loja'] := (cAliasWS)->CK_LOJA 
            oRegistro['descont'] := (cAliasWS)->CK_DESCONT 
            oRegistro['valdesc'] := (cAliasWS)->CK_VALDESC 
            oRegistro['pedcli'] := (cAliasWS)->CK_PEDCLI 
            oRegistro['descri'] := (cAliasWS)->CK_DESCRI 
            oRegistro['prunit'] := (cAliasWS)->CK_PRUNIT 
            oRegistro['numpv'] := (cAliasWS)->CK_NUMPV 
            oRegistro['obs'] := (cAliasWS)->CK_OBS 
            oRegistro['entreg'] := (cAliasWS)->CK_ENTREG 
            oRegistro['cotcli'] := (cAliasWS)->CK_COTCLI 
            oRegistro['itecli'] := (cAliasWS)->CK_ITECLI 
            oRegistro['opc'] := (cAliasWS)->CK_OPC 
            oRegistro['clasfis'] := (cAliasWS)->CK_CLASFIS 
            oRegistro['filven'] := (cAliasWS)->CK_FILVEN 
            oRegistro['filent'] := (cAliasWS)->CK_FILENT 
            oRegistro['contrat'] := (cAliasWS)->CK_CONTRAT 
            oRegistro['projpms'] := (cAliasWS)->CK_PROJPMS 
            oRegistro['edtpms'] := (cAliasWS)->CK_EDTPMS 
            oRegistro['taskpms'] := (cAliasWS)->CK_TASKPMS 
            oRegistro['comis1'] := (cAliasWS)->CK_COMIS1 
            oRegistro['propost'] := (cAliasWS)->CK_PROPOST 
            oRegistro['itempro'] := (cAliasWS)->CK_ITEMPRO 
            oRegistro['nverpms'] := (cAliasWS)->CK_NVERPMS 
            oRegistro['dt1ven'] := (cAliasWS)->CK_DT1VEN 
            oRegistro['itemgrd'] := (cAliasWS)->CK_ITEMGRD 
            oRegistro['tpprod'] := (cAliasWS)->CK_TPPROD 
            oRegistro['fcicod'] := (cAliasWS)->CK_FCICOD 
            oRegistro['vlimpor'] := (cAliasWS)->CK_VLIMPOR 
            oRegistro['mopc'] := (cAliasWS)->CK_MOPC 
            oRegistro['xprazin'] := (cAliasWS)->CK_XPRAZIN 
            oRegistro['xentreg'] := (cAliasWS)->CK_XENTREG 
            oRegistro['xrotina'] := (cAliasWS)->CK_XROTINA 
            oRegistro['xpedcom'] := (cAliasWS)->CK_XPEDCOM 
            oRegistro['xitpcom'] := (cAliasWS)->CK_XITPCOM 
            oRegistro['xmotprc'] := (cAliasWS)->CK_XMOTPRC 
            oRegistro['cknum'] := (cAliasWS)->CK_NUM            
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

WSMETHOD GET ALLID WSRECEIVE updated_at,idN , limit, page, filial WSSERVICE CONSULTA_SCK
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local nId        := ''
    Local nFilial    := ''
    Local oRegistro
    Local cAliasWS   := 'SCK'

    If ! Empty(::idN)
            nId := ::idN
    EndIf

    If ! Empty(::filial)
        nFilial := ::filial
    EndIf
    //Efetua a busca dos registros
    cQueryTab := " SELECT TAB.R_E_C_N_O_ AS TABREC FROM " + RetSQLName(cAliasWS) + " TAB  WHERE   TAB.D_E_L_E_T_ = '' AND  TAB.CK_NUM = '"+ nId +"' AND TAB.CK_FILIAL = '"+nFilial+"' " + CRLF

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
            oRegistro['filial'] := (cAliasWS)->CK_FILIAL 
            oRegistro['item'] := (cAliasWS)->CK_ITEM 
            oRegistro['produto'] := (cAliasWS)->CK_PRODUTO 
            oRegistro['um'] := (cAliasWS)->CK_UM 
            oRegistro['qtdven'] := (cAliasWS)->CK_QTDVEN 
            oRegistro['prcven'] := (cAliasWS)->CK_PRCVEN 
            oRegistro['valor'] := (cAliasWS)->CK_VALOR 
            oRegistro['oper'] := (cAliasWS)->CK_OPER 
            oRegistro['tes'] := (cAliasWS)->CK_TES 
            oRegistro['loja'] := (cAliasWS)->CK_LOJA 
            oRegistro['descont'] := (cAliasWS)->CK_DESCONT 
            oRegistro['valdesc'] := (cAliasWS)->CK_VALDESC 
            oRegistro['pedcli'] := (cAliasWS)->CK_PEDCLI 
            oRegistro['descri'] := (cAliasWS)->CK_DESCRI 
            oRegistro['prunit'] := (cAliasWS)->CK_PRUNIT 
            oRegistro['numpv'] := (cAliasWS)->CK_NUMPV 
            oRegistro['obs'] := (cAliasWS)->CK_OBS 
            oRegistro['entreg'] := (cAliasWS)->CK_ENTREG 
            oRegistro['cotcli'] := (cAliasWS)->CK_COTCLI 
            oRegistro['itecli'] := (cAliasWS)->CK_ITECLI 
            oRegistro['opc'] := (cAliasWS)->CK_OPC 
            oRegistro['clasfis'] := (cAliasWS)->CK_CLASFIS 
            oRegistro['filven'] := (cAliasWS)->CK_FILVEN 
            oRegistro['filent'] := (cAliasWS)->CK_FILENT 
            oRegistro['contrat'] := (cAliasWS)->CK_CONTRAT 
            oRegistro['projpms'] := (cAliasWS)->CK_PROJPMS 
            oRegistro['edtpms'] := (cAliasWS)->CK_EDTPMS 
            oRegistro['taskpms'] := (cAliasWS)->CK_TASKPMS 
            oRegistro['comis1'] := (cAliasWS)->CK_COMIS1 
            oRegistro['propost'] := (cAliasWS)->CK_PROPOST 
            oRegistro['itempro'] := (cAliasWS)->CK_ITEMPRO 
            oRegistro['nverpms'] := (cAliasWS)->CK_NVERPMS 
            oRegistro['dt1ven'] := (cAliasWS)->CK_DT1VEN 
            oRegistro['itemgrd'] := (cAliasWS)->CK_ITEMGRD 
            oRegistro['tpprod'] := (cAliasWS)->CK_TPPROD 
            oRegistro['fcicod'] := (cAliasWS)->CK_FCICOD 
            oRegistro['vlimpor'] := (cAliasWS)->CK_VLIMPOR 
            oRegistro['mopc'] := (cAliasWS)->CK_MOPC 
            oRegistro['xprazin'] := (cAliasWS)->CK_XPRAZIN 
            oRegistro['xentreg'] := (cAliasWS)->CK_XENTREG 
            oRegistro['xrotina'] := (cAliasWS)->CK_XROTINA 
            oRegistro['xpedcom'] := (cAliasWS)->CK_XPEDCOM 
            oRegistro['xitpcom'] := (cAliasWS)->CK_XITPCOM 
            oRegistro['xmotprc'] := (cAliasWS)->CK_XMOTPRC 
            oRegistro['cknum'] := (cAliasWS)->CK_NUM            
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet
