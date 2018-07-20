//--------------------------------------------------------
// ORXYScannerModel
// Created by Mark  A. Howe on Fri Jul 22 2005
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
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

#import "ORXYScannerModel.h"
#import "ORSerialPort.h"
#import "ORSerialPortList.h"
#import "ORSerialPort.h"
#import "ORSerialPortAdditions.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"

#pragma mark ***External Strings
NSString* ORXYScannerModelEndEditing        = @"ORXYScannerModelEndEditing";
NSString* ORXYScannerModelMovingChanged     = @"ORXYScannerModelMovingChanged";
NSString* ORXYScannerModelPatternChanged    = @"ORXYScannerModelPatternChanged";
NSString* ORXYScannerModelDwellTimeChanged  = @"ORXYScannerModelDwellTimeChanged";
NSString* ORXYScannerModelOptionMaskChanged = @"ORXYScannerModelOptionMaskChanged";
NSString* ORXYScannerModelPatternTypeChanged= @"ORXYScannerModelPatternTypeChanged";
NSString* ORXYScannerModelCmdFileChanged    = @"ORXYScannerModelCmdFileChanged";
NSString* ORXYScannerModelGoingHomeChanged  = @"ORXYScannerModelGoingHomeChanged";
NSString* ORXYScannerModelAbsMotionChanged  = @"ORXYScannerModelAbsMotionChanged";
NSString* ORXYScannerModelCmdPositionChanged= @"ORXYScannerModelCmdPositionChanged";
NSString* ORXYScannerModelPositionChanged   = @"ORXYScannerModelPositionChanged";
NSString* ORXYScannerModelSerialPortChanged = @"ORXYScannerModelSerialPortChanged";
NSString* ORXYScannerModelPortNameChanged   = @"ORXYScannerModelPortNameChanged";
NSString* ORXYScannerModelPortStateChanged  = @"ORXYScannerModelPortStateChanged";

NSString* ORXYScannerLock = @"ORXYScannerLock";

@interface ORXYScannerModel (private)
- (void) runStarted:(NSNotification*)aNote;
- (void) runStopped:(NSNotification*)aNote;
- (void) startPattern;
- (void) stopPattern;
- (void) continuePattern;
@end

@implementation ORXYScannerModel
- (id) init
{
	self = [super init];
    [self registerNotificationObservers];
	return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [cmdList release];
    [cmdFile release];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [portName release];
    if([serialPort isOpen]){
        [serialPort close];
    }
    [serialPort release];
    [buffer release];
	[super dealloc];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"XYScanner.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORXYScannerController"];
}

- (NSString*) helpURL
{
	return @"Motor_Controllers/Newmark_X_Y.html";
}


- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];

    [notifyCenter addObserver : self
                     selector : @selector(dataReceived:)
                         name : ORSerialPortDataReceived
                       object : nil];

    [notifyCenter addObserver: self
                     selector: @selector(runStarted:)
                         name: ORRunStartedNotification
                       object: nil];
    
    [notifyCenter addObserver: self
                     selector: @selector(runStopped:)
                         name: ORRunStoppedNotification
                       object: nil];

}

- (void) dataReceived:(NSNotification*)note
{
    //NOTE: in order to process the results, echo must be on and all cmds must terminated by a ';'
    if([[note userInfo] objectForKey:@"serialPort"] == serialPort){
        NSString* theString = [[[[NSString alloc] initWithData:[[note userInfo] objectForKey:@"data"] 
                                                    encoding:NSASCIIStringEncoding] autorelease] uppercaseString];
        if(!buffer){
            buffer = [[NSMutableString string] retain];
        }
        theString = [[theString componentsSeparatedByString:@"@"] componentsJoinedByString:@""];
        theString = [[theString componentsSeparatedByString:@"#"] componentsJoinedByString:@""];
        [buffer appendString:theString];
        do {
            NSRange lineRange = [buffer rangeOfString:@";"];
            if(lineRange.location!= NSNotFound){
                NSMutableString* aCmd = [[[buffer substringToIndex:lineRange.location+1] mutableCopy] autorelease];
                [buffer deleteCharactersInRange:NSMakeRange(0,lineRange.location+1)];      //take it out of the buffer
                NSScanner* scanner = [NSScanner scannerWithString:aCmd];
                if([aCmd rangeOfString:@"AA RU"].location!=NSNotFound){
                    NSCharacterSet* numberSet = [NSCharacterSet characterSetWithCharactersInString:@"-+.0123456789"];
                    [scanner scanUpToCharactersFromSet:numberSet  intoString:nil];
                    float xValue,yValue;
                    if([scanner scanFloat:&xValue]) {
                        [scanner scanUpToCharactersFromSet:numberSet  intoString:nil];
                        if([scanner scanFloat:&yValue]) {
                            oldXyPosition = xyPosition;
                            [self setXyPosition:NSMakePoint(xValue,yValue)];
                            if(!NSEqualPoints(oldXyPosition,xyPosition)){
                                [self performSelector:@selector(queryPosition) withObject:nil afterDelay:.3];
                                [self setMoving:YES];
                            }
                            else {
                                if(goingHome){
                                    [serialPort writeString:@"ax lp0 ay lp0;"];
                                    [self setGoingHome:NO];
                                    validTrackCount = 0;
                                    currentTrackIndex = 0;
                                    [self performSelector:@selector(queryPosition) withObject:nil afterDelay:.3];
                                }
                                else [self setMoving:NO];
                            }
                        }
                    }
                }
            }
        } while([buffer rangeOfString:@";"].location!= NSNotFound);
    }
}



- (void) shipMotorState:(BOOL)running
{
    if([[ORGlobal sharedGlobal] runInProgress]){
        if([self optionSet:kXYShipPositionOption]){
            //get the time(UT!)
            time_t	ut_time;
            time(&ut_time);
            //struct tm* theTimeGMTAsStruct = gmtime(&theTime);
            //time_t ut_time = mktime(theTimeGMTAsStruct);
            
            uint32_t data[5];
            data[0] = dataId | 5;
            data[1] = (uint32_t)ut_time;
            data[2] = (running?1:0)<<16 | ([self uniqueIdNumber]&0x0000fffff);
            
            //encode the position 
            union {
                int32_t asLong;
                float asFloat;
            }thePosition;
            thePosition.asFloat = [self xyPosition].x;
            data[3] = thePosition.asLong;
            
            thePosition.asFloat = [self xyPosition].y;
            data[4] = thePosition.asLong;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ORQueueRecordForShippingNotification 
                                                                object:[NSData dataWithBytes:data length:sizeof(int32_t)*5]];
        }
    }
}


#pragma mark ***Accessors

- (NSMutableArray*) cmdList
{
    return cmdList;
}

- (void) setCmdList:(NSMutableArray*)aCmdList
{
    [aCmdList retain];
    [cmdList release];
    cmdList = aCmdList;
}

- (BOOL) moving
{
    return moving;
}

- (void) setMoving:(BOOL)aMoving
{
    if(moving!=aMoving){
        [self shipMotorState:moving];
        moving = aMoving;
        [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelMovingChanged object:self];
    }
}

- (NSPoint) delta
{
    return delta;
}

- (void) setDelta:(NSPoint)aDelta
{
    [[[self undoManager] prepareWithInvocationTarget:self] setDelta:delta];
    
    delta = aDelta;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelPatternChanged object:self];
}

- (uint32_t) optionMask
{
    return optionMask;
}

- (void) setOptionMask:(uint32_t)aOptionMask
{
    [[[self undoManager] prepareWithInvocationTarget:self] setOptionMask:optionMask];
    
    optionMask = aOptionMask;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelOptionMaskChanged object:self];
}
- (void) setOption:(int)anOption 
{
    int32_t aMask = optionMask;
    aMask |= (0x1L<<anOption);
    [self setOptionMask:aMask];
}

- (void) clearOption:(int)anOption 
{
    int32_t aMask = optionMask;
    aMask &= ~(0x1L<<anOption);
    [self setOptionMask:aMask];
}

- (BOOL) optionSet:(int)anOption 
{
    return (optionMask & (0x1L<<anOption))!=0;
}

- (int) patternType
{
    return patternType;
}

- (void) setPatternType:(int)aPatternType
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPatternType:patternType];
    
    patternType = aPatternType;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelPatternTypeChanged object:self];
}


- (float) dwellTime
{
    return dwellTime;
}

- (void) setDwellTime:(float)aDwellTime
{
    [[[self undoManager] prepareWithInvocationTarget:self] setDwellTime:dwellTime];
    
    dwellTime = aDwellTime;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelDwellTimeChanged object:self];
}

- (NSPoint) endPoint
{
    return endPoint;
}

- (void) setEndPoint:(NSPoint)aEnd
{
    [[[self undoManager] prepareWithInvocationTarget:self] setEndPoint:endPoint];
    
    endPoint = aEnd;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelPatternChanged object:self];
}

- (NSPoint) startPoint
{
    return startPoint;
}

- (void) setStartPoint:(NSPoint)aStart
{
    [[[self undoManager] prepareWithInvocationTarget:self] setStartPoint:startPoint];
    
    startPoint = aStart;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelPatternChanged object:self];
}

- (NSString*) cmdFile
{
    return cmdFile;
}

- (void) setCmdFile:(NSString*)aCmdFile
{
    [[[self undoManager] prepareWithInvocationTarget:self] setCmdFile:cmdFile];
    
    [cmdFile autorelease];
    cmdFile = [aCmdFile copy];    

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelCmdFileChanged object:self];
}

- (NSUInteger)currentTrackIndex
{
    return currentTrackIndex;
}

- (NSUInteger)validTrackCount
{
    return validTrackCount;
}

- (NSPoint) track:(NSUInteger)i
{
    if(i<kNumTrackPoints)return track[i];
    else return NSZeroPoint;
}


- (BOOL) goingHome
{
    return goingHome;
}

- (void) setGoingHome:(BOOL)aGoingHome
{
    goingHome = aGoingHome;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelGoingHomeChanged object:self];
}

- (BOOL) absMotion
{
    return absMotion;
}

- (void) setAbsMotion:(BOOL)aAbsMotion
{
    [[[self undoManager] prepareWithInvocationTarget:self] setAbsMotion:absMotion];
    
    absMotion = aAbsMotion;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelAbsMotionChanged object:self];
}

- (NSPoint) cmdPosition
{
    return cmdPosition;
}

- (void) setCmdPosition:(NSPoint)aCmdPosition
{
    [[[self undoManager] prepareWithInvocationTarget:self] setCmdPosition:cmdPosition];
    
    cmdPosition = aCmdPosition;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelCmdPositionChanged object:self];
}


- (NSPoint) xyPosition
{
    return xyPosition;
}

- (void) setXyPosition:(NSPoint)aPosition
{
    if(!NSEqualPoints(xyPosition,aPosition)){
        xyPosition = aPosition;
				
        track[currentTrackIndex] = xyPosition;
        currentTrackIndex  = currentTrackIndex++;
        if(currentTrackIndex>=kNumTrackPoints)currentTrackIndex = 0;
        validTrackCount++;
        if(validTrackCount>kNumTrackPoints)validTrackCount= kNumTrackPoints;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelPositionChanged object:self];
    }
}

- (BOOL) portWasOpen
{
    return portWasOpen;
}

- (void) setPortWasOpen:(BOOL)aPortWasOpen
{
    portWasOpen = aPortWasOpen;
}

- (NSString*) portName
{
    return portName;
}

- (void) setPortName:(NSString*)aPortName
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPortName:portName];
    
    if(![aPortName isEqualToString:portName]){
        [portName autorelease];
        portName = [aPortName copy];    

        BOOL valid = NO;
        NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
        ORSerialPort *aPort;
        while (aPort = [enumerator nextObject]) {
            if([portName isEqualToString:[aPort name]]){
                [self setSerialPort:aPort];
                if(portWasOpen){
                    [self openPort:YES];
                    if([serialPort isOpen]){
                        [serialPort writeString:@"en;"];
                        [self performSelector:@selector(queryPosition) withObject:nil afterDelay:.3];

                    }
                }
                valid = YES;
                break;
            }
        } 
        if(!valid){
            [self setSerialPort:nil];
        }       
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelPortNameChanged object:self];
}

- (ORSerialPort*) serialPort
{
    return serialPort;
}

- (void) setSerialPort:(ORSerialPort*)aSerialPort
{
    [aSerialPort retain];
    [serialPort release];
    serialPort = aSerialPort;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelSerialPortChanged object:self];
}

- (void) openPort:(BOOL)state
{
    if(state) {
        [serialPort open];
        [serialPort setSpeed:9600];
        [serialPort setParityOdd];
        [serialPort setStopBits2:1];
        [serialPort setDataBits:7];
        [serialPort commitChanges];
        [serialPort writeString:@"EN;"]; //turn echo on
    }
    else      [serialPort close];
    portWasOpen = [serialPort isOpen];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORXYScannerModelPortStateChanged object:self];
    
}


#pragma mark ***Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setOptionMask:[decoder decodeIntForKey:@"ORXYScannerModelOptionMask"]];
	[self setPatternType:[decoder decodeIntForKey:@"ORXYScannerModelPatternType"]];
	[self setCmdFile:[decoder decodeObjectForKey:  @"ORXYScannerModelCmdFile"]];
	[self setAbsMotion:[decoder decodeBoolForKey:  @"ORXYScannerModelAbsMotion"]];
	[self setPortWasOpen:[decoder decodeBoolForKey:@"ORXYScannerModelPortWasOpen"]];
    [self setPortName:[decoder decodeObjectForKey: @"portName"]];

	[self setCmdPosition:[decoder decodePointForKey: @"ORXYScannerModelCmdPosition"]];
	[self setDelta:[decoder decodePointForKey:@"ORXYScannerModelDelta"]];
	[self setDwellTime:[decoder decodeFloatForKey:@"ORXYScannerModelDwellPerPoint"]];
	[self setEndPoint:[decoder decodePointForKey:@"ORXYScannerModelEnd"]];
	[self setStartPoint:[decoder decodePointForKey:@"ORXYScannerModelStart"]];
 
	[[self undoManager] enableUndoRegistration];

    [self registerNotificationObservers];

	return self;
}
- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInt:optionMask forKey:@"ORXYScannerModelOptionMask"];
    [encoder encodeInteger:patternType forKey:@"ORXYScannerModelPatternType"];
    [encoder encodeObject:cmdFile forKey:  @"ORXYScannerModelCmdFile"];
    [encoder encodeBool:absMotion forKey:  @"ORXYScannerModelAbsMotion"];
    [encoder encodeBool:portWasOpen forKey:@"ORXYScannerModelPortWasOpen"];
    [encoder encodeObject:portName forKey: @"portName"];


    [encoder encodePoint:cmdPosition forKey: @"ORXYScannerModelCmdPosition"];
    [encoder encodePoint:delta forKey:@"ORXYScannerModelDelta"];
    [encoder encodeFloat:dwellTime forKey:@"ORXYScannerModelDwellPerPoint"];
    [encoder encodePoint:endPoint forKey:@"ORXYScannerModelEnd"];
    [encoder encodePoint:startPoint forKey:@"ORXYScannerModelStart"];
}

#pragma mark ***Motor Commands
- (void) queryPosition
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(queryPosition) object:nil];
    if([serialPort isOpen]){
        [serialPort writeString:@"en;aa ru;"];
    }
}
- (void) goHome
{
    if([serialPort isOpen]){
        [self setGoingHome:YES];
        [serialPort writeString:@"sa;"];
        [serialPort writeString:@"ax vl10000 hh hm vl1000 hl hr0;"];
        [serialPort writeString:@"ay vl10000 hh hm vl1000 hl hr0;"];
        [self performSelector:@selector(queryPosition) withObject:nil afterDelay:.3];

    }
}

- (void) stopMotion
{
    if([serialPort isOpen]){
        [serialPort writeString:@"sa;"];
        [self performSelector:@selector(queryPosition) withObject:nil afterDelay:.3];

    }
}

- (void) go
{
    if([serialPort isOpen]){
        [self resetTrack];
        
        if(absMotion) [self moveToPoint:NSMakePoint(cmdPosition.x,cmdPosition.y)];
        else          [self move:NSMakePoint(cmdPosition.x,cmdPosition.y)];
    }
}

- (void) moveToPoint:(NSPoint)aPoint
{
    if([serialPort isOpen]){        
        [serialPort writeString:[NSString stringWithFormat:@"aa mt%f,%f go;",aPoint.x,aPoint.y]];
        [self performSelector:@selector(queryPosition) withObject:nil afterDelay:.3];

    }
}

- (void) move:(NSPoint)amount
{
    if([serialPort isOpen]){        
        [serialPort writeString:[NSString stringWithFormat:@"aa ml%f,%f go;",amount.x,amount.y]];
        [self performSelector:@selector(queryPosition) withObject:nil afterDelay:.3];

    }
}

- (void) sendCmd:(NSString*)aCmd
{
    if([serialPort isOpen]){        
        [serialPort writeString:aCmd];
        [self performSelector:@selector(queryPosition) withObject:nil afterDelay:.3];

    }
}


- (void) resetTrack
{
    currentTrackIndex = 0;
    validTrackCount   = 0;
    oldXyPosition = NSMakePoint(-1,-1);
}

- (void) runCmdFile
{
    if([serialPort isOpen]){
        [self resetTrack];
        NSData* theCmdData = [NSData dataWithContentsOfFile:[cmdFile stringByExpandingTildeInPath]];
        NSString* theCmdString = [[[NSString alloc] initWithData:theCmdData encoding:NSASCIIStringEncoding] autorelease];
        [serialPort writeString:theCmdString];
        [serialPort writeString:@";"];
        [self performSelector:@selector(queryPosition) withObject:nil afterDelay:.3];

    }
}


#pragma mark ***Data Records
- (uint32_t) dataId { return dataId; }
- (void) setDataId: (uint32_t) DataId
{
    dataId = DataId;
}
- (void) setDataIds:(id)assigner
{
    dataId       = [assigner assignDataIds:kLongForm];
}

- (void) syncDataIdsWith:(id)anotherXYScanner
{
    [self setDataId:[anotherXYScanner dataId]];
}

- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(NSDictionary*)userInfo
{
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"XYScannerModel"];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        @"ORXYScannerDecoderForPosition",   @"decoder",
        [NSNumber numberWithLong:dataId],   @"dataId",
        [NSNumber numberWithBool:NO],       @"variable",
        [NSNumber numberWithLong:5],        @"length",
        nil];
    [dataDictionary setObject:aDictionary forKey:@"Position"];
    
    return dataDictionary;
}

@end

@implementation ORXYScannerModel (private)

- (void) runStarted:(NSNotification*)aNote
{

    [[NSNotificationCenter defaultCenter]
        postNotificationName:ORXYScannerModelEndEditing
                      object:self];

    if([self optionSet:kXYSyncWithRunOption]){
        if([serialPort isOpen]){
            [self startPattern];
        }
        else {
            [self openPort:YES];
            if([serialPort isOpen]){
                [self startPattern];
            }
            else {
                //couldn't open port...stop the run.
                NSString* reason = [NSString stringWithFormat:@"XYScanner %u port could not be opened",[self  uniqueIdNumber]];
                
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:ORRequestRunHalt
                                  object:self
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:reason,@"Reason",nil]];
              }
        }
    }
}

- (void) runStopped:(NSNotification*)aNote
{
    if([self optionSet:kXYSyncWithRunOption]){
        [self stopPattern];
    }
}

- (void) startPattern
{
    if([serialPort isOpen]){
        if(!cmdList)[self setCmdList:[NSMutableArray array]];
        else [cmdList removeAllObjects];
        float x,y;
        if(patternType == kXYUseFile){
            NSString* fullPath = [cmdFile stringByExpandingTildeInPath];
            if([[NSFileManager defaultManager] fileExistsAtPath:fullPath]){
                NSString* contents = [NSString stringWithContentsOfFile:fullPath encoding:NSASCIIStringEncoding error:nil];
                contents = [[contents componentsSeparatedByString:@"\r"] componentsJoinedByString:@"\n"];
                contents = [[contents componentsSeparatedByString:@"\n\n"] componentsJoinedByString:@"\n"];
                [self setCmdList:[[[contents componentsSeparatedByString:@"\n"] mutableCopy] autorelease]];
            }
        }
        else if(patternType == kXYRaster){
            for(y=startPoint.y;y<=endPoint.y;y+=delta.y){
                for(x=startPoint.x;x<=endPoint.x;x+=delta.x){
                    [cmdList addObject:[NSString stringWithFormat:@"aa mt%f,%f go;",x,y]];
                }
            }
        }
        else {
            int sign = -1;
            float startx = startPoint.x;
            float endx   = endPoint.x;
            for(y=startPoint.y;y<=endPoint.y;y+=delta.y){
                //toggle the direction
                if(sign == -1) sign = 1;
                else sign = -1;
                if(sign == 1){
                    for(x=startx;x<=endx;x+=delta.x){
                        [cmdList addObject:[NSString stringWithFormat:@"aa mt%f,%f go;",x,y]];
                    }
                }
                else {
                    for(x=endx;x>=startx;x-=delta.x){
                        [cmdList addObject:[NSString stringWithFormat:@"aa mt%f,%f go;",x,y]];
                    }
                }
            }
        }
    }  
    
    if([cmdList count]){
        dwelling = NO;
        firstPosition = YES;
        [self performSelector:@selector(continuePattern) withObject:nil afterDelay:.1];
    }
    else {
        NSString* reason = [NSString stringWithFormat:@"XYScanner %u is synced to run but has no valid commands",[self  uniqueIdNumber]];

        [[NSNotificationCenter defaultCenter]
            postNotificationName:ORRequestRunHalt
                          object:self
                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:reason,@"Reason",nil]];
    }
}

- (void) stopPattern
{
    if([serialPort isOpen]){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(continuePattern) object:nil];
        [self goHome];
    }
}

 
- (void) continuePattern
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(continuePattern) object:nil];

    if(![self moving]){
        if(!dwelling){
            dwelling = YES;
            waitingStartTime = [NSDate timeIntervalSinceReferenceDate];
        }
        else {
            if(firstPosition || [NSDate timeIntervalSinceReferenceDate] - waitingStartTime > dwellTime){
                firstPosition = NO;
                if([cmdList count]){
                    [self sendCmd:[cmdList objectAtIndex:0]];
                    [cmdList removeObjectAtIndex:0];    
                    dwelling = NO;
                }
                else {
                    if([self optionSet:kXYStopRunOption]){
                            NSString* reason = [NSString stringWithFormat:@"XYScanner %u port finished pattern",[self  uniqueIdNumber]];
                            
                            [[NSNotificationCenter defaultCenter]
                                postNotificationName:ORRequestRunHalt
                                              object:self
                                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:reason,@"Reason",nil]];
                        
                    }
                    return;
                }
            }
        }
    }
    [self performSelector:@selector(continuePattern) withObject:nil afterDelay:.1];    
}

@end
