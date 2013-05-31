
--	 Search and Replace Syntax A with your own

--   Erstellt die Datenbank SP_AS_Search_CrawlStore mit Filegruppen
--   Primary:		
--   SP_AS_Search_CrawlStoreData01:	Tabellen der SP_AS_Search_CrawlStore Datenbank
--   >> Optional:	SP_AS_Search_CrawlStoreIndex01:	Indexe der SP_AS_Search_CrawlStore Datenbank
--   Log:		Transaktions Log

-- SyntaxA:				SP_AS_Search_CrawlStore <DATENBANK>
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

CREATE DATABASE [SP_AS_Search_CrawlStore] ON PRIMARY 
	( NAME = N'SP_AS_Search_CrawlStore'
		, FILENAME = N'S:\MSSQL10_50.SHARED01\MSSQL\Data\SP_AS_Search_CrawlStore.mdf' 
		, SIZE = 2048MB			
		, MAXSIZE = UNLIMITED
		, FILEGROWTH = 512MB )	
 
LOG ON 
	( NAME = N'SP_AS_Search_CrawlStoreLog'
		, FILENAME = N'S:\MSSQL10_50.SHARED01\MSSQL\TLog\SP_AS_Search_CrawlStoreLog.ldf' 
		, SIZE = 512MB			-- change DatafileSize
		, MAXSIZE = UNLIMITED 
		, FILEGROWTH = 256MB )		-- change DatafileSize

-- evt. angeben falls eine andere Collation erwünscht ist
-- default ist Server Collation "Latin1_General_CI_AS"
-- Beispiel:
COLLATE Latin1_General_CI_AS_KS_WS		-- special Sharepoint Collation 
-- GO

EXEC dbo.sp_dbcmptlevel @dbname=N'SP_AS_Search_CrawlStore', @new_cmptlevel=100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SP_AS_Search_CrawlStore].[dbo].[sp_fulltext_database] @action = 'disable'	-- change if using FT
end
GO

ALTER DATABASE [SP_AS_Search_CrawlStore] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET ANSI_WARNINGS ON 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET ARITHABORT OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET  ENABLE_BROKER 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET  READ_WRITE 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET  MULTI_USER 
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SP_AS_Search_CrawlStore] SET DB_CHAINING OFF
GO

USE [SP_AS_Search_CrawlStore]
GO
EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false
GO

USE [SP_AS_Search_CrawlStore]
GO
declare @isdefault bit
SELECT @isdefault=convert(bit, (status & 0x10)) FROM sysfilegroups WHERE groupname=N'SP_AS_Search_CrawlStoreData01'
if(@isdefault=0)
	ALTER DATABASE [SP_AS_Search_CrawlStore] MODIFY FILEGROUP [SP_AS_Search_CrawlStoreData01] DEFAULT
GO
USE [master]
GO
declare @isdefault bit
SELECT @isdefault=convert(bit, (status & 0x10)) FROM sysfilegroups WHERE groupname=N'SP_AS_Search_CrawlStoreData01'
if(@isdefault=0)
	ALTER DATABASE [SP_AS_Search_CrawlStore] MODIFY FILEGROUP [SP_AS_Search_CrawlStoreData01] DEFAULT
GO


USE [SP_AS_Search_CrawlStore]
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