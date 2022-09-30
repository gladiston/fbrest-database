@echo off
rem Nome: fbrest-database-from-server.cmd
rem Autor: Gladiston Santana (gladiston.santana [em] gmail.com)
rem Criação: 02/01/2016
rem Atualização: 30/09/2022
rem Observação: Este arquivo deve ser encodado como ANSI WIN1252 caso contrario
rem o cmd do Windows pode ter problemas com arquivos contendo acentuações. 
rem
rem Objetivo: Supondo que você queira transferir um banco de dados remoto
rem do FirebirdSQL para uma base local, simplesmente vai ate o cmd e executa:
rem :  fbrest-database-from-server.cmd fbserver01:/meusdados.fdb meusdadosdev.fdb
rem e o script fará um backup de fbserver01:/meusdados.fdb e o restaurará 
rem localmente como meusdadosdev.fdb. O sistema usa as variaveis de
rem ambiente ISC_USER e ISC_PASSWORD para suprimir a digitação da senha para 
rem acessar fbserver01:/meusdados.fdb, assim a mesma não fica exposta
rem dentro deste script, então tenha certeza de ter definido estas variaives 
rem para o usuario/senha que costumeiramente utiliza.
rem Claro que poderia usar o gbak diretamente, mas se fará isso muitas vezes 
rem é bom ter um script que agiliza esse esforço.
rem Use o recurso do TAB de autocompletar no cmd para não ter que digitar
rem os nomes de arquivos por inteiro.
SETLOCAL ENABLEDELAYEDEXPANSION

rem =
rem = Variaveis que precisa ser setadas e/ou confirmadas
rem =

rem utilitario do gbak a ser usado
set gbak="C:\Program Files\Firebird\Firebird_3_0\gbak.exe"
rem estabelecendo o usuario e senha que tem acesso ao database no servidor local:
if %ISC_USER%. == . set ISC_USER=SYSDBA
if %ISC_PASSWORD%. == . set ISC_PASSWORD=masterkey
rem estabelecendo o usuario e senha que tem acesso 
rem ao database no servidor remoto. Eles devem estar previamente 
rem definidos na area de ambiente, se não estiver, assume o mesmo
rem que o local
if %FDB_REMOTE_SERVER%. == . set FDB_REMOTE_SERVER=fbserver
if %FDB_REMOTE_USER%. == . set FDB_REMOTE_USER=%ISC_USER%
if %FDB_REMOTE_PASSWORD%. == . set FDB_REMOTE_PASSWORD=%LOCAL_PASSWORD%

rem caso o nome do database(segundo parametro) nao seja mencionado
rem entao assume o nome padrao definido abaixo
set default_dbname=noname.fdb
rem opcoes de backup
set bak_options=-v -b -t
rem opcoes de restauracao
set rest_options=-v
rem need_enter maior que zero vai ficar pedindo para pressionar enter em cada etapa
set need_enter=0
rem pega o nome do arquivo.cmd
set curcmd=%0
rem pega o diretorio corrente de onde o cmd esta sendo executado
set curdir=%CD%
rem Primeiro parametro define o banco de dados remoto que será 
rem feito um backup para o disco local e depois restaurado
set fdb_remote=%1
rem se o primeiro parametro nao for informado entao assume o servidor 
rem %FDB_REMOTE_SERVER% com o banco de dados default
if %fdb_remote%. == . set fdb_remote=%FDB_REMOTE_SERVER%:%default_dbname%

rem =
rem = Desse ponto em diante, não altere nada
rem =

rem o segundo parametro será o database local
set fdb_local=%2
if %fdb_local%. == . set fdb_local=%curdir%\%default_dbname%
rem usa -r[eplace] caso o banco de dados local exista
rem ou -c[reate] para criá-lo localmente
if exist %fdb_local% set rest_options=%rest_options% -rep
if not exist %fdb_local% set rest_options=%rest_options% -c

rem definindo o nome do arquivo de backup local
set fbk_local=%curdir%\%default_dbname%.fbk
if exist %fbk_local% del /f /q %fbk_local%

echo ========================================
echo Backup remoto de: %fdb_remote%
echo Backup remoto para o local: %fbk_local%
echo Usuario Remoto: %FDB_REMOTE_SERVER%\%ISC_USER%
echo Usuario Local: .\%ISC_USER%
echo Database Local: %fdb_local%
echo ========================================
if %need_enter% GTR 0 (
  echo Pressione [ENTER] para prosseguir ou [CTRL+C] para cancelar
  pause
)

echo ==== BACKUP ======
rem nao será usado -se que agilizaria o backup porque este tipo de comando nao consegue 
rem transferir o backup remoto para um disco local
set exec_cmd=%gbak% %bak_options% -user %FDB_REMOTE_USER% -password %FDB_REMOTE_PASSWORD% %fdb_remote% %fbk_local%
%exec_cmd%
if not %ERRORLEVEL% equ 0 (
  echo "problema com:"
  echo cmd:%exec_cmd% 
  goto fim
)

echo ==== RESTORE ======
rem se ja existir um backup anterior armazenado entao eu apago
if exist %fbk_local% del /f /q %fbk_local%
set exec_cmd=%gbak% %rest_options% -user %ISC_USER% -password %ISC_PASSWORD% %fbk_local% %fdb_local%
%exec_cmd%
if not %ERRORLEVEL% equ 0 (
  echo "problema com:"
  echo cmd:%exec_cmd% 
  goto fim
)
echo Restauracao de %fbk_local% como %fdb_local% finalizada.
goto fim

:no_params
echo Modo de usar:
echo    %curcmd% [databaseremoto] 
echo O [databaseremoto] devera incluir o endereco do servidor remoto, seja caminho ou alias.
echo O [databaselocal] devera incluir o endereco local para o arquivo de dados. Se suprimido será assumido %fdb_local%.
echo ex: %curcmd% %FDB_REMOTE_SERVER%:%default_dbname% %fdb_local%
echo para transferir %fdb_local% para %curdir%
set need_enter=1
goto fim

:fim
if %need_enter% GTR 0 (
  echo Pressione ENTER para finalizar
  pause
)