/**********************************************************************************
                                   Trivadis AG
-----------------------------------------------------------------------------------
Departement......: ZH-IMS-MS
Scripname........: create_database_with_filegroups_SQL2005_v1.sql
Developer........: DaM
Date.............: 08.05.2006
Version..........: 1.0
Purpose..........: Create Database mit Filegroups
Output.......... :
Invoked from.....:
Remarks..........:
-----------------------------------------------------------------------------------
Changes:
DD.MM.MSSQL.1 Developer		Changes                     Reason
***********************************************************************************/
--	 Search and Replace Syntax A with your own

--   Erstellt die Datenbank SP_Content_Intranet mit Filegruppen
--   Primary:		
--   SP_Content_IntranetData01:	Tabellen der SP_Content_Intranet Datenbank
--   >> Optional:	SP_Content_IntranetIndex01:	Indexe der SP_Content_Intranet Datenbank
--   Log:		Transaktions Log

-- SyntaxA:				SP_Content_Intranet <DATENBANK>
-- SyntaxB: 			MSSQL.1 <InstanceID>

USE MASTER
GO

-- allow xp_cmdshell

-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO

-- To update the currently configured value for advanced options.
RECONFIGURE
GO

-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO

-- To update the currently configured value for this feature.
RECONFIGURE
GO

USE MASTER
GO

-- create folders

EXEC xp_cmdshell 'md S:\MSSQL10_50.SHARED01\MSSQL\Data\'
EXEC xp_cmdshell 'md S:\MSSQL10_50.SHARED01\MSSQL\TLog\'


USE [master]
GO

CREATE DATABASE [SP_Content_Intranet] ON PRIMARY 
	( NAME = N'SP_Content_Intranet'
		, FILENAME = N'S:\MSSQL10_50.SHARED01\MSSQL\Data\SP_Content_Intranet.mdf' 
		, SIZE = 4MB			
		, MAXSIZE = UNLIMITED
		, FILEGROWTH = 5120MB )	
 
LOG ON 
	( NAME = N'SP_Content_IntranetLog'
		, FILENAME = N'S:\MSSQL10_50.SHARED01\MSSQL\TLog\SP_Content_IntranetLog.ldf' 
		, SIZE = 20480MB			-- change DatafileSize
		, MAXSIZE = UNLIMITED 
		, FILEGROWTH = 512MB )		-- change DatafileSize

-- evt. angeben falls eine andere Collation erwünscht ist
-- default ist Server Collation "Latin1_General_CI_AS"
-- Beispiel:
COLLATE Latin1_General_CI_AS_KS_WS		-- special Sharepoint Collation 
-- GO

