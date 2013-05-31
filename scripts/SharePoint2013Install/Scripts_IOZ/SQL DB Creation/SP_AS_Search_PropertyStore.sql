--	 Search and Replace Syntax A with your own

--   Erstellt die Datenbank SP_AS_Search_PropertyStore mit Filegruppen
--   Primary:		
--   SP_AS_Search_PropertyStoreData01:	Tabellen der SP_AS_Search_PropertyStore Datenbank
--   >> Optional:	SP_AS_Search_PropertyStoreIndex01:	Indexe der SP_AS_Search_PropertyStore Datenbank
--   Log:		Transaktions Log

-- SyntaxA:				SP_AS_Search_PropertyStore <DATENBANK>
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

CREATE DATABASE [SP_AS_Search_PropertyStore] ON PRIMARY 
	( NAME = N'SP_AS_Search_PropertyStore'
		, FILENAME = N'S:\MSSQL10_50.SHARED01\MSSQL\Data\SP_AS_Search_PropertyStore.mdf' 
		, SIZE = 2048MB			
		, MAXSIZE = UNLIMITED
		, FILEGROWTH = 512MB )	
 
LOG ON 
	( NAME = N'SP_AS_Search_PropertyStoreLog'
		, FILENAME = N'S:\MSSQL10_50.SHARED01\MSSQL\TLog\SP_AS_Search_PropertyStoreLog.ldf' 
		, SIZE = 512MB			-- change DatafileSize
		, MAXSIZE = UNLIMITED 
		, FILEGROWTH = 256MB )		-- change DatafileSize

-- evt. angeben falls eine andere Collation erwünscht ist
-- default ist Server Collation "Latin1_General_CI_AS"
-- Beispiel:
COLLATE Latin1_General_CI_AS_KS_WS		-- special Sharepoint Collation 
-- GO

EXEC dbo.sp_dbcmptlevel @dbname=N'SP_AS_Search_PropertyStore', @new_cmptlevel=100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SP_AS_Search_PropertyStore].[dbo].[sp_fulltext_database] @action = 'disable'	-- change if using FT
end
GO

ALTER DATABASE [SP_AS_Search_PropertyStore] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET ANSI_PADDING OFF
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET ANSI_WARNINGS ON
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET ARITHABORT OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET  ENABLE_BROKER 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET  READ_WRITE 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET  MULTI_USER 
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SP_AS_Search_PropertyStore] SET DB_CHAINING OFF
GO

USE [SP_AS_Search_PropertyStore]
GO
EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false
GO

USE [SP_AS_Search_PropertyStore]
GO
declare @isdefault bit
SELECT @isdefault=convert(bit, (status & 0x10)) FROM sysfilegroups WHERE groupname=N'SP_AS_Search_PropertyStoreData01'
if(@isdefault=0)
	ALTER DATABASE [SP_AS_Search_PropertyStore] MODIFY FILEGROUP [SP_AS_Search_PropertyStoreData01] DEFAULT
GO
USE [master]
GO
declare @isdefault bit
SELECT @isdefault=convert(bit, (status & 0x10)) FROM sysfilegroups WHERE groupname=N'SP_AS_Search_PropertyStoreData01'
if(@isdefault=0)
	ALTER DATABASE [SP_AS_Search_PropertyStore] MODIFY FILEGROUP [SP_AS_Search_PropertyStoreData01] DEFAULT
GO


USE [SP_AS_Search_PropertyStore]
GO 

-- deny xp_cmdshell

-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO

-- To update the currently configured value for advanced options.
RECONFIGURE
GO

-- To deny the feature.
EXEC sp_configure 'xp_cmdshell', 0
GO

-- To update the currently configured value for this feature.
RECONFIGURE
GO