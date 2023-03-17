//
//  ViewController.m
//  Safely
//
//  Created by Kendall Toerner on 8/8/20.
//  Copyright © 2020 Kendall Toerner. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WatchdogUser.h"
#import "CustomCalloutView.h"
@import Mapbox;
@import UIKit;
@import MapKit;
@import CloudKit;

//------------------------------------------

// MGLAnnotationView subclass
@interface CustomAnnotationView : MGLAnnotationView
@end

@implementation CustomAnnotationView

UIImageView *img;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Force the annotation view to maintain a constant size when the map is tilted.
    self.scalesWithViewingDistance = false;
    
    // Use CALayer’s corner radius to turn this view into a circle.
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor;
    self.layer.opacity = 1;
    
    self.layer.shadowOpacity = 0;
    self.layer.shadowRadius = 1;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    CABasicAnimation *animation_borderwidth = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    animation_borderwidth.duration = 0.2;
    self.layer.borderWidth = selected ? 1 : 2;
    [self.layer addAnimation:animation_borderwidth forKey:@"borderWidth"];
    
    CABasicAnimation *animation_opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation_opacity.duration = 0.2;
    self.layer.opacity = selected ? 1 : 1;
    [self.layer addAnimation:animation_opacity forKey:@"opacity"];
}

- (void)setImage:(UIImage*)image
{
    img = [[UIImageView alloc] initWithImage:image];
    img.layer.masksToBounds = YES;
    img.layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    img.layer.cornerRadius = self.frame.size.width / 2;
    [self addSubview:img];
}

@end

//------------------------------------------

//Main View Controller Class
@interface ViewController () <MGLMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, FBSDKLoginButtonDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *map;

@end

@implementation ViewController

//@synthesize map;

/* MAP */
MGLMapView *map;
CGRect map_frame;

UIButton *followlocationbutton;
CGRect followlocationbutton_frame;

UIImageView *followlocationicon;

/* MENU */
UIView *menu;
CGRect menu_frame;
CGRect menu_frame_open;

UIView *menushade;
CGRect menushade_frame;

UILabel *menulabel;
CGRect menulabel_frame;

UIImageView *menuarrow;
CGRect menuarrow_frame;
CGRect menuarrow_frame_open;

/* MENU BUTTONS */

UIButton *sharingbutton;
CGRect sharingbutton_frame_hidden;
CGRect sharingbutton_frame_visible;
UILabel *sharingbuttonlabel;

UIButton *safetybutton;
CGRect safetybutton_frame_hidden;
CGRect safetybutton_frame_visible;
UILabel *safetybuttonlabel;

UIButton *guardbutton;
CGRect guardbutton_frame_hidden;
CGRect guardbutton_frame_visible;
UILabel *guardbuttonlabel;

/* OPTIONS MENU */
UIView *optionsmenu;
CGRect optionsmenu_frame;
CGRect optionsmenu_frame_open;

UILabel *optionslabel;
CGRect optionslabel_frame;
CGRect optionslabel_frame_open;

UIImageView *optionsarrow;
CGRect optionsarrow_frame;
CGRect optionsarrow_frame_open;

UISwitch *sharelocationswitch;
CGRect sharelocationswitch_frame;

UILabel *sharelocationswitchlabel;
CGRect sharelocationswitchlabel_frame;

UILabel *friendslisttitlelabel;
CGRect friendslisttitlelabel_frame;

UITableView *friendslist;
CGRect friendslist_frame;

FBSDKLoginButton *logoutButton;
CGRect logoutButton_frame;

/* LOGIN */
UILabel *watchdoglabel;
CGRect watchdoglabel_frame;

UILabel *startupLabel;
CGRect startuplabel_frame;

UIView *loginmask;
CGRect loginmask_frame;

FBSDKLoginButton *loginButton;
CGRect loginButton_frame;

UITextField *usernameTextfield;
CGRect usernameTextfield_frame;

UIButton *chooseUsernameButton;
CGRect chooseUsernameButton_frame;

UILabel *chooseUsernameButtonLabel;

/* LAUNCH */
UIView *launchmask;
CGRect launchmask_frame;

UIImageView *launchicon;
CGRect launchicon_frame;

UIActivityIndicatorView *loadingspinner;
CGRect loadingspinner_frame;

UILabel *launcherrorlabel;
CGRect launcherrorlabel_frame;

/* LOADING */
UIView *loadingmask;
CGRect loadingmask_frame;

UILabel *loadingmasklabel;
CGRect loadingmasklabel_frame;

UIActivityIndicatorView *loadingmaskspinner;
CGRect loadingmaskspinner_frame;

/* TOUBLE */
UIVisualEffectView *troublemask;
CGRect troublemask_frame;

/* FRIENDS */
UIView *friendsmask;
UIVisualEffectView *friendsmaskeffect;
UIVisualEffectView *addfriendsmaskeffect;
UIButton *friendsbutton;
UISegmentedControl *friendstype;
UIButton *friendsclosebutton;
UITableView *friendslistedit;
UIButton *friendsoption1button;
UIButton *friendsoption2button;
UIView *addfriendmask;
UILabel *addfriendmask_label;
UITextField *addfriendmask_textbox;
UIButton *addfriendmask_addbutton;
UIButton *addfriendmask_cancelbutton;
CGRect friendsmask_frame;
CGRect friendsbutton_frame;
CGRect friendstype_frame;
CGRect friendsclosebutton_frame;
CGRect friendslistedit_frame;
CGRect friendsoption1button_frame;
CGRect friendsoption2button_frame;
CGRect addfriendmask_label_frame;
CGRect addfriendmask_textbox_frame;
CGRect addfriendmask_addbutton_frame;
CGRect addfriendmask_cancelbutton_frame;

/* MESSAGEBOX */
UIVisualEffectView *blurEffectView;
UIView *blurEffectReplacementView;
UIView *messagebox;
UILabel *messagebox_title;
UILabel *messagebox_description;
UIButton *messagebox_button;
UILabel *messagebox_buttonlabel;
UIButton *messagebox_yesbutton;
UILabel *messagebox_yesbuttonlabel;
UIButton *messagebox_nobutton;
UILabel *messagebox_nobuttonlabel;
CGRect messagebox_defaultframe;
CGRect messagebox_lowerdefaultframe;
CGRect messagebox_upperdefaultframe;
CGRect messagebox_title_defaultframe;
CGRect messagebox_title_lowerdefaultframe;
CGRect messagebox_title_upperdefaultframe;
CGRect messagebox_description_defaultframe;
CGRect messagebox_description_lowerdefaultframe;
CGRect messagebox_description_upperdefaultframe;
CGRect messagebox_button_defaultframe;
CGRect messagebox_button_lowerdefaultframe;
CGRect messagebox_button_upperdefaultframe;
CGRect messagebox_buttonlabel_defaultframe;
CGRect messagebox_buttonlabel_lowerdefaultframe;
CGRect messagebox_buttonlabel_upperdefaultframe;
CGRect messagebox_yesbutton_defaultframe;
CGRect messagebox_yesbutton_lowerdefaultframe;
CGRect messagebox_yesbutton_upperdefaultframe;
CGRect messagebox_yesbuttonlabel_defaultframe;
CGRect messagebox_yesbuttonlabel_lowerdefaultframe;
CGRect messagebox_yesbuttonlabel_upperdefaultframe;
CGRect messagebox_nobutton_defaultframe;
CGRect messagebox_nobutton_lowerdefaultframe;
CGRect messagebox_nobutton_upperdefaultframe;
CGRect messagebox_nobuttonlabel_defaultframe;
CGRect messagebox_nobuttonlabel_lowerdefaultframe;
CGRect messagebox_nobuttonlabel_upperdefaultframe;


//Debug switches
bool launcherrorlabel_hidden = false;


//Variables
int fullwidth;
int fullheight;
int halfwidth;
int halfheight;
int fontsize = 35;

int optionsfullwidth;
int optionsfullheight;
int optionshalfwidth;
int optionshalfheight;

bool menuopen = false;
bool optionsopen = false;
bool switchingmenus = false;
bool renamingfriends = false;
bool editingfriends = false;
bool messageboxhidden = true;
bool changingmodes = false;
bool revealoptions = false;

NSString *messageboxresponse = @"";

int watchdogmode = 0;
bool sharingbegan = false;



//Gestures
UITapGestureRecognizer *shadeTapRecognizer;
UISwipeGestureRecognizer *shadeSwipeUpRecognizer;
UISwipeGestureRecognizer *shadeSwipeDownRecognizer;

UITapGestureRecognizer *menuTapRecognizer;
UISwipeGestureRecognizer *menuSwipeUpRecognizer;
UISwipeGestureRecognizer *menuSwipeDownRecognizer;

UITapGestureRecognizer *optionsTapRecognizer;
UISwipeGestureRecognizer *optionsSwipeUpRecognizer;
UISwipeGestureRecognizer *optionsSwipeDownRecognizer;

UILongPressGestureRecognizer *longPressGestureRecognizer;
UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
UISwipeGestureRecognizer *swipeRightGestureRecognizer;



//Objects
NSUserDefaults *defaults;
dispatch_group_t ldg;

//Local UI Property Objects
UIColor *themecolor;

//Map Objects
CLLocationManager *locationManager;
MGLPolygon *circlepoly;

//Timers
NSTimer *updatefriendsliststimer;
NSTimer *updatelocationtimer;
NSTimer *updatefriendslocationstimer;
NSTimer *retryLoginTimer;
NSTimer *loadingtimer;
NSTimer *selectedfriendsupdatetimer;

//Facebook Variables
bool isLoggedIn = false;

//CloudKit Variables
CKRecord *userrecord;
WatchdogUser *user;
NSString *facebookid = @"";

NSMutableArray *friends;
NSMutableArray *friendsnames;
NSMutableArray *friendoutrequests;
NSMutableArray *friendinrequests;
NSMutableArray *friendsmodes;
NSMutableArray *friendslocations;
NSMutableArray *friendspictures;
NSMutableArray *blockedusers;
NSMutableArray *guards;
bool selectedfriends[200][3];
bool selectedfriendsedit[200];
bool selectedrequests[200];

NSString *subscriptionid = @"";
bool userrecordupdating = false;




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self firstInits];
    
    [self frameUI];
    
    [self makeUI];
    
    [self finalInits];
}

- (void)firstInits
{
    //User Defaults
    defaults = [NSUserDefaults standardUserDefaults];
    
    //Define Variables
    fullwidth = self.view.frame.size.width;
    fullheight = self.view.frame.size.height;
    halfwidth = self.view.frame.size.width/2;
    halfheight = self.view.frame.size.height/2;
    
    //Get device type and optimize UI settings
    double screenheight = [[UIScreen mainScreen] bounds].size.height;
    fontsize = 32*(screenheight/736);
    
    optionsfullwidth = fullwidth-(fullwidth*.075);
    optionsfullheight = fullheight*.75;
    optionshalfwidth = optionsfullwidth/2;
    optionshalfheight = optionsfullheight/2;
    
    themecolor = [UIColor colorWithRed:0 green:0.7 blue:1 alpha:1];
    
    //Initialized Lists
    friends = [[NSMutableArray alloc] init];
    friendsnames = [[NSMutableArray alloc] init];
    friendsmodes = [[NSMutableArray alloc] init];
    friendspictures = [[NSMutableArray alloc] init];
    friendinrequests = [[NSMutableArray alloc] init];
    friendoutrequests = [[NSMutableArray alloc] init];
    blockedusers = [[NSMutableArray alloc] init];
    guards = [[NSMutableArray alloc] init];
    
    //Set Delegates
    map.delegate = self;
    
    //Initialize location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    //Map type
    //map.mapType = MKMapTypeHybrid;
    
    //Launch Dispatch Group (manage async requests)
    ldg = dispatch_group_create();
    
    //Initialize gestures
    shadeTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadeTapGesture:)];
    shadeSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(shadeSwipeUpGesture:)];
    shadeSwipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(shadeSwipeDownGesture:)];
    
    menuTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapGesture:)];
    menuSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(menuSwipeUpGesture:)];
    menuSwipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(menuSwipeDownGesture:)];
    
    optionsTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionsTapGesture:)];
    optionsSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(optionsSwipeUpGesture:)];
    optionsSwipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(optionsSwipeDownGesture:)];
    [optionsTapRecognizer setCancelsTouchesInView:NO];
    
    shadeSwipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    shadeSwipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    menuSwipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    menuSwipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    optionsSwipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    optionsSwipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleLeftSwipeGesture:)];
    swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleRightSwipeGesture:)];
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleLongPressGesture:)];
    
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
}

- (void)frameUI
{
    //Map
    map_frame = CGRectMake(0, 0, fullwidth, fullheight);
    
    followlocationbutton_frame = CGRectMake(fullwidth*.8, fullheight*.8, fullwidth*.142, fullheight*.08);
    
    //Menu
    menu_frame = CGRectMake(halfwidth-(fullwidth*.7/2), fullheight*0.05, fullwidth*.7, fullheight*.1);
    menu_frame_open = CGRectMake(halfwidth-(fullwidth*.7/2), fullheight*0.05, fullwidth*.7, fullheight*.45);
    
    menushade_frame = CGRectMake(0, 0, fullwidth, fullheight);
    
    menulabel_frame = CGRectMake(halfwidth-(fullwidth*.7/2), fullheight*0.045, fullwidth*.7, fullheight*.1);
    
    menuarrow_frame = CGRectMake(halfwidth-(fullwidth*.05/2), fullheight*0.125, fullwidth*.05, fullheight*.012);
    menuarrow_frame_open = CGRectMake(halfwidth-(fullwidth*.05/2), fullheight*0.46, fullwidth*.05, fullheight*.012);
    
    //Menu Buttons
    sharingbutton_frame_hidden = CGRectMake(halfwidth-(fullwidth*.5/2), fullheight*.1, fullwidth*.5, fullheight*.08);
    sharingbutton_frame_visible = CGRectMake(halfwidth-(fullwidth*.5/2), fullheight*.15, fullwidth*.5, fullheight*.08);
    
    safetybutton_frame_hidden = CGRectMake(halfwidth-(fullwidth*.5/2), fullheight*.1, fullwidth*.5, fullheight*.08);
    safetybutton_frame_visible = CGRectMake(halfwidth-(fullwidth*.5/2), fullheight*.25, fullwidth*.5, fullheight*.08);
    
    guardbutton_frame_hidden = CGRectMake(halfwidth-(fullwidth*.5/2), fullheight*.1, fullwidth*.5, fullheight*.08);
    guardbutton_frame_visible = CGRectMake(halfwidth-(fullwidth*.5/2), fullheight*.35, fullwidth*.5, fullheight*.08);
    
    //Options Menu
    optionsmenu_frame = CGRectMake(fullwidth*.0375, fullheight*.9, fullwidth*.925, fullheight*.2);
    optionsmenu_frame_open = CGRectMake(fullwidth*.0375, fullheight*.25, fullwidth*.925, fullheight);
    
    optionslabel_frame = CGRectMake(fullwidth*.0375, fullheight*.9, fullwidth*.925, fullheight*.1);
    optionslabel_frame_open = CGRectMake(fullwidth*.0375, fullheight*.26, fullwidth*.925, fullheight*.1);
    
    optionsarrow_frame = CGRectMake(halfwidth-(fullwidth*.05/2), fullheight*0.91, fullwidth*.05, fullheight*.012);
    optionsarrow_frame_open = CGRectMake(halfwidth-(fullwidth*.05/2), fullheight*0.26, fullwidth*.05, fullheight*.012);
    
    friendslisttitlelabel_frame = CGRectMake(0, optionsfullheight*.15, optionsfullwidth, optionsfullheight*.05);
    
    friendslist_frame = CGRectMake(optionsfullwidth*.1, optionsfullheight*.22, optionsfullwidth*.8, optionsfullheight*.3);
    
    sharelocationswitchlabel_frame = CGRectMake(0, optionsfullheight*.67, optionsfullwidth*.825, optionsfullheight*.05);
    
    sharelocationswitch_frame = CGRectMake(optionsfullwidth*.65, optionsfullheight*.67, 30, 15);
    
    logoutButton_frame = CGRectMake(optionshalfwidth-(logoutButton.frame.size.width/2), optionsfullheight*0.93, logoutButton.frame.size.width, logoutButton.frame.size.height);
    
    //Login
    watchdoglabel_frame = CGRectMake(0, fullheight*.03, fullwidth, fullheight*0.2);
    
    startuplabel_frame = CGRectMake(fullwidth*.1, fullheight*.2, fullwidth*.8, fullheight*0.5);
    
    loginmask_frame = CGRectMake(0, 0, fullwidth, fullheight);
    
    loginButton_frame = CGRectMake(halfwidth-(loginButton.frame.size.width/2), fullheight*0.93, loginButton.frame.size.width, loginButton.frame.size.height);
    
    usernameTextfield_frame = CGRectMake(halfwidth-(fullwidth*.8/2), fullheight*.35, fullwidth*.8, fullheight*.075);
    
    chooseUsernameButton_frame = CGRectMake(halfwidth-(fullwidth*.6/2), fullheight*.5, fullwidth*.6, fullheight*.08);
    
    //Launch
    launchmask_frame = CGRectMake(0, 0, fullwidth, fullheight);

    launchicon_frame = CGRectMake(fullwidth-19-210,fullheight-29-210,210,210);
    
    loadingspinner_frame = CGRectMake(halfwidth-10, halfheight-10, 20, 20);
    
    launcherrorlabel_frame = CGRectMake(0, fullheight*.4, fullwidth, fullheight*0.1);
    
    //Loading
    loadingmask_frame = CGRectMake(halfwidth-(fullwidth*.4/2), halfheight-(fullheight*.2/2), fullwidth*.4, fullheight*.2);
    loadingmasklabel_frame = CGRectMake(0, fullheight*.02, fullwidth*.4, fullheight*.05);
    loadingmaskspinner_frame = CGRectMake((fullwidth*.2)-18.5, (fullheight*.15)-37, 37, 37);
    
    //Trouble
    troublemask_frame = CGRectMake(0, 0, fullwidth, fullheight);
    
    //Friends
    friendsmask_frame = CGRectMake(0, 0, fullwidth, fullheight);
    friendsbutton_frame = CGRectMake(optionshalfwidth-(optionsfullwidth*.8/2), optionsfullheight*0.54, optionsfullwidth*.8, optionsfullheight*.07);
    friendstype_frame = CGRectMake(halfwidth-(fullwidth*.8/2), fullheight*0.075, fullwidth*.8, fullheight*.05);
    friendsclosebutton_frame = CGRectMake(halfwidth-(fullwidth*.8/2), fullheight*0.9, fullwidth*.8, fullheight*.05);
    friendslistedit_frame = CGRectMake(halfwidth-(fullwidth*0.8/2), fullheight*.2, fullwidth*.8, fullheight*.5);
    friendsoption1button_frame = CGRectMake(halfwidth-(fullwidth*.8/2), fullheight*0.71, fullwidth*.8, fullheight*.05);
    friendsoption2button_frame = CGRectMake(halfwidth-(fullwidth*.8/2), fullheight*0.77, fullwidth*.8, fullheight*.05);
    addfriendmask_label_frame = CGRectMake(0, fullheight*0.3, fullwidth, fullheight*.1);
    addfriendmask_textbox_frame = CGRectMake(halfwidth-(fullwidth*.5/2), fullheight*0.41, fullwidth*.5, fullheight*.05);
    addfriendmask_addbutton_frame = CGRectMake(halfwidth-(fullwidth*.5/2), fullheight*0.5, fullwidth*.5, fullheight*.05);
    addfriendmask_cancelbutton_frame = CGRectMake(halfwidth-(fullwidth*.5/2), fullheight*0.56, fullwidth*.5, fullheight*.05);
    
    //Messagebox
    messagebox_defaultframe = CGRectMake(fullwidth*0.1, (fullheight*0.35), fullwidth*0.8, fullheight*0.3);
    messagebox_lowerdefaultframe = CGRectMake(fullwidth*0.1, (fullheight*0.35)+50, fullwidth*0.8, fullheight*0.3);
    messagebox_upperdefaultframe = CGRectMake(fullwidth*0.1, (fullheight*0.35)-50, fullwidth*0.8, fullheight*0.3);
    
    messagebox_title_defaultframe = CGRectMake(fullwidth*0.1, (fullheight*0.345), fullwidth*0.8, fullheight*0.08);
    messagebox_title_lowerdefaultframe = CGRectMake(fullwidth*0.1, (fullheight*0.345)+50, fullwidth*0.8, fullheight*0.08);
    messagebox_title_upperdefaultframe = CGRectMake(fullwidth*0.1, (fullheight*0.345)-50, fullwidth*0.8, fullheight*0.08);
    
    messagebox_description_defaultframe = CGRectMake(fullwidth*0.15, (fullheight*0.4), fullwidth*0.7, fullheight*0.17);
    messagebox_description_lowerdefaultframe = CGRectMake(fullwidth*0.15, (fullheight*0.4)+50, fullwidth*0.7, fullheight*0.17);
    messagebox_description_upperdefaultframe = CGRectMake(fullwidth*0.15, (fullheight*0.4)-50, fullwidth*0.7, fullheight*0.17);
    
    messagebox_button_defaultframe = CGRectMake(fullwidth*0.115, (fullheight*0.57), fullwidth*0.77, fullheight*0.069);
    messagebox_button_lowerdefaultframe = CGRectMake(fullwidth*0.115, (fullheight*0.57)+50, fullwidth*0.77, fullheight*0.069);
    messagebox_button_upperdefaultframe = CGRectMake(fullwidth*0.115, (fullheight*0.57)-50, fullwidth*0.77, fullheight*0.069);
    
    messagebox_buttonlabel_defaultframe = CGRectMake(fullwidth*0.115, (fullheight*0.57), fullwidth*0.77, fullheight*0.069);
    messagebox_buttonlabel_lowerdefaultframe = CGRectMake(fullwidth*0.115, (fullheight*0.57)+50, fullwidth*0.77, fullheight*0.069);
    messagebox_buttonlabel_upperdefaultframe = CGRectMake(fullwidth*0.115, (fullheight*0.57)-50, fullwidth*0.77, fullheight*0.069);
    
    messagebox_yesbutton_defaultframe = CGRectMake(fullwidth*0.11, (fullheight*0.57), fullwidth*0.385, fullheight*0.069);
    messagebox_yesbutton_lowerdefaultframe = CGRectMake(fullwidth*0.11, (fullheight*0.57)+50, fullwidth*0.385, fullheight*0.069);
    messagebox_yesbutton_upperdefaultframe = CGRectMake(fullwidth*0.11, (fullheight*0.57)-50, fullwidth*0.385, fullheight*0.069);
    
    messagebox_yesbuttonlabel_defaultframe = CGRectMake(fullwidth*0.11, (fullheight*0.57), fullwidth*0.385, fullheight*0.069);
    messagebox_yesbuttonlabel_lowerdefaultframe = CGRectMake(fullwidth*0.11, (fullheight*0.57)+50, fullwidth*0.385, fullheight*0.069);
    messagebox_yesbuttonlabel_upperdefaultframe = CGRectMake(fullwidth*0.11, (fullheight*0.57)-50, fullwidth*0.385, fullheight*0.069);
    
    messagebox_nobutton_defaultframe = CGRectMake(fullwidth*0.505, (fullheight*0.57), fullwidth*0.385, fullheight*0.069);
    messagebox_nobutton_lowerdefaultframe = CGRectMake(fullwidth*0.505, (fullheight*0.57)+50, fullwidth*0.385, fullheight*0.069);
    messagebox_nobutton_upperdefaultframe = CGRectMake(fullwidth*0.505, (fullheight*0.57)-50, fullwidth*0.385, fullheight*0.069);
    
    messagebox_nobuttonlabel_defaultframe = CGRectMake(fullwidth*0.505, (fullheight*0.57), fullwidth*0.385, fullheight*0.069);
    messagebox_nobuttonlabel_lowerdefaultframe = CGRectMake(fullwidth*0.505, (fullheight*0.57)+50, fullwidth*0.385, fullheight*0.069);
    messagebox_nobuttonlabel_upperdefaultframe = CGRectMake(fullwidth*0.505, (fullheight*0.57)-50, fullwidth*0.385, fullheight*0.069);
}

- (void)makeUI
{
    //Map
    
    NSURL *styleURL = [NSURL URLWithString:@"mapbox://styles/krt72012/ciog6lewo0008abnnf77146fq"];
    
    map = [[MGLMapView alloc] initWithFrame:map_frame styleURL:styleURL];
    map.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //map.styleURL = [MGLStyle darkStyleURLWithVersion:9];
    //map.tintColor = [UIColor lightGrayColor];
    //map.centerCoordinate = CLLocationCoordinate2DMake(0, 66);
    //map.zoomLevel = 2;
    map.delegate = self;
    map.rotateEnabled = false;
    [self.view addSubview:map];
    
    followlocationbutton = [[UIButton alloc] initWithFrame:followlocationbutton_frame];
    followlocationbutton.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    followlocationbutton.alpha = 0;
    followlocationbutton.layer.cornerRadius = fullheight*.0415;
    [followlocationbutton addTarget:self action:@selector(universalbutton_down:) forControlEvents:UIControlEventTouchUpInside];
    [followlocationbutton addTarget:self action:@selector(followlocationbutton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [map addSubview:followlocationbutton];
    
    followlocationicon = [[UIImageView alloc] initWithFrame:followlocationbutton_frame];
    followlocationicon.image = [UIImage imageNamed:@"followlocationicon.png"];
    followlocationicon.alpha = 0;
    [map addSubview:followlocationicon];
    
    //Menu
    menushade = [[UIView alloc] initWithFrame:menushade_frame];
    menushade.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    menushade.alpha = 0;
    [self.view addSubview:menushade];
    
    menu = [[UIView alloc] initWithFrame:menu_frame];
    menu.backgroundColor = themecolor;
    menu.alpha = 0.9;
    menu.layer.cornerRadius = fullheight*0.05;
    [self.view addSubview:menu];
    
    menulabel = [[UILabel alloc] initWithFrame:menulabel_frame];
    menulabel.text = @"Sharing";
    menulabel.textAlignment = NSTextAlignmentCenter;
    menulabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize];
    menulabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    menulabel.alpha = 1;
    menulabel.numberOfLines = 1;
    [self.view addSubview:menulabel];
    
    menuarrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowdown.png"]];
    menuarrow.frame = menuarrow_frame;
    menuarrow.alpha = 1;
    [self.view addSubview:menuarrow];
    
    //Menu Buttons
    sharingbutton = [[UIButton alloc] initWithFrame:sharingbutton_frame_hidden];
    sharingbutton.backgroundColor = [UIColor colorWithRed:0 green:0.93 blue:1 alpha:1];
    sharingbutton.alpha = 0;
    sharingbutton.layer.cornerRadius = fullheight*0.04;
    [sharingbutton addTarget:self action:@selector(sharingbutton_down:) forControlEvents:UIControlEventTouchDown];
    [sharingbutton addTarget:self action:@selector(sharingbutton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sharingbutton];
    sharingbuttonlabel = [[UILabel alloc] initWithFrame:sharingbutton_frame_hidden];
    sharingbuttonlabel.text = @"Sharing";
    sharingbuttonlabel.textAlignment = NSTextAlignmentCenter;
    sharingbuttonlabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-5];
    sharingbuttonlabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    sharingbuttonlabel.alpha = 0;
    [self.view addSubview:sharingbuttonlabel];
    
    safetybutton = [[UIButton alloc] initWithFrame:safetybutton_frame_hidden];
    safetybutton.backgroundColor = [UIColor colorWithRed:.05 green:0.78 blue:1 alpha:1];
    safetybutton.alpha = 0;
    safetybutton.layer.cornerRadius = fullheight*0.04;
    [safetybutton addTarget:self action:@selector(safetybutton_down:) forControlEvents:UIControlEventTouchDown];
    [safetybutton addTarget:self action:@selector(safetybutton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:safetybutton];
    safetybuttonlabel = [[UILabel alloc] initWithFrame:safetybutton_frame_hidden];
    safetybuttonlabel.text = @"Safety";
    safetybuttonlabel.textAlignment = NSTextAlignmentCenter;
    safetybuttonlabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-5];
    safetybuttonlabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    safetybuttonlabel.alpha = 0;
    [self.view addSubview:safetybuttonlabel];
    
    guardbutton = [[UIButton alloc] initWithFrame:guardbutton_frame_hidden];
    guardbutton.backgroundColor = [UIColor colorWithRed:.1 green:0.78 blue:1 alpha:1];
    guardbutton.alpha = 0;
    guardbutton.layer.cornerRadius = fullheight*0.04;
    [guardbutton addTarget:self action:@selector(guardbutton_down:) forControlEvents:UIControlEventTouchDown];
    [guardbutton addTarget:self action:@selector(guardbutton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:guardbutton];
    guardbuttonlabel = [[UILabel alloc] initWithFrame:guardbutton_frame_hidden];
    guardbuttonlabel.text = @"Guard";
    guardbuttonlabel.textAlignment = NSTextAlignmentCenter;
    guardbuttonlabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-5];
    guardbuttonlabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    guardbuttonlabel.alpha = 0;
    [self.view addSubview:guardbuttonlabel];
    
    //Options Menu
    optionsmenu = [[UIView alloc] initWithFrame:optionsmenu_frame];
    optionsmenu.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    optionsmenu.alpha = 0.7;
    optionsmenu.layer.cornerRadius = fullheight*0.05;
    [self.view addSubview:optionsmenu];
    optionslabel = [[UILabel alloc] initWithFrame:optionslabel_frame];
    optionslabel.text = @"Options";
    optionslabel.textAlignment = NSTextAlignmentCenter;
    optionslabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize];
    optionslabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    optionslabel.alpha = 1;
    optionslabel.numberOfLines = 1;
    [self.view addSubview:optionslabel];
    optionsarrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowup.png"]];
    optionsarrow.frame = optionsarrow_frame;
    optionsarrow.alpha = 1;
    [self.view addSubview:optionsarrow];
    
    sharelocationswitch = [[UISwitch alloc] initWithFrame:sharelocationswitch_frame];
    sharelocationswitch.alpha = 1;
    sharelocationswitch.on = true;
    sharelocationswitch.tintColor = [UIColor colorWithWhite:1 alpha:1];
    sharelocationswitch.thumbTintColor = [UIColor colorWithWhite:1 alpha:1];
    sharelocationswitch.onTintColor = [UIColor colorWithRed:0 green:.7 blue:1 alpha:.88];
    [sharelocationswitch addTarget:self action:@selector(sharelocationswitch_changed:) forControlEvents:UIControlEventValueChanged];
    [optionsmenu addSubview:sharelocationswitch];
    
    sharelocationswitchlabel = [[UILabel alloc] initWithFrame:sharelocationswitchlabel_frame];
    sharelocationswitchlabel.text = @"Share Location";
    sharelocationswitchlabel.textAlignment = NSTextAlignmentCenter;
    sharelocationswitchlabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-9];
    sharelocationswitchlabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    sharelocationswitchlabel.alpha = 1;
    [optionsmenu addSubview:sharelocationswitchlabel];
    
    friendslisttitlelabel = [[UILabel alloc] initWithFrame:friendslisttitlelabel_frame];
    friendslisttitlelabel.text = @"Share location with:";
    friendslisttitlelabel.textAlignment = NSTextAlignmentCenter;
    friendslisttitlelabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-9];
    friendslisttitlelabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    friendslisttitlelabel.alpha = 1;
    [optionsmenu addSubview:friendslisttitlelabel];
    
    friendslist = [[UITableView alloc] initWithFrame:friendslist_frame style:UITableViewStylePlain];
    friendslist.backgroundColor = [UIColor colorWithWhite:.3 alpha:.8];
    friendslist.separatorStyle = UITableViewCellSeparatorStyleNone;
    friendslist.allowsMultipleSelection = true;
    friendslist.layer.cornerRadius = fullheight*.025;
    friendslist.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [optionsmenu addSubview:friendslist];
    friendslist.delegate = self;
    friendslist.dataSource = self;
    
    logoutButton = [[FBSDKLoginButton alloc] initWithFrame:logoutButton_frame];
    logoutButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    logoutButton.delegate = self;
    [optionsmenu addSubview:logoutButton];
    
    //Friends
    friendsbutton = [[UIButton alloc] initWithFrame:friendsbutton_frame];
    friendsbutton.alpha = 1;
    [friendsbutton setTitle:@"Manage Friends" forState:UIControlStateNormal];
    friendsbutton.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    friendsbutton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    friendsbutton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-12];
    friendsbutton.layer.cornerRadius = fullheight*0.02;
    [friendsbutton addTarget:self action:@selector(friendsbutton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [friendsbutton addTarget:self action:@selector(universalbutton_down:) forControlEvents:UIControlEventTouchDown];
    [optionsmenu addSubview:friendsbutton];
    
    friendsmask = [[UIView alloc] initWithFrame:friendsmask_frame];
    friendsmask.alpha = 0;
    [self.view addSubview:friendsmask];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Friends", @"Requests", nil];
    friendstype = [[UISegmentedControl alloc] initWithItems:itemArray];
    friendstype.frame = friendstype_frame;
    friendstype.tintColor = [UIColor colorWithWhite:1 alpha:1];
    [friendstype addTarget:self action:@selector(friendstype_valuechanged:) forControlEvents: UIControlEventValueChanged];
    friendstype.selectedSegmentIndex = 0;
    friendstype.alpha = 0;
    [self.view addSubview:friendstype];
    
    friendsclosebutton = [[UIButton alloc] initWithFrame:friendsclosebutton_frame];
    friendsclosebutton.alpha = 0;
    [friendsclosebutton setTitle:@"Done" forState:UIControlStateNormal];
    friendsclosebutton.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    friendsclosebutton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    friendsclosebutton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-12];
    friendsclosebutton.layer.cornerRadius = fullheight*0.02;
    [friendsclosebutton addTarget:self action:@selector(friendsclosebutton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [friendsclosebutton addTarget:self action:@selector(universalbutton_down:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:friendsclosebutton];
    
    friendslistedit = [[UITableView alloc] initWithFrame:friendslistedit_frame style:UITableViewStylePlain];
    friendslistedit.backgroundColor = [UIColor colorWithWhite:.3 alpha:.8];
    friendslistedit.separatorStyle = UITableViewCellSeparatorStyleNone;
    friendslistedit.allowsMultipleSelection = true;
    friendslistedit.layer.cornerRadius = fullheight*.025;
    friendslistedit.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    friendslistedit.alpha = 0;
    [self.view addSubview:friendslistedit];
    friendslistedit.delegate = self;
    friendslistedit.dataSource = self;
    
    friendsoption1button = [[UIButton alloc] initWithFrame:friendsoption1button_frame];
    friendsoption1button.alpha = 0;
    [friendsoption1button setTitle:@"Remove" forState:UIControlStateNormal];
    friendsoption1button.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    friendsoption1button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    friendsoption1button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-12];
    friendsoption1button.layer.cornerRadius = fullheight*0.02;
    [friendsoption1button addTarget:self action:@selector(friendsoption1button_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [friendsoption1button addTarget:self action:@selector(universalbutton_down:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:friendsoption1button];
    
    friendsoption2button = [[UIButton alloc] initWithFrame:friendsoption2button_frame];
    friendsoption2button.alpha = 0;
    [friendsoption2button setTitle:@"Add Friend" forState:UIControlStateNormal];
    friendsoption2button.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    friendsoption2button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    friendsoption2button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-12];
    friendsoption2button.layer.cornerRadius = fullheight*0.02;
    [friendsoption2button addTarget:self action:@selector(friendsoption2button_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [friendsoption2button addTarget:self action:@selector(universalbutton_down:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:friendsoption2button];
    
    addfriendmask = [[UIView alloc] initWithFrame:friendsmask_frame];
    addfriendmask.alpha = 0;
    [self.view addSubview:addfriendmask];
    
    addfriendmask_label = [[UILabel alloc] initWithFrame:addfriendmask_label_frame];
    addfriendmask_label.text = @"Add Friend";
    addfriendmask_label.textAlignment = NSTextAlignmentCenter;
    addfriendmask_label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-7];
    addfriendmask_label.textColor = [UIColor colorWithWhite:1 alpha:1];
    addfriendmask_label.alpha = 0;
    [self.view addSubview:addfriendmask_label];
    
    addfriendmask_textbox = [[UITextField alloc] initWithFrame:addfriendmask_textbox_frame];
    addfriendmask_textbox.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontsize-12];
    addfriendmask_textbox.clearButtonMode = UITextFieldViewModeWhileEditing;
    addfriendmask_textbox.alpha = 0;
    addfriendmask_textbox.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:addfriendmask_textbox];
    
    addfriendmask_addbutton = [[UIButton alloc] initWithFrame:addfriendmask_addbutton_frame];
    addfriendmask_addbutton.alpha = 0;
    [addfriendmask_addbutton setTitle:@"Send Request" forState:UIControlStateNormal];
    addfriendmask_addbutton.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    addfriendmask_addbutton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    addfriendmask_addbutton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-12];
    addfriendmask_addbutton.layer.cornerRadius = fullheight*0.02;
    [addfriendmask_addbutton addTarget:self action:@selector(addfriendmask_addbutton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [addfriendmask_addbutton addTarget:self action:@selector(universalbutton_down:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:addfriendmask_addbutton];
    
    addfriendmask_cancelbutton = [[UIButton alloc] initWithFrame:addfriendmask_cancelbutton_frame];
    addfriendmask_cancelbutton.alpha = 0;
    [addfriendmask_cancelbutton setTitle:@"Done" forState:UIControlStateNormal];
    addfriendmask_cancelbutton.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    addfriendmask_cancelbutton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    addfriendmask_cancelbutton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-12];
    addfriendmask_cancelbutton.layer.cornerRadius = fullheight*0.02;
    [addfriendmask_cancelbutton addTarget:self action:@selector(addfriendmask_cancelbutton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [addfriendmask_cancelbutton addTarget:self action:@selector(universalbutton_down:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:addfriendmask_cancelbutton];
    
    
    // Login
    loginmask = [[UIView alloc] initWithFrame:loginmask_frame];
    loginmask.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    loginmask.hidden = false;
    loginmask.alpha = 1;
    [self.view addSubview:loginmask];
    
    watchdoglabel = [[UILabel alloc] initWithFrame:watchdoglabel_frame];
    watchdoglabel.text = @"Safely";
    watchdoglabel.textAlignment = NSTextAlignmentCenter;
    watchdoglabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize+12];
    watchdoglabel.textColor = [UIColor colorWithRed:0 green:0.65 blue:1 alpha:1];
    watchdoglabel.alpha = 1;
    watchdoglabel.numberOfLines = 1;
    [loginmask addSubview:watchdoglabel];
    
    startupLabel = [[UILabel alloc] initWithFrame:startuplabel_frame];
    startupLabel.text = @"We are currently rapidly developing Safely, so please excuse any bugs or crashes! Graphics will get better and features will be added rapidly in the coming weeks. Thanks for helping in the early stages of our goal to keep you safe!";
    startupLabel.textAlignment = NSTextAlignmentCenter;
    startupLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:fontsize-5];
    startupLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    startupLabel.alpha = 1;
    startupLabel.numberOfLines = 8;
    [loginmask addSubview:startupLabel];
    
    
    loginButton = [[FBSDKLoginButton alloc] initWithFrame:loginButton_frame];
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    loginButton.delegate = self;
    [loginmask addSubview:loginButton];
    
    usernameTextfield = [[UITextField alloc] initWithFrame:usernameTextfield_frame];
    usernameTextfield.placeholder = @"Username";
    usernameTextfield.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize];
    usernameTextfield.backgroundColor = [UIColor colorWithWhite:0 alpha:.2];
    usernameTextfield.borderStyle = UITextBorderStyleRoundedRect;
    //usernameTextfield.textColor = [UIColor colorWithWhite:1 alpha:1];
    usernameTextfield.alpha = 0;
    [loginmask addSubview:usernameTextfield];
    
    chooseUsernameButton = [[UIButton alloc] initWithFrame:chooseUsernameButton_frame];
    chooseUsernameButton.backgroundColor = [UIColor colorWithRed:0 green:0.7 blue:1 alpha:1];
    chooseUsernameButton.alpha = 0;
    chooseUsernameButton.layer.cornerRadius = fullheight*0.03;
    [chooseUsernameButton addTarget:self action:@selector(chooseUsernameButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [chooseUsernameButton addTarget:self action:@selector(chooseUsernameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [loginmask addSubview:chooseUsernameButton];
    chooseUsernameButtonLabel = [[UILabel alloc] initWithFrame:chooseUsernameButton_frame];
    chooseUsernameButtonLabel.text = @"Choose";
    chooseUsernameButtonLabel.textAlignment = NSTextAlignmentCenter;
    chooseUsernameButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-5];
    chooseUsernameButtonLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    chooseUsernameButtonLabel.alpha = 0;
    [loginmask addSubview:chooseUsernameButtonLabel];
    
    //Launch view
    launchmask = [[UIView alloc] initWithFrame:launchmask_frame];
    launchmask.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    launchmask.hidden = false;
    launchmask.alpha = 1;
    [self.view addSubview:launchmask];
    
    launchicon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"safely_1024.png"]];
    launchicon.frame = launchicon_frame;
    [launchmask addSubview:launchicon];
    
    loadingspinner = [[UIActivityIndicatorView alloc] initWithFrame:loadingspinner_frame];
    loadingspinner.alpha = 1;
    loadingspinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [launchmask addSubview:loadingspinner];
    
    launcherrorlabel = [[UILabel alloc] initWithFrame:launcherrorlabel_frame];
    launcherrorlabel.text = @"";
    launcherrorlabel.textAlignment = NSTextAlignmentCenter;
    launcherrorlabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-10];
    launcherrorlabel.textColor = [UIColor colorWithRed:1 green:.5 blue:0 alpha:1];
    launcherrorlabel.hidden = launcherrorlabel_hidden;
    [launchmask addSubview:launcherrorlabel];
    
    
    //--------------//
    //--Messagebox--//
    //--------------//
    
    //Blur Backgrounds
    if (!UIAccessibilityIsReduceTransparencyEnabled())
    {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIBlurEffect *blurEffectDark = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurEffectView.alpha = 0;
        [self.view addSubview:blurEffectView];
        
        troublemask = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        troublemask.frame = troublemask_frame;
        troublemask.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        troublemask.alpha = 0;
        [self.view addSubview:troublemask];
        
        friendsmaskeffect = [[UIVisualEffectView alloc] initWithEffect:blurEffectDark];
        friendsmaskeffect.frame = friendsmask_frame;
        friendsmaskeffect.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        friendsmaskeffect.alpha = 1;
        [friendsmask addSubview:friendsmaskeffect];
        
        addfriendsmaskeffect = [[UIVisualEffectView alloc] initWithEffect:blurEffectDark];
        addfriendsmaskeffect.frame = friendsmask_frame;
        addfriendsmaskeffect.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        addfriendsmaskeffect.alpha = 1;
        [addfriendmask addSubview:addfriendsmaskeffect];
    }
    else
    {
        blurEffectReplacementView = [[UIView alloc] init];
        blurEffectReplacementView.frame = self.view.bounds;
        blurEffectReplacementView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurEffectReplacementView.alpha = 0;
        blurEffectReplacementView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:.8];
        [self.view addSubview:blurEffectReplacementView];
    }
    
    //Messagebox
    messagebox = [[UIView alloc] initWithFrame:messagebox_lowerdefaultframe];
    messagebox.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.9];
    messagebox.alpha = 0;
    messagebox.layer.cornerRadius = fullheight*0.042;
    [self.view addSubview:messagebox];
    
    //Messagebox title
    messagebox_title = [[UILabel alloc] initWithFrame:messagebox_title_lowerdefaultframe];
    messagebox_title.text = @"Title";
    messagebox_title.textAlignment = NSTextAlignmentCenter;
    messagebox_title.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize];
    messagebox_title.textColor = [UIColor colorWithWhite:1 alpha:1];
    messagebox_title.alpha = 0;
    [self.view addSubview:messagebox_title];
    
    //Messagebox description
    messagebox_description = [[UILabel alloc] initWithFrame:messagebox_description_lowerdefaultframe];
    messagebox_description.text = @"Description";
    messagebox_description.textAlignment = NSTextAlignmentCenter;
    messagebox_description.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:fontsize-12];
    messagebox_description.textColor = [UIColor colorWithWhite:1 alpha:1];
    messagebox_description.alpha = 0;
    messagebox_description.numberOfLines = 6;
    [self.view addSubview:messagebox_description];
    
    //Messagebox button
    messagebox_button = [[UIButton alloc] initWithFrame:messagebox_button_lowerdefaultframe];
    messagebox_button.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.9];
    messagebox_button.alpha = 0;
    messagebox_button.layer.cornerRadius = fullheight*0.035;
    [messagebox_button addTarget:self action:@selector(universalbutton_down:) forControlEvents:UIControlEventTouchDown];
    [messagebox_button addTarget:self action:@selector(messagebox_button_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messagebox_button];
    
    //Messagebox button label
    messagebox_buttonlabel = [[UILabel alloc] initWithFrame:messagebox_buttonlabel_lowerdefaultframe];
    messagebox_buttonlabel.text = @"Button";
    messagebox_buttonlabel.textAlignment = NSTextAlignmentCenter;
    messagebox_buttonlabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-5];
    messagebox_buttonlabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    messagebox_buttonlabel.alpha = 0;
    [self.view addSubview:messagebox_buttonlabel];
    
    
    //Messagebox yes button
    messagebox_yesbutton = [[UIButton alloc] initWithFrame:messagebox_yesbutton_lowerdefaultframe];
    messagebox_yesbutton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.9];
    messagebox_yesbutton.alpha = 0;
    messagebox_yesbutton.layer.cornerRadius = fullheight*0.035;
    [messagebox_yesbutton addTarget:self action:@selector(messagebox_yesbutton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messagebox_yesbutton];
    
    //Messagebox yes button label
    messagebox_yesbuttonlabel = [[UILabel alloc] initWithFrame:messagebox_yesbuttonlabel_lowerdefaultframe];
    messagebox_yesbuttonlabel.text = @"Button";
    messagebox_yesbuttonlabel.textAlignment = NSTextAlignmentCenter;
    messagebox_yesbuttonlabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-5];
    messagebox_yesbuttonlabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    messagebox_yesbuttonlabel.alpha = 0;
    [self.view addSubview:messagebox_yesbuttonlabel];
    
    //Messagebox no button
    messagebox_nobutton = [[UIButton alloc] initWithFrame:messagebox_nobutton_lowerdefaultframe];
    messagebox_nobutton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.9];
    messagebox_nobutton.alpha = 0;
    messagebox_nobutton.layer.cornerRadius = fullheight*0.035;
    [messagebox_nobutton addTarget:self action:@selector(messagebox_nobutton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messagebox_nobutton];
    
    //Messagebox no button label
    messagebox_nobuttonlabel = [[UILabel alloc] initWithFrame:messagebox_nobuttonlabel_lowerdefaultframe];
    messagebox_nobuttonlabel.text = @"Button";
    messagebox_nobuttonlabel.textAlignment = NSTextAlignmentCenter;
    messagebox_nobuttonlabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-5];
    messagebox_nobuttonlabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    messagebox_nobuttonlabel.alpha = 0;
    [self.view addSubview:messagebox_nobuttonlabel];
    
    /*---------------*/
    /*----Loading----*/
    /*---------------*/
    loadingmask = [[UIView alloc] initWithFrame:loadingmask_frame];
    loadingmask.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.7];
    loadingmask.alpha = 0;
    loadingmask.layer.cornerRadius = fullheight*0.05;
    [self.view addSubview:loadingmask];
    
    loadingmasklabel = [[UILabel alloc] initWithFrame:loadingmasklabel_frame];
    loadingmasklabel.text = @"Loading";
    loadingmasklabel.textAlignment = NSTextAlignmentCenter;
    loadingmasklabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontsize-12];
    loadingmasklabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    [loadingmask addSubview:loadingmasklabel];
    
    loadingmaskspinner = [[UIActivityIndicatorView alloc] initWithFrame:loadingmaskspinner_frame];
    loadingmaskspinner.alpha = 1;
    loadingmaskspinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [loadingmask addSubview:loadingmaskspinner];
    [loadingmaskspinner startAnimating];
}

- (void)finalInits
{
    //Add Gestures
    [menushade addGestureRecognizer:shadeTapRecognizer];
    [menushade addGestureRecognizer:shadeSwipeUpRecognizer];
    [menushade addGestureRecognizer:shadeSwipeDownRecognizer];
    
    [menu addGestureRecognizer:menuSwipeUpRecognizer];
    [menu addGestureRecognizer:menuSwipeDownRecognizer];
    [menu addGestureRecognizer:menuTapRecognizer];
    
    [optionsmenu addGestureRecognizer:optionsSwipeUpRecognizer];
    [optionsmenu addGestureRecognizer:optionsSwipeDownRecognizer];
    [optionsmenu addGestureRecognizer:optionsTapRecognizer];
    
    if ([FBSDKAccessToken currentAccessToken]) [self login:@""];
    else [self showLogin];
    
    //TEMPORARY FOR SIMULATOR
    /*
    watchdogmode = 1;
    
    [self beginFollowingUser];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        loginmask.alpha = 0;
        launchmask.alpha = 0;
        loginButton.alpha = 0;
    }completion:^(BOOL finished){
        loginmask.hidden = true;
        launchmask.hidden = true;
        chooseUsernameButton.alpha = 1;
        chooseUsernameButtonLabel.alpha = 1;
    }];
    
    [loadingspinner stopAnimating];
     */
}

- (void)openmenu
{
    //Temporary until enabling all modes on app store
    /*
    [self showMessageBox:@"Coming soon" withDescription:@"Let's stick with location sharing for now. Safely is currently undergoing rapid development - all modes will be available soon." withButtonLabel:@"I can't wait!"];
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        menu.frame = menu_frame;
        menuarrow.frame = menuarrow_frame;
        if (!switchingmenus) menushade.alpha = 0;
        menuarrow.image = [UIImage imageNamed:@"arrowdown.png"];
    }completion:nil];
    
    return;
     */
    
    if (changingmodes) return;
    
    menuopen = true;
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        menu.frame = menu_frame_open;
        menuarrow.frame = menuarrow_frame_open;
        if (!switchingmenus) menushade.alpha = 0.6;
        menuarrow.image = [UIImage imageNamed:@"arrowup.png"];
    }completion:nil];
    
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sharingbutton.alpha = 0.9;
        sharingbutton.frame = sharingbutton_frame_visible;
        sharingbuttonlabel.alpha = 1;
        sharingbuttonlabel.frame = sharingbutton_frame_visible;
    }completion:nil];
    
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        safetybutton.alpha = 0.9;
        safetybutton.frame = safetybutton_frame_visible;
        safetybuttonlabel.alpha = 1;
        safetybuttonlabel.frame = safetybutton_frame_visible;
    }completion:nil];
    
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        guardbutton.alpha = 0.9;
        guardbutton.frame = guardbutton_frame_visible;
        guardbuttonlabel.alpha = 1;
        guardbuttonlabel.frame = guardbutton_frame_visible;
    }completion:^(BOOL finished){
    }];
}

- (void)closemenu
{
    if (changingmodes) return;
    
    menuopen = false;
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sharingbutton.alpha = 0;
        sharingbutton.frame = sharingbutton_frame_hidden;
        sharingbuttonlabel.alpha = 0;
        sharingbuttonlabel.frame = sharingbutton_frame_hidden;
    }completion:nil];
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        safetybutton.alpha = 0;
        safetybutton.frame = safetybutton_frame_hidden;
        safetybuttonlabel.alpha = 0;
        safetybuttonlabel.frame = safetybutton_frame_hidden;
    }completion:nil];
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        guardbutton.alpha = 0;
        guardbutton.frame = guardbutton_frame_hidden;
        guardbuttonlabel.alpha = 0;
        guardbuttonlabel.frame = guardbutton_frame_hidden;
    }completion:nil];
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        menu.frame = menu_frame;
        menuarrow.frame = menuarrow_frame;
        if (!switchingmenus) menushade.alpha = 0;
        menuarrow.image = [UIImage imageNamed:@"arrowdown.png"];
    }completion:nil];
}

- (void)openoptions
{
    if (changingmodes) return;
    
    optionsopen = true;
    
    //[friendslist reloadData];
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        optionsmenu.frame = optionsmenu_frame_open;
        optionsarrow.frame = optionsarrow_frame_open;
        optionslabel.frame = optionslabel_frame_open;
        if (!switchingmenus) menushade.alpha = 0.6;
        optionsmenu.alpha = 0.92;
        optionsarrow.image = [UIImage imageNamed:@"arrowdown.png"];
        loginButton.alpha = 1;
    }completion:nil];
}

- (void)closeoptions
{
    if (changingmodes) return;
    
    optionsopen = false;
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        optionsmenu.frame = optionsmenu_frame;
        optionsarrow.frame = optionsarrow_frame;
        optionslabel.frame = optionslabel_frame;
        if (!switchingmenus) menushade.alpha = 0;
        optionsmenu.alpha = 0.7;
        optionsarrow.image = [UIImage imageNamed:@"arrowup.png"];
        loginButton.alpha = 0;
    }completion:nil];
}

- (void)revealOptions
{
    switchingmenus = true;
    [self closemenu];
    switchingmenus = false;
    [self openoptions];
}

-(void)activateSharingMode
{
    NSLog(@"Sharing Mode Activated");
    
    changingmodes = true;
    
    loadingtimer = [NSTimer scheduledTimerWithTimeInterval:.75 target:self selector:@selector(showLoading) userInfo:nil repeats:false];
    
    friendslisttitlelabel.text = @"Share location with:";
    
    menulabel.text = @"Sharing";
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sharingbutton.backgroundColor = [UIColor colorWithRed:0 green:0.93 blue:1 alpha:1];
        safetybutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
        guardbutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
    }completion:nil];
    
    watchdogmode = 1;
    [defaults setInteger:1 forKey:@"mode"];
    [userrecord setValue:[NSNumber numberWithInteger:1] forKey:@"mode"];
    
    [self updateUserRecord];
    
    [self updateUserLocation];
    [self updateFriendsLocations];
    updatelocationtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateUserLocation) userInfo:nil repeats:true];
    updatefriendslocationstimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(updateFriendsLocations) userInfo:nil repeats:true];
}

-(void)activateSafetyMode
{
    NSLog(@"Safety Mode Activated");
    
    changingmodes = true;
    
    loadingtimer = [NSTimer scheduledTimerWithTimeInterval:.75 target:self selector:@selector(showLoading) userInfo:nil repeats:false];
    
    friendslisttitlelabel.text = @"Friends guarding you:";
    
    menulabel.text = @"Safety";
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sharingbutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
        safetybutton.backgroundColor = [UIColor colorWithRed:0 green:0.93 blue:1 alpha:1];
        guardbutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
    }completion:nil];
    
    watchdogmode = 2;
    [defaults setInteger:2 forKey:@"mode"];
    [userrecord setValue:[NSNumber numberWithInteger:2] forKey:@"mode"];
    
    //Update user record happens in next methods; but needs to be called if user has no friends
    if (friends.count > 0) [self updateUserRecord];
    
    [self updateUserLocation];
    [self updateFriendsLocations];
    updatelocationtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateUserLocation) userInfo:nil repeats:true];
    updatefriendslocationstimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(updateFriendsLocations) userInfo:nil repeats:true];
    
    //[self beginMonitoringHeadphoneState];
}

-(void)activateGuardMode
{
    NSLog(@"Guard Mode Activated");
    
    changingmodes = true;
    
    loadingtimer = [NSTimer scheduledTimerWithTimeInterval:.75 target:self selector:@selector(showLoading) userInfo:nil repeats:false];
    
    //No need to have a friends list for guarding, all users should be guarded at once
    friendslisttitlelabel.text = @"";
    friendslist.hidden = true;
    
    menulabel.text = @"Guard";
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sharingbutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
        safetybutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
        guardbutton.backgroundColor = [UIColor colorWithRed:0 green:0.93 blue:1 alpha:1];
    }completion:nil];
    
    watchdogmode = 3;
    [defaults setInteger:3 forKey:@"mode"];
    [userrecord setValue:[NSNumber numberWithInteger:3] forKey:@"mode"];
    
    //Update user record happens in next methods; but needs to be called if user has no friends
    if (friends.count > 0) [self updateUserRecord];
    
    [self updateUserLocation];
    [self updateFriendsLocations];
    updatelocationtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateUserLocation) userInfo:nil repeats:true];
    updatefriendslocationstimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(updateFriendsLocations) userInfo:nil repeats:true];
    
    [self subscribeAsGuard];
    
    [self finishActivatingMode];
}

-(void)finishActivatingMode
{
    [self hideLoading];
    
    changingmodes = false;
    
    if (revealoptions) [self revealOptions];
}

-(void)deactivateAllModes
{
    if (watchdogmode == 1) NSLog(@"Sharing Mode Deactivated");
    else if (watchdogmode == 2) NSLog(@"Safety Mode Deactivated");
    else if (watchdogmode == 3)
    {
        //[self pubNubPublish:[NSString stringWithFormat:@"32%@ has arrived safely",[user getUsername]] toChannel:facebookid];
        NSLog(@"Guard Mode Deactivated");
    }
    
    watchdogmode = 0;
    [defaults setInteger:0 forKey:@"mode"];
    [userrecord setValue:[NSNumber numberWithInteger:0] forKey:@"mode"];
    
    //Deactivate Sharing
    [updatelocationtimer invalidate];
    [updatefriendslocationstimer invalidate];
    sharingbegan = false;
    //[map removeOverlays:[map overlays]];
    [self removeMapAnnotations];
    
    //Deactivate Safety
    NSMutableArray *guards = [[NSMutableArray alloc] init];
    [userrecord setValue:guards forKey:@"guards"];
    [self endMonitoringHeadphoneState];
    
    //Deactivate Guard
    friendslist.hidden = false;
    [self updateUserRecord];
}

//Button Methods
-(IBAction)sharingbutton_pressed:(UIButton*)sender
{
    if (changingmodes) return;
    
    revealoptions = true;
    
    [self deactivateAllModes];
    
    [self activateSharingMode];
    
    menulabel.text = @"Sharing";
}

-(IBAction)safetybutton_pressed:(UIButton*)sender
{
    if (changingmodes) return;
    
    revealoptions = true;
    
    [self deactivateAllModes];
    
    [self activateSafetyMode];
    
    menulabel.text = @"Safety";
}

-(IBAction)guardbutton_pressed:(UIButton*)sender
{
    if (changingmodes) return;
    
    revealoptions = true;
    
    [self deactivateAllModes];
    
    [self activateGuardMode];
    
    menulabel.text = @"Guard";
}

-(IBAction)followlocationbutton_pressed:(id)sender
{
    [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        followlocationbutton.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        followlocationbutton.alpha = 0;
        followlocationicon.alpha = 0;
    }completion:nil];
    
    [self beginFollowingUser];
}

-(IBAction)sharingbutton_down:(UIButton*)sender
{
    if (changingmodes) return;
    
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sharingbutton.backgroundColor = [UIColor colorWithRed:0 green:0.93 blue:1 alpha:1];
        guardbutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
        safetybutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
    }completion:nil];
}

-(IBAction)safetybutton_down:(UIButton*)sender
{
    if (changingmodes) return;
    
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        safetybutton.backgroundColor = [UIColor colorWithRed:0 green:0.93 blue:1 alpha:1];
        sharingbutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
        guardbutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
    }completion:nil];
}

-(IBAction)guardbutton_down:(UIButton*)sender
{
    if (changingmodes) return;
    
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        guardbutton.backgroundColor = [UIColor colorWithRed:0 green:0.93 blue:1 alpha:1];
        sharingbutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
        safetybutton.backgroundColor = [UIColor colorWithRed:0 green:0.78 blue:1 alpha:1];
    }completion:nil];
}

-(IBAction)universalbutton_down:(UIButton*)sender
{
    [UIView animateWithDuration:.07 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        sender.backgroundColor = [UIColor colorWithRed:0 green:0.7 blue:1 alpha:1];
        sender.alpha = 1;
    }completion:nil];
}

-(IBAction)friendsbutton_pressed:(UIButton*)sender
{
    [self showFriends];
    [UIView animateWithDuration:.07 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        friendsbutton.backgroundColor = [UIColor colorWithWhite:1 alpha:.2];
    }completion:nil];
}

-(IBAction)friendsclosebutton_pressed:(UIButton*)sender
{
    [self hideFriends];
    [UIView animateWithDuration:.07 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        friendsclosebutton.backgroundColor = [UIColor colorWithWhite:1 alpha:.2];
    }completion:nil];
}

-(IBAction)friendsoption1button_pressed:(UIButton*)sender
{
    [UIView animateWithDuration:.07 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        friendsoption1button.backgroundColor = [UIColor colorWithWhite:1 alpha:.2];
    }completion:nil];
    
    if (friendstype.selectedSegmentIndex == 0)
    {
        [self showMessageBox:@"Coming soon" withDescription:@"Safely is currently undergoing rapid development. This feature will be available soon." withButtonLabel:@"Ok"];
        return;
        
        //Remove selected friends
        for (int i = 0; i < friends.count; i++) if (selectedfriendsedit[i])
        {
            [friends removeObjectAtIndex:i];
            [friendsnames removeObjectAtIndex:i];
            [friendsmodes removeObjectAtIndex:i];
            [friendslocations removeObjectAtIndex:i];
            [friendspictures removeObjectAtIndex:i];
            [userrecord setValue:friends forKey:@"friends"];
            [userrecord setValue:friendsnames forKey:@"friendsnames"];
            [self updateUserRecord];
            [friendslistedit reloadData];
            [friendslist reloadData];
        }
    }
    else
    {
        //Accept selected requests
        for (int i = 0; i < [friendslistedit numberOfRowsInSection:0]; i++) if (selectedrequests[i])
        {
            [friends addObject:[friendinrequests objectAtIndex:i]];
            [friendsnames addObject:[friendinrequests objectAtIndex:i]];
            [friendinrequests removeObjectAtIndex:i];
            [userrecord setValue:friends forKey:@"friends"];
            [userrecord setValue:friendsnames forKey:@"friendsnames"];
            [userrecord setValue:friendinrequests forKey:@"friendinrequests"];
            [self updateUserRecord];
            [friendslistedit reloadData];
            [friendslist reloadData];
        }
    }
}

-(IBAction)friendsoption2button_pressed:(UIButton*)sender
{
    [UIView animateWithDuration:.07 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        friendsoption2button.backgroundColor = [UIColor colorWithWhite:1 alpha:.2];
    }completion:nil];
    
    if (friendstype.selectedSegmentIndex == 0)
    {
        //Show add friend screen
        [self showAddFriend];
    }
    else
    {
        [self showMessageBox:@"Coming soon" withDescription:@"Safely is currently undergoing rapid development. This feature will be available soon." withButtonLabel:@"Ok"];
        return;
        
        //Decline and block selected requests
        for (int i = 0; i < [friendslistedit numberOfRowsInSection:0]; i++) if (selectedrequests[i])
        {
            [blockedusers addObject:[friendinrequests objectAtIndex:i]];
            [friendinrequests removeObjectAtIndex:i];
            [userrecord setValue:blockedusers forKey:@"blockedusers"];
            [userrecord setValue:friendinrequests forKey:@"friendinrequests"];
            [self updateUserRecord];
            [friendslistedit reloadData];
        }
    }
}

-(IBAction)addfriendmask_addbutton_pressed:(UIButton*)sender
{
    [addfriendmask_textbox resignFirstResponder];
    
    [self showLoading];
    
    [UIView animateWithDuration:.07 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sender.backgroundColor = [UIColor colorWithWhite:1 alpha:.2];
    }completion:nil];
    
    NSString *friendname = addfriendmask_textbox.text;
    
    //Check if user exists
    NSPredicate *userpred = [NSPredicate predicateWithFormat:@"username = %@" argumentArray:@[friendname]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"User" predicate:userpred];
    
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *publicData = container.publicCloudDatabase;
    
    [publicData performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (!error)
        {
            for (CKRecord* rec in results)
            {
                //User found, add friend
                [friendoutrequests addObject:[rec valueForKey:@"username"]];
                if ([blockedusers containsObject:[rec valueForKey:@"username"]]) [blockedusers removeObject:[rec valueForKey:@"username"]];
                [userrecord setValue:friendoutrequests forKey:@"friendoutrequests"];
                [userrecord setValue:blockedusers forKey:@"blockedusers"];
                [self updateUserRecord];
                [self hideLoading];
                [self showMessageBox:@"Sent" withDescription:@"Friend request sent!" withButtonLabel:@"Ok"];
            }
            if (results.count < 1)
            {
                NSLog(@"Cannot add user, error or user not found");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideLoading];
                    [self showMessageBox:@"Error" withDescription:@"User not found" withButtonLabel:@"Ok"];
                });
            }
        }
        else
        {
            //Error: user doesnt exist
            NSLog(@"Cannot add user, error or user not found");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                [self showMessageBox:@"Error" withDescription:@"User not found" withButtonLabel:@"Ok"];
            });
        }
    }];
}

-(IBAction)addfriendmask_cancelbutton_pressed:(UIButton*)sender
{
    [self hideAddFriend];
    
    [UIView animateWithDuration:.07 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sender.backgroundColor = [UIColor colorWithWhite:1 alpha:.2];
    }completion:nil];
}

-(void)showAddFriend
{
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        addfriendmask.alpha = 1;
        addfriendmask_label.alpha = 1;
        addfriendmask_textbox.alpha = 1;
        addfriendmask_addbutton.alpha = 1;
        addfriendmask_cancelbutton.alpha = 1;
    }completion:nil];
}

-(void)hideAddFriend
{
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        addfriendmask.alpha = 0;
        addfriendmask_label.alpha = 0;
        addfriendmask_textbox.alpha = 0;
        addfriendmask_addbutton.alpha = 0;
        addfriendmask_cancelbutton.alpha = 0;
    }completion:nil];
}

-(IBAction)friendstype_valuechanged:(UISegmentedControl*)sender
{
    [friendslistedit reloadData];
    
    //If looking at friends list
    if (friendstype.selectedSegmentIndex == 0)
    {
        [friendsoption1button setTitle:@"Remove Friend" forState:UIControlStateNormal];
        [friendsoption2button setTitle:@"Add Friend" forState:UIControlStateNormal];
        [self disableFriendsOptionButton1];
        [self enableFriendsOptionButton2];
    }
    
    //If looking at requests list
    if (friendstype.selectedSegmentIndex == 1)
    {
        [friendsoption1button setTitle:@"Accept Request" forState:UIControlStateNormal];
        [friendsoption2button setTitle:@"Decline Request" forState:UIControlStateNormal];
        [self disableFriendsOptionButton1];
        [self disableFriendsOptionButton2];
    }
}

-(void)enableFriendsOptionButton1
{
    friendsoption1button.enabled = true;
    friendsoption1button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    friendsoption1button.alpha = 1;
}

-(void)disableFriendsOptionButton1
{
    friendsoption1button.enabled = false;
    friendsoption1button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    friendsoption1button.alpha = .5;
}

-(void)enableFriendsOptionButton2
{
    friendsoption2button.enabled = true;
    friendsoption2button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    friendsoption2button.alpha = 1;
}

-(void)disableFriendsOptionButton2
{
    friendsoption2button.enabled = false;
    friendsoption2button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    friendsoption2button.alpha = .5;
}

//Messagebox

-(IBAction)messagebox_button_pressed:(UIButton*)sender
{
    [UIView animateWithDuration:.07 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        messagebox_button.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.9];
        messagebox_button.alpha = 0.25;
    }completion:nil];
    
    [self hideMessageBox];
    
    if ([messageboxresponse isEqualToString:@""])
    {
        //Perform action after dismissing messagebox
    }
    
    messageboxresponse = 0;
}

-(IBAction)messagebox_yesbutton_pressed:(UIButton*)sender
{
    [self hideMessageBox];
    
    //if ([messagebox_title.text isEqualToString:@"Facebook Login"]) [self loginWithFacebook];
}

-(IBAction)messagebox_nobutton_pressed:(UIButton*)sender
{
    [self hideMessageBox];
    
    
}

-(void)showMessageBox:(NSString*)title withDescription:(NSString*)description withButtonLabel:(NSString*)buttonlabel
{
    messagebox_title.text = title;
    messagebox_description.text = description;
    messagebox_buttonlabel.text = buttonlabel;
    messageboxhidden = false;
    
    [UIView animateWithDuration:.35 delay:.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        messagebox.frame = messagebox_defaultframe;
        messagebox.alpha = 0.9;
        messagebox_description.frame = messagebox_description_defaultframe;
        messagebox_description.alpha = 1;
        messagebox_title.frame = messagebox_title_defaultframe;
        messagebox_title.alpha = 1;
        messagebox_button.alpha = 0.25;
        messagebox_button.frame = messagebox_button_defaultframe;
        messagebox_buttonlabel.alpha = 1;
        messagebox_buttonlabel.frame = messagebox_buttonlabel_defaultframe;
        blurEffectView.alpha = 1;
        blurEffectReplacementView.alpha = 1;
    }completion:nil];
}

-(void)showMessageBoxWithOptions:(NSString*)title withDescription:(NSString*)description withYesButtonLabel:(NSString*)yesbuttonlabel withNoButtonLabel:(NSString*)nobuttonlabel
{
    messagebox_title.text = title;
    messagebox_description.text = description;
    messagebox_yesbuttonlabel.text = yesbuttonlabel;
    messagebox_nobuttonlabel.text = nobuttonlabel;
    messageboxhidden = false;
    [UIView animateWithDuration:.35 delay:.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        messagebox.frame = messagebox_defaultframe;
        messagebox.alpha = 0.9;
        messagebox_description.frame = messagebox_description_defaultframe;
        messagebox_description.alpha = 1;
        messagebox_title.frame = messagebox_title_defaultframe;
        messagebox_title.alpha = 1;
        
        messagebox_yesbutton.alpha = 0.15;
        messagebox_yesbutton.frame = messagebox_yesbutton_defaultframe;
        
        messagebox_nobutton.alpha = 0.15;
        messagebox_nobutton.frame = messagebox_nobutton_defaultframe;
        
        messagebox_yesbuttonlabel.alpha = 1;
        messagebox_yesbuttonlabel.frame = messagebox_yesbuttonlabel_defaultframe;
        
        messagebox_nobuttonlabel.alpha = 1;
        messagebox_nobuttonlabel.frame = messagebox_nobuttonlabel_defaultframe;
        
        blurEffectView.alpha = 1;
        blurEffectReplacementView.alpha = 1;
    }completion:nil];
}

//Show message box with delay

-(void)showMessageBoxWithDelay:(NSString*)title withDescription:(NSString*)description withButtonLabel:(NSString*)buttonlabel
{
    messagebox_title.text = title;
    messagebox_description.text = description;
    messagebox_buttonlabel.text = buttonlabel;
    messageboxhidden = false;
    [UIView animateWithDuration:.35 delay:.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        messagebox.frame = messagebox_defaultframe;
        messagebox.alpha = 0.9;
        messagebox_description.frame = messagebox_description_defaultframe;
        messagebox_description.alpha = 1;
        messagebox_title.frame = messagebox_title_defaultframe;
        messagebox_title.alpha = 1;
        messagebox_button.alpha = 0.15;
        messagebox_button.frame = messagebox_button_defaultframe;
        messagebox_buttonlabel.alpha = 1;
        messagebox_buttonlabel.frame = messagebox_buttonlabel_defaultframe;
        
        blurEffectView.alpha = 1;
        blurEffectReplacementView.alpha = 1;
    }completion:nil];
}

-(void)hideMessageBox
{
    messageboxhidden = true;
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        blurEffectView.alpha = 0;
        blurEffectReplacementView.alpha = 0;
        
        messagebox.frame = messagebox_upperdefaultframe;
        messagebox.alpha = 0;
        messagebox_description.frame = messagebox_description_upperdefaultframe;
        messagebox_description.alpha = 0;
        messagebox_title.frame = messagebox_title_upperdefaultframe;
        messagebox_title.alpha = 0;
        messagebox_button.alpha = 0;
        messagebox_button.frame = messagebox_button_upperdefaultframe;
        messagebox_buttonlabel.alpha = 0;
        messagebox_buttonlabel.frame = messagebox_buttonlabel_upperdefaultframe;
        
        messagebox_yesbutton.alpha = 0;
        messagebox_yesbutton.frame = messagebox_yesbutton_upperdefaultframe;
        messagebox_nobutton.alpha = 0;
        messagebox_nobutton.frame = messagebox_nobutton_upperdefaultframe;
        messagebox_yesbuttonlabel.alpha = 0;
        messagebox_yesbuttonlabel.frame = messagebox_yesbuttonlabel_upperdefaultframe;
        messagebox_nobuttonlabel.alpha = 0;
        messagebox_nobuttonlabel.frame = messagebox_nobuttonlabel_upperdefaultframe;
    }completion:^(BOOL finished){
        messagebox.frame = messagebox_lowerdefaultframe;
        messagebox_title.frame = messagebox_title_lowerdefaultframe;
        messagebox_description.frame = messagebox_description_lowerdefaultframe;
        messagebox_button.frame = messagebox_button_lowerdefaultframe;
        messagebox_buttonlabel.frame = messagebox_buttonlabel_lowerdefaultframe;
        
        messagebox_yesbutton.frame = messagebox_yesbutton_lowerdefaultframe;
        messagebox_nobutton.frame = messagebox_nobutton_lowerdefaultframe;
        messagebox_yesbuttonlabel.frame = messagebox_yesbuttonlabel_lowerdefaultframe;
        messagebox_nobuttonlabel.frame = messagebox_nobuttonlabel_lowerdefaultframe;
    }];
}

//Map and Location Manager Delegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    
    if (watchdogmode == 4)
    {
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
        {
            //Get current time
            NSDate *currentTime = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm:ss a"];
            NSString *date = [dateFormatter stringFromDate: currentTime];
            if ([[date substringToIndex:1] integerValue] == 0) date = [date substringFromIndex:1];
            [userrecord setValue:date forKey:@"time"];
            
            [userrecord setValue:location forKey:@"location"];
            
            [self updateUserRecord];
        }
    }
}

-(void)updateFriendsLists
{
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *publicData = container.publicCloudDatabase;
    
    //Check if anyone added you to their outrequests, and add them to your inrequests list if they arent on it already
    NSPredicate *outrequestspred = [NSPredicate predicateWithFormat:@"friendoutrequests CONTAINS %@" argumentArray:@[user.getUsername]];
    
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"User" predicate:outrequestspred];
    
    [publicData performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (!error)
        {
            //User sent you a friend request, add them to your inrequests list if you haven't added them yet
            for (CKRecord* rec in results)
            {
                //Check if you already added them, or already declined them
                if ([friends containsObject:[rec valueForKey:@"username"]]) continue;
                if ([blockedusers containsObject:[rec valueForKey:@"username"]]) continue;
                
                //Add them to inrequests if you havent added them yet
                [friendinrequests addObject:[rec valueForKey:@"username"]];
                [userrecord setValue:friendinrequests forKey:@"friendinrequests"];
                [self updateUserRecord];
                [friendslistedit reloadData];
            }
        }
        else
        {
            //No one has sent you a request
        }
    }];
    
    //Check for anyone on your outrequests list has added you as a friend, or has you blocked.
    //If blocked, remove from outreqests, if added, add to your friends list if not already added
    for (NSString* outrequest in friendoutrequests)
    {
        NSPredicate *userpred = [NSPredicate predicateWithFormat:@"username = %@" argumentArray:@[outrequest]];
        NSPredicate *friendspred = [NSPredicate predicateWithFormat:@"friends CONTAINS %@" argumentArray:@[user.getUsername]];
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userpred,friendspred]];
        
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"User" predicate:predicate];
        
        [publicData performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
            if (!error)
            {
                //They accepted your request, add them to your friends list
                [friends addObject:outrequest];
                [friendsnames addObject:outrequest];
                [friendoutrequests removeObject:outrequest];
                [userrecord setValue:friends forKey:@"friends"];
                [userrecord setValue:friendsnames forKey:@"friendsnames"];
                [userrecord setValue:friendoutrequests forKey:@"friendoutrequests"];
                [self updateUserRecord];
                [friendslistedit reloadData];
                [friendslist reloadData];
            }
            else
            {
                //They haven't accepted. Check if they declined
                NSPredicate *blockedpred = [NSPredicate predicateWithFormat:@"blockedusers CONTAINS %@" argumentArray:@[user.getUsername]];
                NSPredicate *blockedpredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userpred,blockedpred]];
                
                CKQuery *blockedquery = [[CKQuery alloc] initWithRecordType:@"User" predicate:blockedpredicate];
                
                [publicData performQuery:blockedquery inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
                    if (!error)
                    {
                        //They declined your request, remove from outrequests list
                        return;
                        [friendoutrequests removeObject:outrequest];
                        [userrecord setValue:friendoutrequests forKey:@"friendoutrequests"];
                        [self updateUserRecord];
                    }
                    else
                    {
                        //They haven't accepted yet, it's all good
                    }
                }];
            }
        }];
    }
    
    
    //Check if any friends removed you from their friends list, remove them from yours
    for (NSString* friend in friends)
    {
        NSPredicate *userpred = [NSPredicate predicateWithFormat:@"username = %@" argumentArray:@[friend]];
        NSPredicate *friendspred = [NSPredicate predicateWithFormat:@"friends CONTAINS %@" argumentArray:@[user.getUsername]];
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userpred,friendspred]];
        
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"User" predicate:predicate];
        
        [publicData performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
            if (!error)
            {
                //Still friends, it's all good
            }
            else
            {
                //You aren't on their friends list, check if you're still on their outrequests list
                NSPredicate *outpred = [NSPredicate predicateWithFormat:@"friendoutrequests CONTAINS %@" argumentArray:@[user.getUsername]];
                NSPredicate *outpredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userpred,outpred]];
                
                CKQuery *blockedquery = [[CKQuery alloc] initWithRecordType:@"User" predicate:outpredicate];
                
                [publicData performQuery:blockedquery inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
                    if (!error)
                    {
                        //You're still on their outrequests, it's all good
                    }
                    else
                    {
                        //They removed you, remove them
                        return;
                        int i = (int)[friends indexOfObject:friend];
                        [friends removeObjectAtIndex:i];
                        [friendsnames removeObjectAtIndex:i];
                        [friendsmodes removeObjectAtIndex:i];
                        [friendslocations removeObjectAtIndex:i];
                        [friendspictures removeObjectAtIndex:i];
                        [userrecord setValue:friends forKey:@"friends"];
                        [userrecord setValue:friendsnames forKey:@"friendsnames"];
                        [self updateUserRecord];
                        [friendslistedit reloadData];
                        [friendslist reloadData];
                    }
                }];
            }
        }];
    }
}

-(void)updateUserLocation
{
    //if (friends.count < 1) return;
    
    NSLog(@"User location update");
    [userrecord setValue:[NSNumber numberWithDouble:locationManager.location.horizontalAccuracy] forKey:@"locationaccuracy"];
    [userrecord setValue:locationManager.location forKey:@"location"];
    NSLog(@"%@",locationManager.location);
    
    //Get current time
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm:ss a"];
    NSString *date = [dateFormatter stringFromDate: currentTime];
    if ([[date substringToIndex:1] integerValue] == 0) date = [date substringFromIndex:1];
    [userrecord setValue:date forKey:@"time"];
    
    [self updateUserRecord];
}

-(void)updateFriendsLocations
{
    if (friends.count < 1)
    {
        if (changingmodes) [self finishActivatingMode];
        return;
    }
    
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *publicData = container.publicCloudDatabase;
    
    //[map removeOverlays:[map overlays]];
    //[self removeMapAnnotations];
    
    int updatemode = 0;
    if (watchdogmode == 1) updatemode = 1;
    else if (watchdogmode == 2) updatemode = 3;
    else if (watchdogmode == 3) updatemode = 2;
    
    for (NSString* friend in friends)
    {
        NSPredicate *userpred = [NSPredicate predicateWithFormat:@"username = %@" argumentArray:@[friend]];
        NSPredicate *modepred = [NSPredicate predicateWithFormat:@"mode = %@" argumentArray:@[[NSNumber numberWithInteger:updatemode]]];
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userpred,modepred]];
        if (watchdogmode == 1)
        {
            NSPredicate *visiblepred = [NSPredicate predicateWithFormat:@"visibleto CONTAINS %@" argumentArray:@[user.getUsername]];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userpred,modepred,visiblepred]];
        }
        else if (watchdogmode == 3)
        {
            //Get only friends who want you as their guard when in guard mode
            NSPredicate *guardpred = [NSPredicate predicateWithFormat:@"guards CONTAINS %@" argumentArray:@[user.getUsername]];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userpred,modepred,guardpred]];
        }
        /*
         else if (watchdogmode == 2)
         {
         NSPredicate *guardingpred = [NSPredicate predicateWithFormat:@"guarding CONTAINS %@" argumentArray:@[user.getUsername]];
         predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userpred,modepred,guardingpred]];
         }
         */
        
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"User" predicate:predicate];
        
        [publicData performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
            if (!error)
            {
                for (CKRecord* rec in results)
                {
                    if (watchdogmode == 3)
                    {
                        if ([rec valueForKey:@"introuble"] == [NSNumber numberWithInteger:1]) [self friendInTrouble:[rec valueForKey:@"username"]];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addFriendLocationFromUpdate:friend withRecord:rec withMode:updatemode];
                    });
                }
                if (results.count < 1)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (changingmodes) [self finishActivatingMode];
                    });
                }
            }
            else
            {
                NSLog(@"Find User Error");
                if (changingmodes) [self finishActivatingMode];
            }
        }];
    }
    
    NSLog(@"Updated friends locations");
}

-(void)addFriendLocationFromUpdate:(NSString*)friend withRecord:(CKRecord*)userrec withMode:(int)updatemode
{
    float largestdistance = 0;
    
    NSNumber* updatemodeint = [NSNumber numberWithInt:updatemode];
    
    int friendindex = (int)[friends indexOfObject:friend];
    
    [friendsmodes setObject:updatemodeint atIndexedSubscript:friendindex];
    
    CLLocation *location = userrec[@"location"];
    int accuracy = (int) userrec[@"accuracy"];
    NSString* updatetime = userrec[@"time"];
    
    //Get profile picture
    CKAsset *picture = userrec[@"picture"];
    NSData *imageData = [NSData dataWithContentsOfURL:picture.fileURL];
    UIImage *propic = [UIImage imageWithData:imageData];
    if (friendindex > 0) if (friendspictures.count < friendindex+1) for (int i = 0; i <= friendindex; i++) [friendspictures setObject:propic atIndexedSubscript:i];
    [friendspictures setObject:propic atIndexedSubscript:friendindex];
    
    //[self getGeocodeLocation:location];
    
    //[friendlocations addObject:location];
    
    CLLocationDistance distance = [locationManager.location distanceFromLocation:location];
    
    if ((float)distance > largestdistance) largestdistance = (float)distance;
    
    
    
    //Add friend radius to map
    //circlepoly = [self polygonCircleForCoordinate:location.coordinate withMeterRadius:accuracy];
    //[map addOverlay:circlepoly];
    
    for (int i = 0; i < friendslocations.count; i++)
    {
        MGLPointAnnotation *friendannotation = friendslocations[i];
        if (friendannotation.title == [friendsnames objectAtIndex:[friends indexOfObject:friend]])
        {
            friendannotation.coordinate = location.coordinate;
            break;
        }
        
        if (i == friendslocations.count-1)
        {
            // Add new friend annotation
            MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
            point.coordinate = location.coordinate;
            point.title = [friendsnames objectAtIndex:[friends indexOfObject:friend]];
            point.subtitle = [NSString stringWithFormat:@"Updated at %@",updatetime];
            [map addAnnotation:point];
            [friendslocations addObject:point];
        }
    }
    
    if (friendslocations.count < 1)
    {
        // Add new friend annotation
        MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
        point.coordinate = location.coordinate;
        point.title = [friendsnames objectAtIndex:[friends indexOfObject:friend]];
        point.subtitle = [NSString stringWithFormat:@"Updated at %@",updatetime];
        [map addAnnotation:point];
        [friendslocations addObject:point];
    }
    
    if (!sharingbegan)
    {
        [self finishActivatingMode];
    }
    
    if (!sharingbegan && (largestdistance > 1))
    {
        //[self stopFollowingUser];
        double zoomvar = 16;
        if (largestdistance < 5000) zoomvar = 12;
        else if (largestdistance < 10000) zoomvar = 10;
        else if (largestdistance < 50000) zoomvar = 8;
        else if (largestdistance < 100000) zoomvar = 7.2;
        else if (largestdistance < 200000) zoomvar = 5.5;
        
        [map setCenterCoordinate:locationManager.location.coordinate zoomLevel:zoomvar animated:true];
        
        //MGLCoordinateBounds bounds = MGLCoordinateBoundsMake(location.coordinate,locationManager.location.coordinate);
        //[map setVisibleCoordinateBounds:bounds];
        
        sharingbegan = true;
    }
}

- (MGLAnnotationView*)mapView:(MGLMapView *)mapView viewForAnnotation:(id <MGLAnnotation>)annotation
{
    // Only concerned with point annotations
    if (![annotation isKindOfClass:[MGLPointAnnotation class]]) return nil;
    
    // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view
    NSString *reuseIdentifier = annotation.title;
    
    // For better performance, always try to reuse existing annotations
    CustomAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    
    // If there’s no reusable annotation view available, initialize a new one.
    if (!annotationView)
    {
        annotationView = [[CustomAnnotationView alloc] initWithReuseIdentifier:reuseIdentifier];
        annotationView.frame = CGRectMake(0, 0, 40, 40);
        
        //Set Color
        annotationView.backgroundColor = [UIColor colorWithRed:0 green:0.7 blue:1 alpha:1];
        
        [annotationView setImage:[friendspictures objectAtIndex:[friendsnames indexOfObject:annotation.title]]];
    }
    
    return annotationView;
}

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation {
    return YES;
}

-(void)mapView:(MGLMapView *)mapView didSelectAnnotation:(id<MGLAnnotation>)annotation
{
    CLLocationCoordinate2D calloutcoordinate = CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude);
    [map setCenterCoordinate:calloutcoordinate animated:YES];
    
    [self performSelector:@selector(revealCallout:) withObject:annotation afterDelay:0.5];
}

-(void)revealCallout:(id<MGLAnnotation>)annotation
{
    [map selectAnnotation:annotation animated:YES];
}

-(void)removeMapAnnotations
{
    NSMutableArray * annotationsToRemove = [map.annotations mutableCopy];
    [annotationsToRemove removeObject:map.userLocation];
    [map removeAnnotations:annotationsToRemove];
}

-(id<MGLCalloutView>)mapView:(MGLMapView *)mapView calloutViewForAnnotation:(id<MGLAnnotation>)annotation
{
    CustomCalloutView *calloutView = [[CustomCalloutView alloc] init];
    calloutView.representedObject = annotation;
    return calloutView;
}

- (void)mapView:(MGLMapView *)mapView tapOnCalloutForAnnotation:(id<MGLAnnotation>)annotation
{
    // Optionally handle taps on the callout
    NSLog(@"Tapped the callout for: %@", annotation);
    
    // Hide the callout
    [mapView deselectAnnotation:annotation animated:YES];
}

-(IBAction)annotation_address_button_pressed:(UIButton*)sender
{
    /*
    NSString *friend = sender.titleLabel.text;
    //NSString *friendname = [friendsnames objectAtIndex:[friends indexOfObject:friend]];
    
    CLLocation *loc = (CLLocation*)[sharedlocations objectAtIndex:[sharedlocationsfriends indexOfObject:friend]];
    NSString *geolocation = [self getGeocodeLocation:loc];
    
    NSString *messageboxtitle = @"Address Copied!";
    NSString *messageboxdescription = [NSString stringWithFormat:@"%@\r\n\r\n%@",[friendsnames objectAtIndex:[friends indexOfObject:friend]],geolocation];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = geolocation;
    
    [self showMessageBox:messageboxtitle withDescription:messageboxdescription withButtonLabel:@"Ok"];
    */
}

-(void)askForLocationPermissions
{
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [locationManager requestAlwaysAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    map.showsUserLocation = true;
}

-(void)beginFollowingUser
{
    //[map setUserTrackingMode:MKUserTrackingModeFollow animated:true];
    [map setUserTrackingMode:MGLUserTrackingModeFollow animated:true];
}

-(void)stopFollowingUser
{
    //[map setUserTrackingMode:MKUserTrackingModeNone animated:true];
    [map setUserTrackingMode:MGLUserTrackingModeNone animated:true];
}

-(void)mapView:(MGLMapView *)mapView didChangeUserTrackingMode:(MGLUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MGLUserTrackingModeNone)
    {
        [UIView animateWithDuration:.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            followlocationbutton.alpha = 0.4;
            followlocationicon.alpha = 0.6;
        }completion:nil];
    }
    else
    {
        [UIView animateWithDuration:.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            followlocationbutton.alpha = 0;
            followlocationicon.alpha = 0;
        }completion:nil];
    }
}

/*
-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MKUserTrackingModeNone)
    {
        [UIView animateWithDuration:.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            followlocationbutton.alpha = 0.4;
            followlocationicon.alpha = 0.6;
        }completion:nil];
    }
    else
    {
        [UIView animateWithDuration:.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            followlocationbutton.alpha = 0;
            followlocationicon.alpha = 0;
        }completion:nil];
    }
}
*/

//Gestures

-(void)shadeTapGesture:(UITapGestureRecognizer*)tapGestureRecognizer
{
    //CGPoint taplocation = [tapGestureRecognizer locationInView:menu];
    
    if (menuopen) [self closemenu];
    if (optionsopen) [self closeoptions];
    
}

-(void)shadeSwipeUpGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    if (menuopen) [self closemenu];
}

-(void)shadeSwipeDownGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    if (optionsopen) [self closeoptions];
}

-(void)menuTapGesture:(UITapGestureRecognizer*)tapGestureRecognizer
{
    //CGPoint taplocation = [tapGestureRecognizer locationInView:menu];
    
    if (menuopen) [self closemenu];
    else
    {
        switchingmenus = true;
        if (optionsopen) [self closeoptions];
        switchingmenus = false;
        [self openmenu];
    }
    
}

-(void)menuSwipeUpGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    if (menuopen) [self closemenu];
    else
    {
        switchingmenus = true;
        if (optionsopen) [self closeoptions];
        switchingmenus = false;
        [self openmenu];
    }
}

-(void)menuSwipeDownGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    if (!menuopen)
    {
        switchingmenus = true;
        if (optionsopen) [self closeoptions];
        switchingmenus = false;
        [self openmenu];
    }
}

-(void)optionsTapGesture:(UITapGestureRecognizer*)tapGestureRecognizer
{
    CGPoint taplocation = [tapGestureRecognizer locationInView:optionsmenu];
    
    if (taplocation.y > fullheight*0.1) return;
    
    if (optionsopen) [self closeoptions];
    else
    {
        switchingmenus = true;
        if (menuopen) [self closemenu];
        switchingmenus = false;
        [self openoptions];
    }
    
}

-(void)optionsSwipeUpGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    if (!optionsopen)
    {
        switchingmenus = true;
        if (menuopen) [self closemenu];
        switchingmenus = false;
        [self openoptions];
    }
}

-(void)optionsSwipeDownGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    if (optionsopen) [self closeoptions];
    else
    {
        switchingmenus = true;
        if (menuopen) [self closemenu];
        switchingmenus = false;
        [self openoptions];
    }
}

-(void)handleSingleLongPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
}


-(void)handleSingleLeftSwipeGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
}

-(void)handleSingleRightSwipeGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    
    return YES;
}

-(IBAction)sharelocationswitch_changed:(UISwitch*)sender
{
    if (sender.on)
    {
        
    }
    else
    {
        
    }
}

//Springboard Shortcuts
- (void)springboardShortcut:(int)shortcut
{
    watchdogmode = shortcut;
    if (!isLoggedIn) return;
    
    if (watchdogmode == 1) [self activateSharingMode];
    if (watchdogmode == 2) [self activateSafetyMode];
    if (watchdogmode == 3) [self activateGuardMode];
}

//3D Touch
-(void)setSpringboardShortcutItems
{
    //-----------------------------------------------------//
    //---Home screen application icon shortcuts 3d touch---//
    //-----------------------------------------------------//
    if ([UIDevice currentDevice].systemVersion.integerValue < 9) return;
    
    NSMutableArray <UIApplicationShortcutItem *> *updatedShortcutItems = [[NSMutableArray alloc] init];
    
    /*
    UIApplicationShortcutIcon *shortcuticonguard = [UIApplicationShortcutIcon iconWithTemplateImageName:@"springboard_guard.png"];
    UIApplicationShortcutItem *guardshareitem = [[UIApplicationShortcutItem alloc] initWithType:@"3" localizedTitle:@"Guard" localizedSubtitle:nil icon:shortcuticonguard userInfo:nil];
    [updatedShortcutItems addObject:guardshareitem];
    
    UIApplicationShortcutIcon *shortcuticonsafety = [UIApplicationShortcutIcon iconWithTemplateImageName:@"springboard_safety.png"];
    UIApplicationShortcutItem *safetyitem = [[UIApplicationShortcutItem alloc] initWithType:@"2" localizedTitle:@"Safety" localizedSubtitle:nil icon:shortcuticonsafety userInfo:nil];
    [updatedShortcutItems addObject:safetyitem];
     */
    
    UIApplicationShortcutIcon *shortcuticonlocshare = [UIApplicationShortcutIcon iconWithTemplateImageName:@"springboard_sharing.png"];
    UIApplicationShortcutItem *locshareitem = [[UIApplicationShortcutItem alloc] initWithType:@"1" localizedTitle:@"Sharing" localizedSubtitle:nil icon:shortcuticonlocshare userInfo:nil];
    [updatedShortcutItems addObject:locshareitem];
    
    [[UIApplication sharedApplication] setShortcutItems: updatedShortcutItems];
}


//Textfield Delegate Methods

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //Dismiss the keyboard
    [textField resignFirstResponder];
    
    return true;
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    [self logout];
}

-(void)logout
{
    NSLog(@"Facebook Logout");
    isLoggedIn = false;
    
    if (menuopen) [self closemenu];
    if (optionsopen) [self closeoptions];
    [self showLogin];
}

-(void)showLogin
{
    loginmask.hidden = false;
    watchdoglabel.text = @"Safely";
    usernameTextfield.alpha = 0;
    chooseUsernameButton.alpha = 0;
    chooseUsernameButtonLabel.alpha = 0;
    
    //Location Permissions
    [self askForLocationPermissions];
    [map setCenterCoordinate:locationManager.location.coordinate zoomLevel:1600000 animated:true];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        loginButton.alpha = 1;
        loginmask.alpha = 1;
        launchmask.alpha = 0;
        watchdoglabel.alpha = 1;
    }completion:^(BOOL finished){
        launchmask.hidden = true;
    }];
}


//Facebook login button result
-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    startupLabel.alpha = 0;
    
    if (!error)
    {
        launcherrorlabel.text = @"Associating Facebook";
        NSLog(@"%@",@"Associating Facebook");
        
        if ([FBSDKAccessToken currentAccessToken])
        {
            launchmask.alpha = 0;
            launchmask.hidden = false;
            
            [loadingspinner startAnimating];
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                launchmask.alpha = 1;
            }completion:^(BOOL finished){
            }];
            
            [self login:@""];
        }
    }
    else
    {
        NSLog(@"%@",@"Facebook Login Error:");
        NSLog(@"%@",error);
        launcherrorlabel.text = @"Facebook login Error";
        [self showMessageBox:@"Error" withDescription:@"Facebook login error" withButtonLabel:@"Ok"];
    }
}

//UI Methods
-(void)showLoading
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        loadingmask.alpha = 1;
        blurEffectView.alpha = 1;
    }completion:^(BOOL finished){
    }];
}

-(void)hideLoading
{
    [loadingtimer invalidate];
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        loadingmask.alpha = 0;
        blurEffectView.alpha = 0;
    }completion:^(BOOL finished){
    }];
}

-(void)showChooseUsername
{
    watchdoglabel.alpha = 0;
    loginButton.alpha = 0;
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        launchmask.alpha = 0;
    }completion:^(BOOL finished){
        [loadingspinner stopAnimating];
        launchmask.hidden = true;
        
        watchdoglabel.text = @"Choose Username";
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            watchdoglabel.alpha = 1;
            chooseUsernameButton.alpha = 1;
            chooseUsernameButtonLabel.alpha = 1;
            usernameTextfield.alpha = 1;
        }completion:^(BOOL finished){
            
        }];
    }];
}

-(void)showFriends
{
    editingfriends = true;
    [friendslistedit reloadData];
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        friendsmask.alpha = 1;
        friendstype.alpha = 1;
        friendsclosebutton.alpha = 1;
        friendslistedit.alpha = 1;
        friendsoption1button.alpha = 1;
        friendsoption2button.alpha = 1;
    }completion:nil];
    
    [self disableFriendsOptionButton1];
    
    [self updateFriendsLists];
}

-(void)hideFriends
{
    editingfriends = false;
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        friendsmask.alpha = 0;
        friendstype.alpha = 0;
        friendsclosebutton.alpha = 0;
        friendslistedit.alpha = 0;
        friendsoption1button.alpha = 0;
        friendsoption2button.alpha = 0;
    }completion:nil];
}

-(IBAction)chooseUsernameButtonDown:(id)sender
{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        chooseUsernameButton.backgroundColor = [UIColor colorWithRed:0 green:.85 blue:1 alpha:1];
    }completion:^(BOOL finished){
        
    }];
}

-(IBAction)chooseUsernameButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        chooseUsernameButton.backgroundColor = [UIColor colorWithRed:0 green:.7 blue:1 alpha:1];
    }completion:^(BOOL finished){
    
    }];
    
    [usernameTextfield resignFirstResponder];
    
    launchmask.alpha = 0;
    launchmask.hidden = false;
    
    [loadingspinner startAnimating];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        launchmask.alpha = 1;
    }completion:^(BOOL finished){
        loginmask.alpha = 0;
        loginmask.hidden = true;
    }];
    
    launcherrorlabel.text = @"Logging in with new username";
    NSLog(@"%@",@"Logging in with new username");
    
    [self login:usernameTextfield.text];
}

-(void)login:(NSString*)username
{
    startupLabel.alpha = 0;
    
    launcherrorlabel.text = @"Logging into Safely";
    
    //Check if facebook is logged in
    if (![FBSDKAccessToken currentAccessToken])
    {
        NSLog(@"%@",@"Facebook Login Error (2)");
        launcherrorlabel.text = @"Login Error";
        loginmask.alpha = 1;
        return;
    }
    
    [loadingspinner startAnimating];
    
    [retryLoginTimer invalidate];
    
    launcherrorlabel.text = @"Logging into Facebook";
    
    //Get Facebook User
    NSDictionary *params = @{@"fields": @"id, name, picture.width(150).height(150)"};
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
    {
        launcherrorlabel.text = @"Logging into Facebook (completion)";
         if (!error)
         {
             NSLog(@"Facebook Login Success!");
             launcherrorlabel.text = @"Facebook User Attached";
             
             facebookid = [result objectForKey:@"id"];
             [defaults setObject:facebookid forKey:@"facebookid"];
             NSLog(@"%@%@",@"FBID: ",facebookid);
             
             //Get profile picture
             NSString *propicurlstring = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
             NSURL *propicurl = [NSURL URLWithString:propicurlstring];
             NSData *propicdata = [NSData dataWithContentsOfURL:propicurl];
             UIImage *propic = [[UIImage alloc] initWithData:propicdata];
             
             //Make or find CloudKit Account
             [self initUser:username withFBID:facebookid withPropic:propic];
         }
         else
         {
             launcherrorlabel.text = @"Facebook Error";
             if ([[error localizedDescription] containsString:@"The Internet connection appears to be offline"])
             {
                 if ([launcherrorlabel.text isEqualToString:@""])
                 {
                     NSLog(@"Facebook Login Error: The Internet connection appears to be offline");
                     
                     //temp
                     //[self enterUI];
                 }
                 retryLoginTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(login:) userInfo:username repeats:true];
                 launcherrorlabel.text = @"No Internet Connection";
             }
             else
             {
                 NSLog(@"Facebook Graph Request Connection Error%@",error);
                 launcherrorlabel.text = [error localizedDescription];
             }
         }
     }];
}

-(void)enterUI
{
    //If app hasn't been started yet, do everything for the first time
    if ([defaults integerForKey:@"mode"] == 0)
    {
        [defaults setInteger:1 forKey:@"mode"];
    }
    
    watchdogmode = (int)[defaults integerForKey:@"mode"];
    
    if (watchdogmode == 1) [self activateSharingMode];
    if (watchdogmode == 2) [self activateSafetyMode];
    if (watchdogmode == 3) [self activateGuardMode];
    
    [self beginFollowingUser];
    
    [self setSpringboardShortcutItems];
    
    updatefriendsliststimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(updateFriendsLists) userInfo:nil repeats:true];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        loginmask.alpha = 0;
        launchmask.alpha = 0;
        loginButton.alpha = 0;
    }completion:^(BOOL finished){
        loginmask.hidden = true;
        launchmask.hidden = true;
        chooseUsernameButton.alpha = 1;
        chooseUsernameButtonLabel.alpha = 1;
    }];
    
    [loadingspinner stopAnimating];
}

//CloudKit
-(void)updateUserRecord
{
    if (userrecordupdating) return;
    
    userrecordupdating = true;
    
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *publicData = container.publicCloudDatabase;
    
    [publicData saveRecord:userrecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error)
        {
            NSLog(@"User Record Updated");
            userrecordupdating = false;
        }
        else
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookid = %@" argumentArray:@[facebookid]];
            CKQuery *query = [[CKQuery alloc] initWithRecordType:@"User" predicate:predicate];
            
            [publicData performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
                if (!error)
                {
                    for (CKRecord* userrec in results)
                    {
                        userrecord = userrec;
                        [publicData saveRecord:userrecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                            if (!error)
                            {
                                //NSLog(@"User Record Found and Updated");
                                userrecordupdating = false;
                            }
                            else
                            {
                                NSLog(@"User Record Update Failed: %@",error);
                                userrecordupdating = false;
                            }
                        }];
                    }
                }
            }];
        }
    }];
}

-(void)initUser:(NSString*)user_username withFBID:(NSString*)user_facebookid withPropic:(UIImage*)user_propic
{
    launcherrorlabel.text = @"Initializing User";
    NSLog(@"%@",@"Initializing User");
    NSLog(@"%@%@",@"Username: ",user_username);
    NSLog(@"%@%@",@"FBID: ",user_facebookid);
    
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *publicData = container.publicCloudDatabase;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookid = %@" argumentArray:@[user_facebookid]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"User" predicate:predicate];
    
    __block WatchdogUser *wuser;
    __block bool usernameneeded = false;
    
    [publicData performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (!error)
        {
            for (CKRecord* userrec in results)
            {
                wuser = [[WatchdogUser alloc] init];
                [wuser setUsername:userrec[@"username"]];
                [wuser setFacebookID:userrec[@"facebookid"]];
                [wuser setPropic:user_propic];
                
                NSLog(@"User Found: %@ for FBID: %@", [wuser getUsername], [wuser getFacebookID]);
                
                //Save profile picture to cloudkit user record profile
                NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
                NSString *imageFilePath = [documentDirectory stringByAppendingPathComponent:@"lastimage"];
                [UIImagePNGRepresentation(user_propic) writeToFile:imageFilePath atomically:true];
                CKAsset *asset = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:imageFilePath]];
                [userrec setObject:asset forKey:@"picture"];
                
                userrecord = userrec;
                user = wuser;
                
                [self updateUserRecord];
                NSLog(@"CloudKit Login Success!");
                
                [self postLoginTasks];
                
                isLoggedIn = true;
                
                launcherrorlabel.text = @"Safely Account Found";
            }
        }
        else
        {
            launcherrorlabel.text = [error localizedDescription];
            NSLog(@"%@%@",@"Public data error: ",error);
        }
        
        if ((results.count == 0) && ![user_username isEqualToString:@""])
        {
            launcherrorlabel.text = @"Creating Safely Account";
            
            NSLog(@"No users found, creating new user");
            CKRecord *record = [[CKRecord alloc] initWithRecordType:@"User"];
            
            [record setValue:user_facebookid forKey:@"facebookid"];
            [record setValue:user_username forKey:@"username"];
            
            //Save profile picture to cloudkit user record profile
            NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
            NSString *imageFilePath = [documentDirectory stringByAppendingPathComponent:@"lastimage"];
            [UIImagePNGRepresentation(user_propic) writeToFile:imageFilePath atomically:true];
            CKAsset *asset = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:imageFilePath]];
            [record setObject:asset forKey:@"picture"];
            
            [publicData saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                if (!error)
                {
                    launcherrorlabel.text = @"Creating New User";
                    
                    NSLog(@"New User Created:%@ with Facebook ID:%@",user_username,user_facebookid);
                    NSLog(@"CloudKit Login Success!");
                    
                    wuser = [[WatchdogUser alloc] init];
                    
                    [wuser setUsername:user_username];
                    [wuser setFacebookID:user_facebookid];
                    [wuser setPropic:user_propic];
                    
                    userrecord = record;
                    user = wuser;
                    
                    isLoggedIn = true;
                    
                    [self postLoginTasks];
                }
                else
                {
                    launcherrorlabel.text = @"Create User Error";
                    NSLog(@"%@%@",@"Create User Error: ",error);
                }
            }];
        }
        
        if ([user_username isEqualToString:@""] && (results.count == 0)) usernameneeded = true;
        
    }];
    
    while(!isLoggedIn)
    {
        if (usernameneeded)
        {
            [self showChooseUsername];
            return;
        }
        else
        {
            
        }
    }
    
    NSLog(@"Username:%@ FacebookID:%@",[user getUsername],facebookid);
    
    [friendslist reloadData];
    
    [self enterUI];
}

-(void)postLoginTasks
{
    //Load user's lists
    friends = userrecord[@"friends"];
    friendsnames = userrecord[@"friendsnames"];
    friendoutrequests = userrecord[@"friendoutrequests"];
    friendinrequests = userrecord[@"friendinrequests"];
    blockedusers = userrecord[@"blockedusers"];
    
    for (int i = 0; i < friends.count; i++)
    {
        //Add placeholder pictures
        friendspictures[i] = [[UIImage alloc] init];
        
        //Add placeholder modes
        NSNumber* integ = [NSNumber numberWithInt:0];
        [friendsmodes addObject:integ];
    }
    
    //If app hasn't been started yet and the user is new
    if ([defaults integerForKey:@"mode"] == 0)
    {
        [self showMessageBox:@"Welcome" withDescription:@"Welcome to Safely! To get started, go to 'Manage Friends' in the Options menu below and add a friend!" withButtonLabel:@"Let's do this"];
    }
}

-(WatchdogUser*)findUserWithUsername:(NSString*)user_username
{
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *publicData = container.publicCloudDatabase;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@" argumentArray:@[user_username]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"User" predicate:predicate];
    
    __block WatchdogUser *wuser;
    
    [publicData performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (!error)
        {
            for (CKRecord* user in results)
            {
                wuser = [[WatchdogUser alloc] init];
                [wuser setUsername:user[@"username"]];
                [wuser setFacebookID:user[@"facebookid"]];
                
                NSLog(@"User Found %@ in %u results", [wuser getUsername], (uint)results.count);
            }
            if (results.count < 1) NSLog(@"No User Found");
        }
        else
        {
            NSLog(@"Find User Error");
        }
    }];
    
    return wuser;
}

-(WatchdogUser*)findUserWithFBID:(NSString*)user_facebookid
{
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *publicData = container.publicCloudDatabase;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookid = %@" argumentArray:@[user_facebookid]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"User" predicate:predicate];
    
    __block WatchdogUser *wuser = [[WatchdogUser alloc] init];;
    
    [publicData performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (!error)
        {
            for (CKRecord* user in results)
            {
                [wuser setUsername:user[@"username"]];
                [wuser setFacebookID:user[@"facebookid"]];
                
                NSLog(@"User Found %@ in %u results", [wuser getUsername], (uint)results.count);
                
                if (results.count < 1) NSLog(@"No User Found");
            }
        }
        else NSLog(@"Find User Error");
    }];
    
    return wuser;
}

-(void)subscribeAsGuard
{
    return;
    
    for (NSString* friend in friends)
    {
        NSPredicate *userpred = [NSPredicate predicateWithFormat:@"username = %@" argumentArray:@[friend]];
        NSPredicate *modepred = [NSPredicate predicateWithFormat:@"mode = %i" argumentArray:@[[NSNumber numberWithInteger:2]]];
        NSPredicate *guardpred = [NSPredicate predicateWithFormat:@"guards contains %@",[user getUsername]];
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userpred,modepred,guardpred]];
        CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:@"User" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordUpdate];
        
        CKContainer *container = [CKContainer defaultContainer];
        CKDatabase *publicData = container.publicCloudDatabase;
        
        if ([subscriptionid isEqualToString:@""])
        {
            [publicData saveSubscription:subscription completionHandler:^(CKSubscription * _Nullable subscription, NSError * _Nullable error) {
                if (!error)
                {
                    subscriptionid = subscription.subscriptionID;
                }
                else
                {
                    [self showMessageBox:@"Error" withDescription:[error localizedDescription] withButtonLabel:@"Ok"];
                    NSLog(@"Guard Subscription Error: %@",error);
                }
            }];
        }
        else
        {
            [publicData deleteSubscriptionWithID:subscriptionid completionHandler:^(NSString * _Nullable subscriptionID, NSError * _Nullable error) {
                if (!error)
                {
                    subscriptionid = @"";
                }
                else
                {
                    NSLog(@"Guard Unsubscribe Error: %@",error);
                }
            }];
        }
    }
}

//AV Foundations

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason)
    {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //NSLog(@"Headphones plugged in");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"Headphones Removed");
            [self panicWithCountdown];
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
}

-(void)beginMonitoringHeadphoneState
{
    [AVAudioSession sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
}

-(void)endMonitoringHeadphoneState
{
    [AVAudioSession sharedInstance];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

//Tableview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (friendstype.selectedSegmentIndex == 1) return friendinrequests.count;
    else return friendsnames.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil];
    
    if (friendstype.selectedSegmentIndex == 1)
    {
        //****TO DO -- FIND FRIENDS WHO HAVE SENT YOU A REQUEST*****//
        //look at their outgoing request list for your name
        cell.textLabel.text = [friendinrequests objectAtIndex:indexPath.row];
        
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:fontsize-6];
        cell.imageView.image = [UIImage imageNamed:@"checkbox_unchecked.png"];
        cell.imageView.highlightedImage = [UIImage imageNamed:@"checkbox_checked.png"];
        UIView *backgroundview = [[UIView alloc] initWithFrame:cell.frame];
        backgroundview.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        cell.selectedBackgroundView = backgroundview;
        
        return cell;
    }
    else if (renamingfriends)
    {
        cell.textLabel.text = @"";
        UITextField *renametextfield = [[UITextField alloc] initWithFrame:CGRectMake(54,0,fullwidth*0.6,fullheight*0.045)];
        renametextfield.delegate = self;
        renametextfield.borderStyle = UITextBorderStyleRoundedRect;
        renametextfield.layer.cornerRadius=8.0f;
        renametextfield.layer.masksToBounds=YES;
        renametextfield.layer.borderColor=[[UIColor colorWithWhite:1 alpha:1]CGColor];
        renametextfield.layer.borderWidth= 0.5f;
        renametextfield.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        renametextfield.textColor = [UIColor colorWithWhite:1 alpha:1];
        renametextfield.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontsize];
        renametextfield.text = [friendsnames objectAtIndex:indexPath.row];
        renametextfield.placeholder = [friendsnames objectAtIndex:indexPath.row];
        renametextfield.returnKeyType = UIReturnKeyDone;
        if (indexPath.row == 0) [renametextfield becomeFirstResponder];
        //[renametextfield addTarget:self action:@selector(renameTextField_TextChanged:) forControlEvents:UIControlEventEditingChanged];
        [cell addSubview:renametextfield];
    }
    else cell.textLabel.text = [friendsnames objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:fontsize-6];
    cell.imageView.image = [UIImage imageNamed:@"checkbox_unchecked.png"];
    cell.imageView.highlightedImage = [UIImage imageNamed:@"checkbox_checked.png"];
    UIView *backgroundview = [[UIView alloc] initWithFrame:cell.frame];
    backgroundview.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    cell.selectedBackgroundView = backgroundview;
    
    cell.selected = selectedfriends[indexPath.row][watchdogmode];
    
    //Get selected cells
    //NSArray *selectedCells = [self.tableView indexPathsForSelectedRows];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If at least one item is selected
    if ([tableView indexPathsForSelectedRows].count > 0)
    {
        if (editingfriends)
        {
            if (friendstype.selectedSegmentIndex == 1)
            {
                selectedrequests[indexPath.row] = true;
                [self enableFriendsOptionButton1];
                [self enableFriendsOptionButton2];
            }
            else
            {
                selectedfriendsedit[indexPath.row] = true;
                [self enableFriendsOptionButton1];
            }
        }
        else
        {
            selectedfriends[indexPath.row][watchdogmode] = true;
            
            selectedfriendsupdatetimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateWithSelectedFriends) userInfo:nil repeats:false];
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingfriends)
    {
        if (friendstype.selectedSegmentIndex == 1) selectedrequests[indexPath.row] = false;
        else selectedfriendsedit[indexPath.row] = false;
    }
    else
    {
        selectedfriends[indexPath.row][watchdogmode] = false;
        
        selectedfriendsupdatetimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateWithSelectedFriends) userInfo:nil repeats:false];
    }
    
    //If nothing is selected
    if ([tableView indexPathsForSelectedRows].count > 0)
    {
        if (friendstype.selectedSegmentIndex == 1)
        {
            [self disableFriendsOptionButton1];
            [self disableFriendsOptionButton2];
        }
        else
        {
            [self disableFriendsOptionButton1];
            [self enableFriendsOptionButton2];
        }
    }
}

-(void)updateWithSelectedFriends
{
    if (watchdogmode == 1)
    {
        NSMutableArray *visibleto = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < friends.count; i++)
        {
            if (selectedfriends[i][watchdogmode])
            {
                //Allow this friend to see your location
                [visibleto addObject:friends[i]];
            }
        }
        
        [userrecord setValue:visibleto forKey:@"visibleto"];
        [self updateUserRecord];
    }
    else if (watchdogmode == 2)
    {
        [guards removeAllObjects];
        
        for (int i = 0; i < friends.count; i++)
        {
            if (selectedfriends[i][watchdogmode])
            {
                //Add this friend to your guard list so they can see you in guard mode
                [guards addObject:friends[i]];
            }
        }
        
        [userrecord setValue:guards forKey:@"guards"];
        [self updateUserRecord];
    }
}

//Safety Methods

-(void)panic
{
    [userrecord setValue:[NSNumber numberWithInteger:1] forKey:@"introuble"];
    [self updateUserRecord];
}

-(void)panicWithCountdown
{
    
}

-(void)friendInTrouble:(NSString*)friendusername
{
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        troublemask.alpha = 1;
    }completion:nil];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
}

@end
