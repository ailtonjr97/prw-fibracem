#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.ch"

/*/{Protheus.doc} nomeFunction
(long_description)
@type user function
@author user
@since 25/03/2024
@version version
@param param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function ZTESTEFAT()

Local aArea := GetArea()
Local oBrowseSC5

oBrowseSC5 := FwmBrowse():New()
oBrowseSC5:SetAlias("SC5")

oBrowseSC5:SetDescription("Primeiro Módulo - Ailton")

oBrowseSC5:Activate()

RestArea(aArea)

Return Nil

Static Function MenuDef()
    Local aRot := {}

    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ZTESTEFAT' OPERATION MODEL_OPERATION_VIEW ACCESS 0
    ADD OPTION aRot TITLE 'Incluir' ACTION 'VIEWDEF.ZTESTEFAT' OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION aRot TITLE 'Alterar' ACTION 'VIEWDEF.ZTESTEFAT' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRot TITLE 'Excluir' ACTION 'VIEWDEF.ZTESTEFAT' OPERATION MODEL_OPERATION_DELETE ACCESS 0

Return aRot

