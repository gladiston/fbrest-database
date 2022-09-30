@echo off
rem Nome: fbrest-database-from-fbk.cmd
rem Autor: Gladiston Santana (gladiston.santana [em] gmail.com)
rem Criação: 02/01/2016
rem Atualização: 30/09/2022
rem Observação: Este arquivo deve ser encodado como ANSI WIN1252 caso contrario
rem o cmd do Windows pode ter problemas com arquivos contendo acentuações. 
rem
rem Objetivo: Supondo que você tenha um arquivo local de FirebirdSQL,
rem por exemplo, backup.fbk, você simplesmente vai ate o cmd e executa:
rem :  fbrest-database-from-fbk.cmd "backup-2022-09-30+09h37m29s.fbk" teste.fdb
rem e o script fará a restauração para você como teste.fdb. 
rem O script utiliza as variaveis de ambiente ISC_USER e ISC_PASSWORD para 
rem suprimir a digitação da senha e a mesma não ficar exposta dentro 
rem deste script, então tenha certeza de ter definido estas variaives para 
rem o usuario/senha que costumeiramente utiliza.
rem Claro que poderia usar o gbak diretamente, mas se fará isso muitas vezes 
rem é bom ter um script que agiliza.
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
rem caso o nome do database(segundo parametro) nao seja mencionado
rem entao assume o nome padrao definido abaixo
set default_dbname=noname.fdb
rem opcoes de restauracao
set rest_options=-v
rem need_enter maior que zero vai ficar pedindo para pressionar enter em cada etapa
set need_enter=0
rem pega o nome do arquivo.cmd
set curcmd=%0
rem pega o diretorio corrente de onde o cmd esta sendo executado
set curdir=%CD%
rem Primeiro parametro define o fbk
set fbk_file=%1

rem Segundo parametro define o fdb
rem tratando arquivo de base de dados, se ele nao
rem existir entao assume um nome padrao
set fdb_file=%2
if "%fdb_file%." == "." set fdb_file=%curdir%\%default_dbname%

rem =
rem = Desse ponto em diante, não altere nada
rem =

rem usa -r[eplace] caso o banco de dados existe ou
rem -c[reate] para criá-lo 
if exist %fdb_file% set rest_options=%rest_options% -rep
if not exist %fdb_file% set rest_options=%rest_options% -c
echo ========================================
echo Backup Local: %fbk_file%
echo Restaurar localmente em: %fdb_file%
echo Usuario Local: .\%ISC_USER%
echo ========================================
if %need_enter% GTR 0 (
  echo Pressione [ENTER] para prosseguir ou [CTRL+C] para cancelar
  pause
)
if %fbk_file%. == . goto no_params
if %curdir%. == . goto no_params

echo ==== RESTORE ======
rem estabelecendo o usuario e senha que tem acesso ao database no servidor local:
set ISC_USER=%ISC_USER%
set ISC_PASSWORD=%ISC_PASSWORD%
set exec_cmd=%gbak% %rest_options% -user %ISC_USER% -password %ISC_PASSWORD% %fbk_file% "%fdb_file%"
%exec_cmd%
if not %ERRORLEVEL% equ 0 (
  echo "problema com:"
  echo cmd:%exec_cmd% 
  goto fim
)
echo Restauracao de "%fbk_file%" para "%fdb_file%" finalizada com sucesso.
goto fim

:no_params
echo Modo de usar:
echo    %curcmd% [nomedobackup] [nomedodatabase] 
echo O [nomedobackup] devera ser a localizacao do arquivo de backup 
echo O [nomedodatabase] devera ser a localizacao do arquivo de dados a ser restaurado. Este parametro pode ser suprimido e sera assumido %fdb_file%
echo ex: %curcmd% meusdados.fbk meusdados.fdb

set need_enter=1
goto fim

:fim
if %need_enter% GTR 0 (
  echo Pressione ENTER para finalizar
  pause
)