//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"



WSRESTFUL CRIA_STAMP_API DESCRIPTION 'Cria Stamp'
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
    WSDATA stamp      AS STRING
    WSDATA codigo     AS STRING
    WSDATA nome       AS STRING
    WSDATA email      AS STRING
    WSDATA alias      AS STRING
    //Métodos
    WSMETHOD GET     ALL     DESCRIPTION 'Cria Stamp na tabela'        WSSYNTAX '/CRIA_STAMP_API/get_stamp?{updated_at, limit, page, updated_at, alias}' PATH 'get_stamp'       PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD GET ALL WSRECEIVE limit, page, alias WSSERVICE CRIA_STAMP_API
Local nI, cConfig, aConfig

//Cria uma nova conexão com um banco (SGBD) através do DBAccess
TCLink() 

//Habilita o Dbaccess e acrescentar o campo STAMP nas novas tabelas
TCConfig('SETUSEROWSTAMP=ON') 

// Habilita criar o campo para tabelas já existentes (Para usar esse segundo comando ( AUTOSTAMP ) , você deve primeiro habilitar o primeiro (USEROWSTAMP)
TCCONfig("SETAUTOSTAMP=ON") 

// Faz o Dbaccess acrescentar a coluna sem precisar recriar a tabela
TCRefresh(::alias) 

//Após execução desligar as chaves para não criar em outras tabelas do sistema desnecessárias 
 TCCONfig("SETUSEROWSTAMP=OFF") 
 TCCONfig("SETAUTOSTAMP=OFF") 

//Encerra a conexão especificada com o DBAccess
TCUnlink() 

Return
