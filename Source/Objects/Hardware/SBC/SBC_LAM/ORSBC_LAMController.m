//--------------------------------------------------------
// ORSBC_LAMController
// Created by Mark  A. Howe on Mon Aug 23 2004
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

#import "ORSBC_LAMController.h"
#import "ORSBC_LAMModel.h"
#import "OReCPU147Config.h"

@implementation ORSBC_LAMController

#pragma mark ***Initialization

- (id) init
{
	self = [super initWithWindowNibName:@"SBC_LAM"];
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void) awakeFromNib
{
	[super awakeFromNib];
}


#pragma mark ***Notifications

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [super registerNotificationObservers];

    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:) 
                         name : ORRunStatusChangedNotification
                       object : nil];

    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORSBC_LAMLock
                        object: nil];

    [notifyCenter addObserver : self
                     selector : @selector(slotChanged:)
                         name : ORSBC_LAMSlotChangedNotification
                        object: nil];
}

- (void) updateWindow
{
    [super updateWindow];
    [self lockChanged:nil];
    [self slotChanged:nil];
}

#pragma mark ***Interface Management
- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORSBC_LAMLock to:secure];
    [lockButton setEnabled:secure];
}

- (void) lockChanged:(NSNotification*)aNotification
{
    BOOL locked = [gSecurity isLocked:ORSBC_LAMLock];
    
    [lockButton setState: locked];
    [self updateButtons];
}

- (void) slotChanged:(NSNotification*)aNotification
{
	[slotField setIntValue:[model slot]];
	[address1Field setIntValue:MAC_DPM(MAC_WRITE_LAM_START + sizeof(MacWriteLAMStruct)*[model slot])];
	[address2Field setIntValue:MAC_DPM(ECPU_WRITE_LAM_START + sizeof(EcpuWriteLAMStruct)*[model slot])];

	[[self window] setTitle:[NSString stringWithFormat:@"SBC LAM (%d)",[model slot]]];
}


- (void) updateButtons
{
    BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL locked = [gSecurity isLocked:ORSBC_LAMLock];
    
    BOOL someThingSelected = [variableTable selectedRow] >= 0;
    BOOL canAddMore = [[model variableNames] count] < 10;
    
    [newButton setEnabled:!locked && !runInProgress & canAddMore];
    [deleteButton setEnabled:!locked && !runInProgress && someThingSelected];
    [variableTable setEnabled:!locked && !runInProgress];
}

#pragma mark ***Actions
- (IBAction) lockAction:(id) sender
{
    [gSecurity tryToSetLock:ORSBC_LAMLock to:[sender intValue] forWindow:[self window]];
}

- (IBAction) delete:(id)sender
{
    [self deleteAction:sender];
}

- (IBAction) newAction:(id) sender
{
    NSUInteger count = [[model variableNames] count];
    if(count<10){
        NSInteger index =  [variableTable selectedRow];
        if(index<0)index = count;
        else index++;
        [[model variableNames] insertObject:@"Var" atIndex:index];
        [variableTable reloadData];    
        [self updateButtons];
    }
}

- (IBAction) deleteAction:(id) sender
{
    NSInteger index =  [variableTable selectedRow];
    if(index>=0){
        [[model variableNames] removeObjectAtIndex:index];
    }
    [variableTable reloadData];
    [self updateButtons];
}


#pragma mark •••Data Source Methods
- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn row:(int) rowIndex
{
    NSParameterAssert(rowIndex >= 0 && rowIndex < [[model variableNames] count]);
    return [[model variableNames] objectAtIndex:rowIndex];
}

// just returns the number of items we have.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[model variableNames] count];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSParameterAssert(rowIndex >= 0 && rowIndex < [[model variableNames] count]);
    [[model variableNames] replaceObjectAtIndex:rowIndex withObject:anObject];
}

- (void) tableViewSelectionDidChange:(NSNotification*)aNote
{
    [self updateButtons];
}

@end

