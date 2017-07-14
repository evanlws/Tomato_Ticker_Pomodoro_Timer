//
//  TTMenuController.m
//  Tomato Ticker - The Pomodoro Timer
//
//  Created by Evan Lewis on 12/2/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "TTMenuItem.h"
#import "TTMenuController.h"

typedef NS_OPTIONS(NSUInteger, TimerType) {
    workingTime = 1 << 0,
    breakTime = 1 << 1
};

@interface TTMenuController () <NSUserNotificationCenterDelegate>

@property (weak) IBOutlet NSMenu *workMenu;
@property (weak) IBOutlet NSMenu *breakMenu;
@property (weak) IBOutlet NSMenu *longBreakMenu;

@property (nonatomic, strong) NSStatusItem *statusItem;

@property (nonatomic) NSInteger workTime;
@property (nonatomic) NSInteger breakTime;
@property (nonatomic) NSInteger longBreakTime;
@property (nonatomic) NSInteger longBreakCounter;
@property (nonatomic) NSString *breakString;

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSUInteger timerType;
@property (nonatomic) int counter;
@property BOOL timerStarted;

@end

@implementation TTMenuController

- (void)awakeFromNib {
    
    //Status Bar Initialization
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.menu = self;
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
    NSImage *statusBarImage = [NSImage imageNamed:@"clock"];

    self.statusItem.image = statusBarImage;
	self.statusItem.alternateImage = [NSImage imageNamed: @"clock_selected"];
    
    //Set the timers to their default
    [self workMenuItemSelected:(TTMenuItem*)[self.workMenu itemAtIndex:4]];
    [self breakMenuItemSelected:(TTMenuItem*)[self.breakMenu itemAtIndex:0]];
    [self longBreakMenuItemSelected:(TTMenuItem*)[self.longBreakMenu itemAtIndex:2]];
    _longBreakCounter = 0;
    _timerStarted = NO;
    _timerType = workingTime;
    _breakString = @"";
    
}

#pragma mark Timer Methods

- (void)updateTimer {
    
    if (self.counter > 0) {
        int minutes = self.counter/60;
        int seconds = self.counter - (minutes  *60);
        NSString *timerOutput = [NSString stringWithFormat:@"%@%2d:%.2d", self.breakString, minutes, seconds];
        self.statusItem.title = timerOutput;
        self.counter--;
        return;
    }
    [self stopTimer:self];
    switch (self.timerType) {
        case workingTime:
        {
            if (self.breakTime != -1) {
                if (self.longBreakCounter >= 4) {
                    _longBreakCounter = 0;
                    [self startLongBreakTimer];
                    return;
                } else {
                    NSUserNotification *notification = [[NSUserNotification alloc] init];
                    notification.title = @"Time for a break!";
                    notification.soundName = @"TimerDone.aif";
                    
                    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                    [self startBreakTimer];
                    self.longBreakCounter++;
                    return;
                }
            } else {
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                notification.title = @"Timer is done!";
                notification.soundName = @"TimerDone.aif";
                
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            }
        }
            break;
        default:
        {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"Break's over!";
            notification.soundName = @"TimerDone2.aif";
            
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            [self startTimer:self];
            return;
        }
            break;
    }
    
}

- (void)startBreakTimer {
    
    if (!self.timerStarted) {
        _timerStarted = YES;
        self.counter = (int)self.breakTime;
        _timerType = breakTime;
        _breakString = @"B:";
        _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                  target: self
                                                selector:@selector(updateTimer)
                                                userInfo: nil
                                                 repeats:YES];
    }
    
}

- (void)startLongBreakTimer {
    
    if (!self.timerStarted) {
        _timerStarted = YES;
        self.counter = (int)self.longBreakTime;
        _timerType = breakTime;
        _breakString = @"B:";
        _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                  target: self
                                                selector:@selector(updateTimer)
                                                userInfo: nil
                                                 repeats:YES];
    }
    
}

#pragma mark Timer IBActions

- (IBAction)startTimer:(id)sender {
    
    if (!self.timerStarted) {
        _timerStarted = YES;
        self.counter = (int)self.workTime;
        _timerType = workingTime;
        _breakString = @"";
        _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                  target: self
                                                selector:@selector(updateTimer)
                                                userInfo: nil
                                                 repeats:YES];
    }
    
}

- (IBAction)stopTimer:(id)sender {
    
    [self.timer invalidate];
    _timerStarted = NO;
    _timer = nil;
    self.statusItem.title = nil;
    
}

- (IBAction)workMenuItemSelected:(TTMenuItem *)sender {
    _workTime = sender.timeValue + 1;
    for (NSMenuItem *menuItem in [self.workMenu itemArray]) {
        menuItem.state = NSOffState;
    }
    sender.state = NSOnState;
}

- (IBAction)breakMenuItemSelected:(TTMenuItem *)sender {
    _breakTime = sender.timeValue + 1;
    for (NSMenuItem *menuItem in [self.breakMenu itemArray]) {
        menuItem.state = NSOffState;
    }
    sender.state = NSOnState;
}

- (IBAction)longBreakMenuItemSelected:(TTMenuItem *)sender {
    _longBreakTime = sender.timeValue + 1;
    for (NSMenuItem *menuItem in [self.longBreakMenu itemArray]) {
        menuItem.state = NSOffState;
    }
    sender.state = NSOnState;
}

#pragma mark NotificationCenter

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
