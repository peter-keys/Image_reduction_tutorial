;NAME: 
;	ROSA_directory_generator.bat
;  
; CATEGORY:
;   File I/O
;  	
;PURPOSE:
;	Creates the standard directory structures that we use with the ROSA pipeline
;	This is run from IDL command line to make things easier for the user
;	Assumes you are creating the directories in a UNIX/LINUX type system 
;	May not work, therefore, if you are trying to run it on a laptop
;	You can just manually create the necessary directory structures 
;	This code may be easier (definitely for ROSA SOLARNET work)
;
;  ** NOTE: YOU NEED TO EDIT SOME OF THIS FILE TO GET THE RIGHT DIRECTORIES/FILTERS **
;	
;	You will need to edit:
;		+ Date for the data 	(DDMMMYYY format)
;		+ PI for the data 	(Surname only)
;		+ Target for the data 	(e.g. QS/AR, 1st_target/2nd_target, exposure changes etc..)
;		+ Filter Names		(All used with ROSA - usually 4 - no spaces)
;
;	The parts you need to edit:
;		+ LINES 43:46 - Input the names of the date of observation, PI and pointing targets
;		+ LINES 48:51 - Input the names of the filters used
;		+ LINES 85:97 - Comment out if a second target was not observed
;		+ LINES 167:213 - Comment out if a second target was not observed
;	
;	That's basically it. If you have more than 2 targets, add that in. Normally 
;	this won't be the case. However, you may have different PI's for the one day
;	which sometimes sorts this out. If you don't have a PI (for whatever reason) 
;	you can delete the string in PI (have no characters, even spaces for it and
;	it will be returned as a null and won't effect the other path names).
;
;REQUIREMENTS:
; 	Uses IDL programs: FILE_MKDIR (directory creator) & FILE_CHMOD (rights changer)
;	(P. Keys Dec 2016)
;-
;------------------------------------------------------------------------------------------------

	; If you have only one target, leave 'Target1' as an empty string (no characters, no 
	;	spaces) and don't run the Target2 scripts (in the *****'d section below)
Date_Obs = '08Oct2013/'
PI = 'StudentName/'
Target1 = 'AR11857/'

Filter1 = 'Gband/'
Filter2 = 'Continuum4170/'
Filter3 = 'CaK/'
;Filter4 = 'Hbeta/'

;-----------------------------------
; Paths for pre-speckled raw data
;
; - This is the data that has been 
;   dark/flat corrected and made 
;   into a specklegram for KISIP
;-----------------------------------

	; Raw Data Folder:
raw_directory_path = '/data/rosa3/oldrosa1/Speckle/Data/Raw/'

	; Have to create an individual path for each filter
FILE_MKDIR,raw_directory_path+Date_Obs+PI+Target1+Filter1,/NOEXPAND_PATH
FILE_MKDIR,raw_directory_path+Date_Obs+PI+Target1+Filter2,/NOEXPAND_PATH
FILE_MKDIR,raw_directory_path+Date_Obs+PI+Target1+Filter3,/NOEXPAND_PATH
;FILE_MKDIR,raw_directory_path+Date_Obs+PI+Target1+Filter4,/NOEXPAND_PATH

	; Change the permissions if you need to (QUB people should do this)
FILE_CHMOD,raw_directory_path+Date_Obs,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,raw_directory_path+Date_Obs+PI,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,raw_directory_path+Date_Obs+PI+Target1,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,raw_directory_path+Date_Obs+PI+Target1+Filter1,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,raw_directory_path+Date_Obs+PI+Target1+Filter2,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,raw_directory_path+Date_Obs+PI+Target1+Filter3,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,raw_directory_path+Date_Obs+PI+Target1+Filter4,/A_EXECUTE,/A_WRITE,/A_READ


;*************************************************************************************
	; ONLY RUN IF YOU HAVE A SECOND TARGET ON A SINGLE DAY 
	; - OTHERWISE SKIP THIS SECTION COMPLETELY
	
	; Have to create an individual path for each filter
;FILE_MKDIR,raw_directory_path+Date_Obs+PI+Target2+Filter1,/NOEXPAND_PATH
;FILE_MKDIR,raw_directory_path+Date_Obs+PI+Target2+Filter2,/NOEXPAND_PATH
;FILE_MKDIR,raw_directory_path+Date_Obs+PI+Target2+Filter3,/NOEXPAND_PATH
;FILE_MKDIR,raw_directory_path+Date_Obs+PI+Target2+Filter4,/NOEXPAND_PATH

	; Change the permissions if you need to (QUB people should do this)
;FILE_CHMOD,raw_directory_path+Date_Obs,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,raw_directory_path+Date_Obs+PI,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,raw_directory_path+Date_Obs+PI+Target2,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,raw_directory_path+Date_Obs+PI+Target2+Filter1,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,raw_directory_path+Date_Obs+PI+Target2+Filter2,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,raw_directory_path+Date_Obs+PI+Target2+Filter3,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,raw_directory_path+Date_Obs+PI+Target2+Filter4,/A_EXECUTE,/A_WRITE,/A_READ
;*************************************************************************************

;-----------------------------------
; Paths for speckled reduced data
;
; - This is the data that has been 
;   passed through KISIP and is in 
;   the final stages of processing
;-----------------------------------

	; Reduced Data Folder:
reduced_directory_path = '/data/rosa3/oldrosa1/Speckle/Data/Reconstructed/'

	; Have to create an individual path for each filter and each speckled/mid_processed/processed directory
	
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter1+'speckled/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter1+'mid_processed/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter1+'processed/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter1+'calib/',/NOEXPAND_PATH

FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter2+'speckled/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter2+'mid_processed/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter2+'processed/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter2+'calib/',/NOEXPAND_PATH

FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter3+'speckled/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter3+'mid_processed/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter3+'processed/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter3+'calib/',/NOEXPAND_PATH

FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter4+'speckled/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter4+'mid_processed/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter4+'processed/',/NOEXPAND_PATH
FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target1+Filter4+'calib/',/NOEXPAND_PATH

	; Change the permissions if you need to (QUB people should do this)
FILE_CHMOD,reduced_directory_path+Date_Obs,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter1,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter1+'speckled/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter1+'mid_processed/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter1+'processed/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter1+'calib/',/A_EXECUTE,/A_WRITE,/A_READ

FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter2,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter2+'speckled/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter2+'mid_processed/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter2+'processed/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter2+'calib/',/A_EXECUTE,/A_WRITE,/A_READ

FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter3,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter3+'speckled/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter3+'mid_processed/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter3+'processed/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter3+'calib/',/A_EXECUTE,/A_WRITE,/A_READ

FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter4,/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter4+'speckled/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter4+'mid_processed/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter4+'processed/',/A_EXECUTE,/A_WRITE,/A_READ
FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target1+Filter4+'calib/',/A_EXECUTE,/A_WRITE,/A_READ

;*************************************************************************************
	; ONLY RUN IF YOU HAVE A SECOND TARGET ON A SINGLE DAY 
	; - OTHERWISE SKIP THIS SECTION COMPLETELY

	; Have to create an individual path for each filter and each speckled/mid_processed/processed directory
	
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter1+'speckled/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter1+'mid_processed/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter1+'processed/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter1+'calib/',/NOEXPAND_PATH

;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter2+'speckled/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter2+'mid_processed/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter2+'processed/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter2+'calib/',/NOEXPAND_PATH

;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter3+'speckled/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter3+'mid_processed/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter3+'processed/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter3+'calib/',/NOEXPAND_PATH

;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter4+'speckled/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter4+'mid_processed/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter4+'processed/',/NOEXPAND_PATH
;FILE_MKDIR,reduced_directory_path+Date_Obs+PI+Target2+Filter4+'calib/',/NOEXPAND_PATH

	; Change the permissions if you need to (QUB people should do this)
;FILE_CHMOD,reduced_directory_path+Date_Obs,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter1,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter1+'speckled/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter1+'mid_processed/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter1+'processed/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter1+'calib/',/A_EXECUTE,/A_WRITE,/A_READ

;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter2,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter2+'speckled/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter2+'mid_processed/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter2+'processed/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter2+'calib/',/A_EXECUTE,/A_WRITE,/A_READ

;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter3,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter3+'speckled/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter3+'mid_processed/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter3+'processed/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter3+'calib/',/A_EXECUTE,/A_WRITE,/A_READ

;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter4,/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter4+'speckled/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter4+'mid_processed/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter4+'processed/',/A_EXECUTE,/A_WRITE,/A_READ
;FILE_CHMOD,reduced_directory_path+Date_Obs+PI+Target2+Filter4+'calib/',/A_EXECUTE,/A_WRITE,/A_READ

;*************************************************************************************
;-----------------------------------------------------------------------------------------------------------
						  ; END
