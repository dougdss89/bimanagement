/*

=========== CRIANDO UMA USER-DEFINED ROLE =========== 

*/
CREATE ROLE [NOME_ROLE]

-- INSERINDO USU�RIOS DENTRO DA ROLE
-- OS USU�RIOS DEVEM TER PERMISS�O DE ACESSO (CONTA CRIADA) NO BANCO
ALTER ROLE [NOME_ROLE] ADD MEMBER [NOME_USUARIO]

-- INSERINDO A ROLE EM GRUPOS DE PERMISS�ES SEM ATRIBUI��O INDIVIDUAL
-- AS ROLES AQUI, J� S�O DEFAULT EM CADA BANCO, N�O PRECISA CRIAR
-- COMO ESTAMOS ALTERANDO UMA ROLE INSERINDO A ROLE CRIADA NAS DATABASE ROLE, NA SINTAXE, ELAS V�M PRIMEIRO

ALTER ROLE DB_DATAREADER ADD MEMBER [SUA_ROLE_CRIADA] -- AQUI, TODOS  OS USU�RIOS PODER�O EXECUTAR O COMANDO SELECT
ALTER ROLE DB_DATAWRITER ADD MEMBER [SUA_ROLE_CRIADA] -- TODOS OS USU�RIOS AGRUPARDOS NA ROLE PODER�O INSERIR DADOS

-- PARA EXCLUIR A ROLE DO GRUPO, CASO TENHA INSERIDO ERRADO, O COMANDO N�O VARIA MUITO
ALTER ROLE DB_DATAREADER DROP MEMBER [SUA_ROLE_CRIADA] -- COM ISSO, NENHUM USU�RIO NESTA ROLE EXECUTARA MAIS O COMANDO SELECT.

-- ATRIBUINDO PERMISS�O PARA USU�RIOS E ROLES

-- ATRIBUINDO AO USU�RIO OU A ROLE A AUTORIZA��O PARA EXECUTAR SELECT
GRANT SELECT TO [NOME_USUARIO]
GRANT SELECT TO [NOME_ROLE]
GRANT SELECT TO [NOME_USUARIO] WITH GRANT OPTION -- PERMITE QUE ESTE POSSA DISTRIBUIR PERMISS�ES PARA OUTROS

-- PERMISS�O PARA UM USU�RIO EXECUTAR UMA STORED PROCEDURE
GRANT EXEC TO [NOME_USUARIO]
GRANT EXEC TO [NOME_ROLE]
GRANT EXEC ON [SP_HELP] TO [NOME_USUARIO] -- GARANTE QUE O USUARIO POSSA EXECUTAR APENAS UMA PROCEDURE ESPEC�FICA

-- PARA FUN��O TAMB�M � BASEADO NO GRANT SELECT, UMA FEZ QUE AS FUN��ES S�O 'SELECIONADAS'
GRANT SELECT ON [NOME_FUN��O] TO [NOME_USUARIO]
GRANT SELECT ON [NOME_FUN��O] TO [NOME_ROLE]

-- FILTRANDO GRANT SELECT PARA TABELAS E COLUNAS
GRANT SELECT ON [TABELA] (COLUNA) TO [NOME_USUARIO]

-- PERMISSAO DE UPDATE NA TABELA
GRANT UPDATE ON [TABELA] TO [NOME_USUARIO]
GRANT UPDATE ON [TABELA] (COLUNA) TO [NOME_USUARIO]

GRANT SELECT ON SALES.ORDERS TO USER02PL

-- PERMISS�O EM SCHEMAS DE TABELAS

-- PERMISS�O PARA SELECT ESPEC�FICO EM UM SCHEMA
GRANT SELECT ON SCHEMA::[NOME_SCHEMA] TO [NOME_USUARIO]
GRANT SELECT ON SCHEMA:: [NOME SCHEMA] TO [NOME_ROLE]

-- UPDATE EM UM SCHEMA
GRANT UPDATE ON SCHEMA:: [NOME_SCHEMA] TO [NOME_USUARIO]
GRANT UPDATE ON SCHEMA:: [NOME_SCHEMA] TO [NOME_ROLE]

-- NEGANDO PERMISS�O  AO SCHEMA
DENY SELECT ON SCHEMA:: [NOME_SCHEMA] TO [NOME_USUARIO]
REVOKE SELECT ON SCHEMA::[NOME_SCHEMA] TO [NOME_USUARIO]

/*

========= CUSTOM SERVER ROLE =========

*/

-- CRIANDO A SERVER ROLE PARA TESTE
CREATE SERVER ROLE AZSRVROLE

-- AQUI EU POSSO ATRIBUIR TANTO UM USU�RIO, QUANTO UM DATABASE ROLE (CUSTOM OU DE SYSTEM)
-- FOI ATRIBUIDO NO EXEMPLO ABAIXO, PERMISS�O PARA USU�RIOS REALIZAREM OPERA��ES DE BULK
ALTER SERVER ROLE BULKADMIN ADD MEMBER [NOME_SERVER_ROLE]
ALTER SERVER ROLE BULKADMIN ADD MEMBER [NOME_USUARIO]

-- CASO QUEIRA DEIXAR UM GRUPO OU USU�RIO ESPEC�FICO COMO ADMINISTRADOR DO SERVIDOR, BASTA:
ALTER SERVER ROLE SERVERADMIN ADD MEMBER [NOME_SERVER_ROLE]
ALTER SERVER ROLE SERVERADMIN ADD MEMBER [NOME_USUARIO]

-- PERMISS�O DO SERVIDOR PARA CRIAR LOGINS E AUTORIZA��ES PARA TODOS OS BANCOS, �:
ALTER SERVER ROLE SECURITYADMIN ADD MEMBER [NOME_SERVER_ROLE]
ALTER SERVER ROLE SECURITYADMIN ADD MEMBER [NOME_USUARIO]

-- PERMITE CRIAR BANCOS DE DADOS NO SERVIDOR
ALTER SERVER ROLE [NOME_SERVER_ROLE] ADD 

/*

============ APPLICATION ROLE ============

*/

-- ABAIXO A SINTAXE PARA CRIA��O DE UMA APPLICATION ROLE NO BANCO
-- � IMPORTATE DECLARAR O SCHEMA PADR�O PARA LIMITAR O CAMPO DE ATUA��O DA APPROLE
-- N�O ESQUE�A DE CRIAR NO BANCO ONDE A APLICA��O IR� 'TRABALHAR'
CREATE APPLICATION ROLE [NOME_APPLICATION_ROLE]
WITH PASSWORD = 'SENHA!', DEFAULT_SCHEMA = SALES;

-- ATIVANDO A APPLICATION ROLE NO BANCO
-- COMO MENCIONADO, PRECISAMOS EXECUTAR UMA STORED PROCEDURE PARA ATIVAR
EXEC sp_setapprole '[NOME_APPLICATION_ROLE]', 'SENHA!';
go

-- DANDO PERMISS�O PARA A APPLICATION ROLE REALIZAR LEITURA E ESCRITAS EM TABELAS
-- O APPLICATION ROLE ENCARA AS DATABASE ROLES COMO SCHEMA, POR ISSO, A SINTAXE � UM POUCO ALTERADA
ALTER AUTHORIZATION ON SCHEMA:: DB_DATAREADER TO [NOME_APPROLE]
ALTER AUTHORIZATION ON SCHEMA:: [db_denydatawriter] TO [NOME_APPROLE]

-- FORMA CONVENCIONAL DE ATRIBUIR PERMISS�O PARA APPLICATION ROLE
ALTER ROLE DB_DATAREADER ADD MEMBER [NOME_APPROLE]

-- QUERY DE SISTEMA PARA VERIFICAR TODAS AS PERMISS�ES DISPON�VEIS
-- TAMB�M FUNCIONA NO AZURESQL
select * from sys.fn_builtin_permissions(default)

-- ESTA QUERY MOSTRA TODAS AS PERMISS�ES A N�VEL DE SERVIDOR
SELECT * FROM sys.fn_builtin_permissions('SERVER') ORDER BY permission_name; 



/*

============ ORPHANED USER ============

*/

-- EXECUTE AS QUERIES NO BANCO EM QUE SE QUER DESCOBRIR OS USU�RIOS �RF�OS
-- O QUE FAZ UM USU�RIO FICAR 'ORF�O' DO SEU LOGIN � A PERDA DO SID COMO REFER�NCIA

-- ESTA QUERY IR� MOSTRAR TODOS OS USU�RIOS QUE O BANCO POSSUI
-- QUANDO EXECUTADA NO BANCO QUE O USU�RIO SEM LOGIN EST�, SALVE O SID DESTE USU�RIO.
SELECT name, principal_id, type_desc,sid 
FROM SYS.database_principals
WHERE type = 'S'

-- ESSA QUERY IR� MOSTRAR TODOS OS LOGINS BASEADOS EM SQL SERVER AUTHENTICATION
-- EXECUTE ESTA QUERY E VEJA SE O LOGIN APARECE, E SALVE O SID
SELECT name, principal_id, sid
FROM SYS.sql_logins

-- ESSA QUERY MOSTRA TODOS OS LOGINS DE ACESSO A INST�NCIA DE BANCOS
-- OS LOGINS S�O SEPARADOS PELOS TIPOS WINDOWS E SQL SERVER
SELECT name, principal_id, sid, type_desc, TYPE
FROM SYS.server_principals
WHERE TYPE = 'S' OR type = 'U'
ORDER BY type_desc

-- COM O SID, BASTA CRIAR UM NOVO LOGIN PARA O USU�RIO
-- O LOGIN RECRIADO DEVE TER O MESMO SID DO USU�RIO
CREATE LOGIN USER02PL 
WITH PASSWORD = 'SUA_SENHA_FORTE',
SID = 0x6192A1205A98C84CBDA29BA3A33808F3 -- SID COPIADO

-- AP�S, ALTERE O USU�RI APONTANDO PARA O LOGIN RECRIADO 
ALTER USER USER02PL WITH LOGIN = USER02PL -- ATRIBUINDO O USU�RIO PARA O SEU DEVIDO LOGIN

-- QUERY ALTERNATIVA PARA O TROUBLESHOOTING
SELECT name, sid, principal_id
FROM sys.database_principals 
WHERE type = 'S' 
  AND name NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys')
  AND authentication_type_desc = 'INSTANCE';


