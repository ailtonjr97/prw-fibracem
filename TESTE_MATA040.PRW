#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"

User Function MyMata040()

Local aDados := {}

Private lMsErroAuto

RPCSetEnv("01", "0101001", "ailton souza", "bagre157", "FAT")

aAdd(aDados, {"A3_FILIAL", "0101", nil})
aAdd(aDados, {"A3_COD", "000040", nil})
aAdd(aDados, {"A3_NOME", "TESTE INSERT API", nil})
aAdd(aDados, {"A3_MSBLQL", "2", nil})
aAdd(aDados, {"A3_GERASE2", "F", nil})
aAdd(aDados, {"A3_COMIS", 0, nil})
aAdd(aDados, {"A3_ALEMISS", 0, nil})
aAdd(aDados, {"A3_ALEMISS", 0, nil})
aAdd(aDados, {"A3_QTCONTA", 0, nil})
aAdd(aDados, {"A3_ACREFIN", "N", nil})
aAdd(aDados, {"A3_DIA", 0, nil})
aAdd(aDados, {"A3_PERDESC", 0, nil})
aAdd(aDados, {"A3_DIARESE", 0, nil})
aAdd(aDados, {"A3_SINCTAF", "S", nil})
aAdd(aDados, {"A3_SINCAGE", "S", nil})
aAdd(aDados, {"A3_SINCCON", "S", nil})
aAdd(aDados, {"A3_PERAGE", "A", nil})
aAdd(aDados, {"A3_PERTAF", "A", nil})
aAdd(aDados, {"A3_TIMEMIN", "30", nil})
aAdd(aDados, {"A3_NIVEL", 0, nil})
aAdd(aDados, {"A3_BIAGEND", "2", nil})
aAdd(aDados, {"A3_BITAREF", "2", nil})
aAdd(aDados, {"A3_BICONT", "2", nil})
aAdd(aDados, {"A3_BASEIR", "1", nil})
aAdd(aDados, {"A3_HAND", "1", nil})
aAdd(aDados, {"A3_MODTRF", "1", nil})
aAdd(aDados, {"A3_XCOMISP", "1", nil})


MSExecAuto({|x,y,z|mata040(x,y,z)},aDados,3)


If lMsErroAuto
    MsgStop("Erro na inclusão.")
    MostraErro()
Else
    MsgAlert('Vendedor criado com sucesso.')

EndIf

RpcClearEnv() 

Return
