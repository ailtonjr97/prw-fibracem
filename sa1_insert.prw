#Include "Protheus.ch"
#include "TBICONN.CH"
#Include "Totvs.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RESTFUL.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} MyCRMA980
Função de exemplo para utilização da rotina automática de Clientes.
/*/
//-------------------------------------------------------------------
User Function INSERTCRMA980()
 
Local aSA1Auto := {}
Local aAI0Auto := {}
Local nOpcAuto := 4 //Número 4 indica update
Local lRet := .T.
 
Private lMsErroAuto := .F.
 
lRet := RpcSetEnv("T1","D MG 01","Admin")

If lRet
 
 //----------------------------------
 // Dados do Cliente
 //----------------------------------
 aAdd(aSA1Auto,{"A1_COD" ,"C00009" ,Nil})
 aAdd(aSA1Auto,{"A1_NOME" ,"ROTINA AUTOMATICA" ,Nil})
 aAdd(aSA1Auto,{"A1_NREDUZ" ,"ROTAUTO" ,Nil}) 
 
 //---------------------------------------------------------
 // Dados do Complemento do Cliente
 //---------------------------------------------------------
 aAdd(aAI0Auto,{"AI0_SALDO" ,30 ,Nil})
 
 //------------------------------------
 // Chamada para cadastrar o cliente.
 //------------------------------------
 MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto, {})
 
 If lMsErroAuto 
 lRet := lMsErroAuto
 MostraErro() // Não funciona na execução via JOB
 Else
 Conout("Cliente atualizado com sucesso!")
 EndIf
 
EndIf
 
RpcClearEnv()
 
Return lRet
