//--------------------------------------------------------
// ORTPG256AController
//  Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
//  Created by Mark Howe on Mon Apr 16 2012.
//  Copyright 2012  University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files

@class ORCompositeTimeLineView;
@class ORSerialPortController;

@interface ORTPG256AController : OrcaObjectController
{
	IBOutlet NSTabView*		tabView;	
	IBOutlet NSView*		totalView;
    IBOutlet NSTextField*   lockDocField;
	IBOutlet NSPopUpButton* unitsPU;
	IBOutlet NSPopUpButton*	pressureScalePU;
	IBOutlet NSButton*		shipPressuresButton;
    IBOutlet NSButton*      lockButton;
    IBOutlet NSPopUpButton* pollTimePopup;
    IBOutlet NSButton*      readPressuresButton;
	IBOutlet ORCompositeTimeLineView*   plotter0;
	IBOutlet NSTableView*	pressureTableView;
	IBOutlet NSTableView*	processLimitTableView;
    IBOutlet NSButton*		yAxisLogCB;
    IBOutlet ORSerialPortController* serialPortController;

	NSSize					basicOpsSize;
	NSSize					plotSize;
	NSSize					processLimitSize;
	NSView*					blankView;
}

#pragma mark ***Initialization
- (id)   init;
- (void) dealloc;
- (void) awakeFromNib;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark ***Interface Management
- (void) unitsChanged:(NSNotification*)aNote;
- (void) highLimitChanged:(NSNotification*)aNote;
- (void) highAlarmChanged:(NSNotification*)aNote;
- (void) pressureScaleChanged:(NSNotification*)aNote;
- (void) updateTimePlot:(NSNotification*)aNotification;
- (void) scaleAction:(NSNotification*)aNotification;
- (void) shipPressuresChanged:(NSNotification*)aNotification;
- (void) lockChanged:(NSNotification*)aNotification;
- (void) pressureChanged:(NSNotification*)aNotification;
- (void) pollTimeChanged:(NSNotification*)aNotification;
- (void) miscAttributesChanged:(NSNotification*)aNotification;
- (NSString*) pressureValuesForIndex:(int)index;
- (void) tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
- (void) windowDidResize:(NSNotification *)aNote;
- (BOOL) portLocked;

#pragma mark ***Actions
- (IBAction) unitsAction:(id)sender;
- (IBAction) pressureScaleAction:(id)sender;
- (IBAction) shipPressuresAction:(id)sender;
- (IBAction) lockAction:(id) sender;
- (IBAction) readPressuresAction:(id)sender;
- (IBAction) pollTimeAction:(id)sender;

#pragma mark ***Plotter Data Source
- (NSColor*) colorForDataSet:(int)set;
- (int) numberPointsInPlot:(id)aPlotter;
- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue;

#pragma mark ***Pressure Table Data Source
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn 
			 row:(NSInteger) rowIndex;

@end


