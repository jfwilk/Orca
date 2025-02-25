//--------------------------------------------------------
// ORSmartFolder
// Created by Mark  A. Howe on Thu Apr 08 2004
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2004 CENPA, University of Washington. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Washington at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files


#import "ORSmartFolder.h"
#import "ORQueue.h"
#import "ORFileMoverOp.h"
#import "ORFileMover.h"

#pragma mark ***External Strings

NSString* ORFolderCopyEnabledChangedNotification	= @"ORFolderCopyEnabledChangedNotification";
NSString* ORFolderDeleteWhenCopiedChangedNotification = @"ORFolderDeleteWhenCopiedChangedNotification";
NSString* ORFolderRemoteHostChangedNotification		= @"ORFolderRemoteHostChangedNotification";
NSString* ORFolderRemotePathChangedNotification		= @"ORFolderRemotePathChangedNotification";
NSString* ORFolderRemoteUserNameChangedNotification = @"ORFolderRemoteUserNameChangedNotification";
NSString* ORFolderPassWordChangedNotification		= @"ORFolderPassWordChangedNotification";
NSString* ORFolderVerboseChangedNotification		= @"ORFolderVerboseChangedNotification";
NSString* ORFolderDirectoryNameChangedNotification  = @"ORFolderDirectoryNameChangedNotification";
NSString* ORDataFileQueueRunningChangedNotification = @"ORDataFileQueueRunningChangedNotification";
NSString* ORFolderLock								= @"ORFolderLock";
NSString* ORFolderTransferTypeChangedNotification	= @"ORFolderTransferTypeChangedNotification";
NSString* ORFolderPercentDoneChanged                = @"ORFolderPercentDoneChanged";


#if !defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific
@interface ORSmartFolder (private)
- (void)_deleteAllSheetDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(NSDictionary*)userInfo;
- (void)_sendAllSheetDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(NSDictionary*)userInfo;
@end
#endif

@implementation ORSmartFolder
- (id) init
{
    if(self = [super init]){
        
        
#if !defined(MAC_OS_X_VERSION_10_9) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9 // 10.9-specific
        [NSBundle loadNibNamed:@"NcdCableCheckTask" owner:self];
#else
        [[NSBundle mainBundle] loadNibNamed:@"SmartFolder" owner:self topLevelObjects:&topLevelObjects];
#endif

    }
    
    [view retain];
    
    [self setDirectoryName:@"~"];
    [self setRemoteHost:@""];
    [self setRemoteUserName:@""];
    [self setPassWord:@""];

    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(![NSThread isMainThread]){
        [view performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
    }
    else [view removeFromSuperview];
    [title release];
    [remoteHost release];
    [remotePath release];
    [remoteUserName release];
    [passWord release];
    [directoryName release];
    [fileQueue cancelAllOperations];
    [fileQueue release];
    [defaultLastPathComponent release];
    [topLevelObjects release];
    [super dealloc];
}


#pragma mark ***Accessors
- (NSString *)title
{
    return title; 
}

- (void)setTitle:(NSString *)aTitle 
{
    [title autorelease];
    title = [aTitle copy];
    if(title)[titleField setStringValue:title];
}


- (NSUndoManager*) undoManager
{
    return [(ORAppDelegate*)[NSApp delegate] undoManager];
}

- (NSView*) view
{
    return view;
}

- (BOOL) copyEnabled
{
    return copyEnabled;
}
- (void) setCopyEnabled:(BOOL)aNewCopyEnabled
{
    [[[self undoManager] prepareWithInvocationTarget:self] setCopyEnabled:copyEnabled];
    
    copyEnabled = aNewCopyEnabled;
    
    [[NSNotificationCenter defaultCenter] 
		    postNotificationName:ORFolderCopyEnabledChangedNotification 
                          object: self];
}

- (BOOL) deleteWhenCopied
{
    return deleteWhenCopied;
}
- (void) setDeleteWhenCopied:(BOOL)aNewDeleteWhenCopied
{
    [[[self undoManager] prepareWithInvocationTarget:self] setDeleteWhenCopied:deleteWhenCopied];
    
    deleteWhenCopied = aNewDeleteWhenCopied;
    
    [[NSNotificationCenter defaultCenter] 
		    postNotificationName:ORFolderDeleteWhenCopiedChangedNotification 
                          object: self];
}

- (NSString*) remoteHost
{
    return remoteHost;
}
- (void) setRemoteHost:(NSString*)aNewRemoteHost
{
    [[[self undoManager] prepareWithInvocationTarget:self] setRemoteHost:remoteHost];
    
    [remoteHost autorelease];
    remoteHost = [aNewRemoteHost copy];
    
    [[NSNotificationCenter defaultCenter] 
		    postNotificationName:ORFolderRemoteHostChangedNotification 
                          object: self];
}

- (NSString*) remotePath
{
    return remotePath;
}
- (void) setRemotePath:(NSString*)aNewRemotePath
{
    [[[self undoManager] prepareWithInvocationTarget:self] setRemotePath:remotePath];
    
    [remotePath autorelease];
    remotePath = [aNewRemotePath copy];
    
    [[NSNotificationCenter defaultCenter] 
		    postNotificationName:ORFolderRemotePathChangedNotification 
                          object: self];
}

- (NSString*) remoteUserName
{
    return remoteUserName;
}
- (void) setRemoteUserName:(NSString*)aNewRemoteUserName
{
    [[[self undoManager] prepareWithInvocationTarget:self] setRemoteUserName:remoteUserName];
    
    [remoteUserName autorelease];
    remoteUserName = [aNewRemoteUserName copy];
    
    [[NSNotificationCenter defaultCenter] 
		    postNotificationName:ORFolderRemoteUserNameChangedNotification 
                          object: self];
}

- (NSString*) passWord
{
    return passWord;
}
- (void) setPassWord:(NSString*)aNewPassWord
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPassWord:passWord];
    
    [passWord autorelease];
    passWord = [aNewPassWord copy];
    
    [[NSNotificationCenter defaultCenter] 
		    postNotificationName:ORFolderPassWordChangedNotification 
                          object: self];
}

- (BOOL) verbose
{
    return verbose;
}
- (void) setVerbose:(BOOL)aNewVerbose
{
    [[[self undoManager] prepareWithInvocationTarget:self] setVerbose:verbose];
    
    verbose = aNewVerbose;
    
    [[NSNotificationCenter defaultCenter] 
		    postNotificationName:ORFolderVerboseChangedNotification 
                          object: self];
}

- (int) transferType
{
    return transferType;
}
- (void) setTransferType:(int)aNewTransferType
{
    [[[self undoManager] prepareWithInvocationTarget:self] setTransferType:transferType];
    
    transferType = aNewTransferType;
    
    [[NSNotificationCenter defaultCenter] 
		    postNotificationName:ORFolderTransferTypeChangedNotification 
                          object: self];
}

- (BOOL) useFolderStructure
{
	return useFolderStructure;
}

- (void) setUseFolderStructure:(BOOL)aFlag;
{
	useFolderStructure = aFlag;
}

- (NSString*) finalDirectoryName
{
	NSString* path = @"~"; //default
	if(useFolderStructure){
		NSDate* date = [NSDate date];
		NSString* year  = [NSString stringWithFormat:@"%d",(int)[date yearOfCommonEra]];
		NSString* month = [NSString stringWithFormat:@"%02ld",[date monthOfYear]];
		path = [self directoryName];
		path = [path stringByAppendingPathComponent:year];
		path = [path stringByAppendingPathComponent:month];
	
		if(defaultLastPathComponent) path = [path stringByAppendingPathComponent:defaultLastPathComponent];
	}
	else {
		path = [self directoryName];
		if(defaultLastPathComponent) path = [path stringByAppendingPathComponent:defaultLastPathComponent];
	}
    [self ensureExists:path];
	return path;
}

- (NSString*) defaultLastPathComponent
{
	return defaultLastPathComponent;
}

- (void) setDefaultLastPathComponent:(NSString*)aString
{
    [defaultLastPathComponent autorelease];
    defaultLastPathComponent = [aString copy];
}


- (NSString*) directoryName
{
    return directoryName;
}
- (void) setDirectoryName:(NSString*)aNewDirectoryName
{
    [[[self undoManager] prepareWithInvocationTarget:self] setDirectoryName:directoryName];
    
    [directoryName autorelease];
    directoryName = [aNewDirectoryName copy];
 	      
    [[NSNotificationCenter defaultCenter] 
		    postNotificationName:ORFolderDirectoryNameChangedNotification 
                          object: self];
}

- (void) sendAll
{
    workingOnFile   = 0;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* files = [fileManager contentsOfDirectoryAtPath:[[self finalDirectoryName]stringByExpandingTildeInPath] error:nil];
    for(id aFile in files){
        NSString* fullName = [[[self finalDirectoryName] stringByAppendingPathComponent:aFile] stringByExpandingTildeInPath];
        BOOL isDir;
        if ([fileManager fileExistsAtPath:fullName isDirectory:&isDir] && !isDir){
            NSRange range = [fullName rangeOfString:@".DS_Store"];
            if(range.location == NSNotFound){
                [self queueFileForSending:fullName];
            }
        }
    }
}

- (void) deleteAll
{
    if(![self queueIsRunning]){
        ORFileMover* mover = [[ORFileMover alloc] init];
        [mover cleanSentFolder:[[self finalDirectoryName]stringByExpandingTildeInPath]];
        [mover release];
    }
}

- (BOOL) queueIsRunning
{
    return [fileQueue operationCount];
}

- (NSString*) queueStatusString
{
    if([fileQueue operationCount]) {
		if(transferType == eUseCURL){
			if(startCount > 1) return [NSString stringWithFormat:@"Working: %d/%d",workingOnFile,startCount];
			else return [NSString stringWithFormat:@"Working"];
		}
		else {
			if(startCount > 1)return [NSString stringWithFormat:@"Working: %d/%d  %d%%",workingOnFile,startCount,[self percentDone]];
			else return [NSString stringWithFormat:@"Working: %d%%",[self percentDone]];
		}
    }
    else return @"Idle";
}

- (int) percentDone
{
    return percentDone;
}

- (void) setPercentDone:(NSNumber*)aPercent
{
    percentDone = [aPercent intValue];

    [[NSNotificationCenter defaultCenter] postNotificationName:ORDataFileQueueRunningChangedNotification object: self];
    
}

- (NSWindow *)window 
{
    return window; 
}

- (void)setWindow:(NSWindow *)aWindow 
{
    window = aWindow; //don't retain this...
}


#pragma mark ���Data Handling
//some of these methods can run from a thread and can udpate the gui, so post to main thread
- (void) queueFileForSending:(NSString*)fullPath
{
    halt = NO;
    if(!fileQueue){
        fileQueue = [[NSOperationQueue alloc] init];
        [fileQueue setMaxConcurrentOperationCount:1];
        [fileQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    }
    
    startCount++;
    if(workingOnFile==0)workingOnFile=1;
    
    ORFileMoverOp* mover = [[[ORFileMoverOp alloc] init] autorelease];
    mover.delegate     = self;
    mover.transferType = transferType;
    mover.verbose      = verbose;
    mover.fullPath     = fullPath;
	
    NSString* remoteFilePath = [remotePath stringByAppendingPathComponent:[fullPath lastPathComponent]];
    [mover setMoveParams:fullPath to:remoteFilePath remoteHost:remoteHost userName:remoteUserName passWord:passWord];
    
    [fileQueue addOperation:mover];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == fileQueue && [keyPath isEqual:@"operations"]) {
        if([fileQueue operationCount]==0){
            workingOnFile   = 0;
            startCount      = 0;
            if(fileQueue && [self copyEnabled] && !halt){
                [self sendAll];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ORDataFileQueueRunningChangedNotification object: self];
        [self performSelectorOnMainThread:@selector(updateSpecialButtons) withObject:nil waitUntilDone:NO];
    }
}
- (void) updateSpecialButtons
{
    if([self queueIsRunning])   [copyButton setTitle:@"Stop"];
    else                        [copyButton setTitle:@"Send All..."];
    [deleteButton setEnabled:![self queueIsRunning]];
}

- (void) fileMoverIsDone
{
    workingOnFile++;
    if(workingOnFile<0)workingOnFile = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORDataFileQueueRunningChangedNotification object: self];
}

- (void) stopTheQueue
{
    if([fileQueue operationCount]){
        halt = YES;
        NSLog(@"<%@> File transfer stopped\n",title);
        [fileQueue cancelAllOperations];
    }
}

- (BOOL) shouldRemoveFile:(NSString*)aFile
{
    if([[[self finalDirectoryName]stringByExpandingTildeInPath] isEqualToString:[aFile stringByDeletingLastPathComponent]]){
        if(deleteWhenCopied)return YES;
        else return NO;
    }
    else return NO;
}

- (NSString*) ensureSubFolder:(NSString*)subFolder inFolder:(NSString*)folderName
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString* tmpDir = [[folderName stringByExpandingTildeInPath] stringByAppendingPathComponent:subFolder];
    if(![fm fileExistsAtPath:tmpDir]){
		[fm createDirectoryAtPath:tmpDir withIntermediateDirectories:YES attributes:nil error:nil];
     }
    return tmpDir;
}

- (NSString*) ensureExists:(NSString*)folderName
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString* tmpDir = [folderName stringByExpandingTildeInPath];
    if(![fm fileExistsAtPath:tmpDir]){
		[fm createDirectoryAtPath:tmpDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return tmpDir;
}



#pragma mark ***Notifications

- (void) registerNotificationObservers
{
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserver : self
                      selector: @selector(copyEnabledChanged:)
                          name: ORFolderCopyEnabledChangedNotification
                       object : self];
    
    [notifyCenter addObserver : self
                      selector: @selector(deleteWhenCopiedChanged:)
                          name: ORFolderDeleteWhenCopiedChangedNotification
                       object : self];
    
    [notifyCenter addObserver : self
                      selector: @selector(remoteHostChanged:)
                          name: ORFolderRemoteHostChangedNotification
                       object : self];
    
    [notifyCenter addObserver : self
                      selector: @selector(remotePathChanged:)
                          name: ORFolderRemotePathChangedNotification
                       object : self];
    
    [notifyCenter addObserver : self
                      selector: @selector(remoteUserNameChanged:)
                          name: ORFolderRemoteUserNameChangedNotification
                       object : self];
    
    [notifyCenter addObserver : self
                      selector: @selector(passWordChanged:)
                          name: ORFolderPassWordChangedNotification
                       object : self];
    
    [notifyCenter addObserver : self
                      selector: @selector(verboseChanged:)
                          name: ORFolderVerboseChangedNotification
                       object : self];

    [notifyCenter addObserver : self
                      selector: @selector(transferTypeChanged:)
                          name: ORFolderTransferTypeChangedNotification
                       object : self];
    
    [notifyCenter addObserver : self
                      selector: @selector(directoryNameChanged:)
                          name: ORFolderDirectoryNameChangedNotification
                       object : self];
    
    
    [notifyCenter addObserver : self
                     selector : @selector(queueChanged:)
                         name : ORDataFileQueueRunningChangedNotification
                        object: self ];
    
    
    [notifyCenter addObserver : self
                     selector : @selector(securityStateChanged:)
                         name : ORGlobalSecurityStateChanged
                        object: nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : [self lockName]
                        object: nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(sheetChanged:)
                         name : NSWindowWillBeginSheetNotification
                        object: window?window:[view window]];
    
    [notifyCenter addObserver : self
                     selector : @selector(sheetChanged:)
                         name : NSWindowDidEndSheetNotification
                        object: window?window:[view window]];
}

- (void) updateWindow
{
    [self deleteWhenCopiedChanged:nil];
    [self remoteHostChanged:nil];
    [self remotePathChanged:nil];
    [self remoteUserNameChanged:nil];
    [self passWordChanged:nil];
    [self verboseChanged:nil];
    [self transferTypeChanged:nil];
    [self directoryNameChanged:nil];
    [self copyEnabledChanged:nil];
    [self securityStateChanged:nil];
    [self lockChanged:nil];
}

- (void) updateButtons
{
    BOOL enable = ![gSecurity isLocked: [self lockName]] && !sheetDisplayed;
    [remoteHostTextField setEnabled:enable];
    [remotePathTextField setEnabled:enable];
    [userNameTextField setEnabled:enable];
    [passWordSecureTextField setEnabled:enable];
    [copyButton setEnabled:enable];
    [deleteButton setEnabled:enable];
    [verboseButton setEnabled:enable];
    [enableDeleteButton setEnabled:enable];
    [enableCopyButton setEnabled:enable];
    [chooseDirButton setEnabled:enable];
}

- (void) sheetChanged:(NSNotification*)aNotification
{
    if([[aNotification name] isEqualToString:NSWindowWillBeginSheetNotification]){
        if(!sheetDisplayed){
            sheetDisplayed = YES;
            [remoteHostTextField setEnabled:NO];
            [remotePathTextField setEnabled:NO];
            [userNameTextField setEnabled:NO];
            [passWordSecureTextField setEnabled:NO];
            [copyButton setEnabled:NO];
            [deleteButton setEnabled:NO];
            [verboseButton setEnabled:NO];
            [enableCopyButton setEnabled:NO];
            [enableDeleteButton setEnabled:NO];
            [chooseDirButton setEnabled:NO];
         }
    }
    else {
        if(sheetDisplayed){
            sheetDisplayed = NO;
            [self updateButtons];
        }
    }
    
}

- (void) securityStateChanged:(NSNotification*)aNotification
{
    [self checkGlobalSecurity];
}

- (void) checkGlobalSecurity
{
    BOOL secure = [gSecurity globalSecurityEnabled];
    [gSecurity setLock:[self lockName] to:secure];
    [lockButton setEnabled:secure];
    [self updateButtons];
}

- (void) lockChanged:(NSNotification*)aNotification
{
    BOOL locked = [gSecurity isLocked: [self lockName]];
    [lockButton setState: locked];
    [self updateButtons];
}



- (void) copyEnabledChanged:(NSNotification*)note
{
	[enableCopyButton setState:[self copyEnabled]];
}

- (void) deleteWhenCopiedChanged:(NSNotification*)aNote
{
	[enableDeleteButton setState:[self deleteWhenCopied]];
}

- (void) remoteHostChanged:(NSNotification*)aNote
{
	if(remoteHost)[remoteHostTextField setStringValue:remoteHost];
}

- (void) remotePathChanged:(NSNotification*)aNote
{
	if(remotePath)[remotePathTextField setStringValue:remotePath];
}

- (void) remoteUserNameChanged:(NSNotification*)aNote
{
	if(remoteUserName)[userNameTextField setStringValue:remoteUserName];
}

- (void) passWordChanged:(NSNotification*)aNote
{
	if(passWord)[passWordSecureTextField setStringValue:passWord];
}

- (void) verboseChanged:(NSNotification*)aNote
{
	[verboseButton setState: verbose];
}

- (void) transferTypeChanged:(NSNotification*)aNote
{
	[transferTypePopupButton selectItemAtIndex:transferType];
}

- (void) directoryNameChanged:(NSNotification*)aNote
{
	if(directoryName)[dirTextField setStringValue:directoryName];
	else [dirTextField setStringValue:@"~"];
}

- (void) queueChanged:(NSNotification*)note
{        
}
- (NSString*) lockName
{
    return [NSString stringWithFormat:@"%@_%@",ORFolderLock,title];
}

#pragma mark ***Actions

- (IBAction) lockButtonAction:(id)sender
{
    [gSecurity tryToSetLock:[self lockName] to:[sender intValue] forWindow:window?window:[view window]];
}

- (IBAction) copyEnabledAction:(NSButton*)sender
{
    [self setCopyEnabled:[sender state]];
}

- (IBAction) deleteEnabledAction:(NSButton*)sender
{
    [self setDeleteWhenCopied:[sender state]];
}


- (IBAction) chooseDirButtonAction:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setPrompt:@"Choose"];
    [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSString* dirName = [[[openPanel URL]path]stringByAbbreviatingWithTildeInPath];
            [self setDirectoryName:dirName];
        }
    }];
}


- (IBAction) copyButtonAction:(id)sender
{
    if(![[view window] makeFirstResponder:[view window]]){
	    [[view window] endEditingFor:nil];		
    }
    NSString* s = ![self queueIsRunning]?@"You can always send them later.":
    [NSString stringWithFormat:@"Push 'Send' to send ALL files in:\n<%@>",[self finalDirectoryName]];
#if defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:[self queueIsRunning]?@"Stop Sending?":@"Send All Files?"];
    [alert setInformativeText:s];
    [alert addButtonWithTitle:[self queueIsRunning]?@"Stop":@"Send"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertStyle:NSAlertStyleWarning];
    
    [alert beginSheetModalForWindow:[self window]?[self window]:[view window] completionHandler:^(NSModalResponse result){
        if (result == NSAlertFirstButtonReturn){
            if(![self queueIsRunning])[self sendAll];
            else [self stopTheQueue];
        }
    }];
#else
    NSBeginAlertSheet([self queueIsRunning]?@"Stop Sending?":@"Send All Files?",
                      [self queueIsRunning]?@"Stop":@"Send",
                      @"Cancel",
                      nil,window?window:[view window],
                      self,
                      @selector(_sendAllSheetDidEnd:returnCode:contextInfo:),
                      nil,
                      nil,
                      @"%@",s);
#endif
}

- (IBAction) deleteButtonAction:(id)sender
{
    NSString* s = [NSString stringWithFormat:@"Push 'Delete' to delete files that are in:\n<%@/sentFiles>",[self finalDirectoryName]];
#if defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Delete All Sent Files?"];
    [alert setInformativeText:s];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertStyle:NSAlertStyleWarning];
    
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse result){
        if (result == NSAlertFirstButtonReturn){
            [self deleteAll];
       }
    }];
#else
    NSBeginAlertSheet(@"Delete All Sent Files?",
                      @"Delete",
                      @"Cancel",
                      nil,window?window:[view window],
                      self,
                      @selector(_deleteAllSheetDidEnd:returnCode:contextInfo:),
                      nil,
                      nil,
                      @"%@",s);
#endif
}


- (IBAction) remoteHostTextFieldAction:(id)sender
{
    [self setRemoteHost:[sender stringValue]];
}

- (IBAction) remotePathTextFieldAction:(id)sender
{
    [self setRemotePath:[sender stringValue]];
}

- (IBAction) passWordSecureTextFieldAction:(id)sender
{
    [self setPassWord:[sender stringValue]];
}

- (IBAction) userNameTextFieldAction:(id)sender
{
    [self setRemoteUserName:[sender stringValue]];
}

- (IBAction) verboseButtonAction:(NSButton*)sender
{
    [self setVerbose:[sender state]];
}

- (IBAction) transferPopupButtonAction:(id)sender
{
	[self setTransferType:(int)[(NSPopUpButton*)sender indexOfSelectedItem]];
}


#pragma mark ***Archival

static NSString* ORFolderTitle		  = @"ORFolderTitle";
static NSString* ORFolderCopyEnabled      = @"ORFolderCopyEnabled";
static NSString* ORFolderDeleteWhenCopied = @"ORFolderDeleteWhenCopied";
static NSString* ORFolderRemoteHost       = @"ORFolderRemoteHost";
static NSString* ORFolderRemotePath       = @"ORFolderRemotePath";
static NSString* ORFolderRemoteUserName   = @"ORFolderRemoteUserName";
static NSString* ORFolderPassWord         = @"ORFolderPassWord";
static NSString* ORFolderVerbose	  = @"ORFolderVerbose";
static NSString* ORFolderDirectoryName    = @"ORFolderDirectoryName";

- (id) initWithCoder:(NSCoder*)decoder
{
    self = [super init];
#if !defined(MAC_OS_X_VERSION_10_9)
    [NSBundle loadNibNamed:@"SmartFolder" owner:self];
#else
    [[NSBundle mainBundle] loadNibNamed:@"SmartFolder" owner:self topLevelObjects:&topLevelObjects];
#endif
    [topLevelObjects retain];

    [[self undoManager] disableUndoRegistration];
    [self setCopyEnabled:[decoder decodeBoolForKey:ORFolderCopyEnabled]];
    [self setDeleteWhenCopied:[decoder decodeBoolForKey:ORFolderDeleteWhenCopied]];
    [self setRemoteHost:[decoder decodeObjectForKey:ORFolderRemoteHost]];
    [self setRemotePath:[decoder decodeObjectForKey:ORFolderRemotePath]];
    [self setRemoteUserName:[decoder decodeObjectForKey:ORFolderRemoteUserName]];
    [self setPassWord:[decoder decodeObjectForKey:ORFolderPassWord]];
    [self setVerbose:[decoder decodeBoolForKey:ORFolderVerbose]];
    [self setDirectoryName:[decoder decodeObjectForKey:ORFolderDirectoryName]];
    [self setTitle:[decoder decodeObjectForKey:ORFolderTitle]];
    [self setTransferType:[decoder decodeIntForKey:@"transferType"]];
    [[self undoManager] enableUndoRegistration];
    
    [self registerNotificationObservers];
    [self updateWindow];	
    
    return self;
}
- (void) encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeBool:copyEnabled forKey:ORFolderCopyEnabled];
    [encoder encodeBool:deleteWhenCopied forKey:ORFolderDeleteWhenCopied];
    [encoder encodeObject:remoteHost forKey:ORFolderRemoteHost];
    [encoder encodeObject:remotePath forKey:ORFolderRemotePath];
    [encoder encodeObject:remoteUserName forKey:ORFolderRemoteUserName];
    [encoder encodeObject:passWord forKey:ORFolderPassWord];
    [encoder encodeBool:verbose forKey:ORFolderVerbose];
    [encoder encodeObject:directoryName forKey:ORFolderDirectoryName];
    [encoder encodeObject:title forKey:ORFolderTitle];
    [encoder encodeInteger:transferType forKey:@"transferType"];
}

- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary
{
	[dictionary setObject:[NSNumber numberWithInt:copyEnabled] forKey:@"CopyEnabled"];
    [dictionary setObject:[NSNumber numberWithInt:deleteWhenCopied] forKey:@"DeleteWhenCopied"];
    if(remoteHost)[dictionary setObject:remoteHost forKey:@"RemoteHost"];
    if(remotePath)[dictionary setObject:remotePath forKey:@"RemotePath"];
    if(remoteUserName)[dictionary setObject:remoteUserName forKey:@"RemoteUserName"];
    [dictionary setObject:[NSNumber numberWithInt:verbose] forKey:@"Verbose"];
    if(directoryName)[dictionary setObject:directoryName forKey:@"DirectoryName"];
    [dictionary setObject:[NSNumber numberWithInt:transferType] forKey:@"TransferType"];
	return dictionary;
}


@end

#if !defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific
@implementation ORSmartFolder (private)
- (void)_deleteAllSheetDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(NSDictionary*)userInfo
{
    if(returnCode == NSAlertFirstButtonReturn){
        [self deleteAll];
    }
}

- (void)_sendAllSheetDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(NSDictionary*)userInfo
{
    if(returnCode == NSAlertFirstButtonReturn){
        if(![self queueIsRunning])[self sendAll];
        else [self stopTheQueue];
    }
}
@end
#endif

