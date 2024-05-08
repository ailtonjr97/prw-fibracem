#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function MVCCAD()
Local oBrowse := FwLoadBrw("MVCCAD")

oBrowse:Activate()

Return

Static Function BrowseDef()
    Local oBrowse := FwmBrowse():New()

    oBrowse:SetAlias("SZ9")
    oBrowse:SetDescription("Aula Sistematizei - SZ9")

    oBrowse:AddLegend("SZ9->Z9_STATUS == 'A'", "GREEN", "Usuario ativo.")
    oBrowse:AddLegend("SZ9->Z9_STATUS == 'I'", "RED", "Usuario inativo.")

    oBrowse:SetOnlyFields({"Z9_FILIAL", "Z9_CODIGO", "Z9_NOME", "Z9_STATUS"})

    oBrowse:DisableDetails()

    oBrowse:Activate()
Return oBrowse

Static Function MenuDef()
Local aMenu := {}

ADD OPTION aMenu TITLE 'Pesquisar'  ACTION 'PesqBrw' OPERATION 1 ACCESS 0
ADD OPTION aMenu TITLE 'Visualizar'  ACTION 'VIEWDEF.MVCCAD' OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir'  ACTION 'VIEWDEF.MVCCAD' OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar'  ACTION 'VIEWDEF.MVCCAD' OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir'  ACTION 'VIEWDEF.MVCCAD' OPERATION 5 ACCESS 0
ADD OPTION aMenu TITLE 'Copiar'  ACTION 'VIEWDEF.MVCCAD' OPERATION 9 ACCESS 0
ADD OPTION aMenu TITLE 'Imprimir'  ACTION 'VIEWDEF.MVCCAD' OPERATION 8 ACCESS 0

aAdd(aMenu, {"incluir DIFERENTE", "u_AXIncluir", 0, 3})


Return aMenu

User Function AXIncluir()
    Local aArea := FWGetArea()
    Local aAreaZ9 := SZ9->(FWGetArea())
    Local nOpcao := 0
    Private cCadastro := "Teste de inclusao"

    nOpcao := AxInclui('SZ9',0,3)
    If nOpcao == 1
        DbSelectArea('SZ9')
        SZ9->(DbSetOrder(1)) // Filial + Código
        alert('teste 1')
        //Se conseguir posicionar no produto
        If SZ9->(DbSeek(FWxFilial('SZ9') + "Z9_COD"))
            alert('teste 2')
            RecLock('SZ9', .F.)
                M->Z9_COD := "VSCODE"
            SZ9->(MsUnlock())
        EndIf
    EndIf
Return

Static Function ModelDef()
Local oModel := Nil

Local oStructSZ9 := FwFormStruct(1, "SZ9")

oModel := MPFormModel():New("MVCCADM", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields("FORMSZ9",,oStructSZ9)

oModel:SetPrimaryKey({"Z9_FILIAL", "Z9_CODIGO"})

oModel:SetDescription("Modelo de dados MVCCAD")

oModel:GetModel("FORMSZ9"):SetDescription("Formulário de Cadastro SZ9")

Return oModel

Static Function ViewDef()
Local oView := Nil

Local oModel := FwLoadModel("MVCCAD")

Local oStructSZ9 := FwFormStruct(2, "SZ9")

oView := FwFormView():New()

oView:SetModel(oModel)

oView:AddField("VIEWSZ9", oStructSZ9, "FORMSZ9")

oView:CreateHorizontalBox("TELASZ9", 100)

oView:EnableTitleView("VIEWSZ9", "Visualização Usuarios.")

oView:SetCloseOnOk({|| .T.})

oView:SetOwnerView("VIEWSZ9", "TELASZ9")

Return oView
