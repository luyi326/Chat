#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface iOSChatClientViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, NSXMLParserDelegate, CLLocationManagerDelegate, UITextFieldDelegate>	{
	IBOutlet UITextField *messageText;
	IBOutlet UIButton *sendButton;
    IBOutlet UIButton *refreshButton;
	IBOutlet UITableView *messageList;
	int lastId;
    
    //Lat Long
    IBOutlet UITextField *latitudeTextField;
    IBOutlet UITextField *longitudeTextField;
    IBOutlet UITextField *accuracyTextField;
    CLLocationManager *lm;
    //
	
	NSMutableData *receivedData;
	
	NSMutableArray *messages;
	
	NSTimer *timer;
	int functioncalled;
    
	NSXMLParser *chatParser;
	NSString *msgAdded;
	NSMutableString *msgUser;
	NSMutableString *msgText;
	int msgId;
	Boolean inText;
	Boolean inUser;
    float latv;
    float lngv;
}

@property (nonatomic,retain) UITextField *messageText;
@property (nonatomic,retain) UIButton *sendButton;
@property (nonatomic,retain) UIButton *refreshButton;
@property (nonatomic,retain) UITableView *messageList;

- (IBAction)sendClicked:(id)sender;
- (IBAction)refreshClicked:(id)sender;

@property (retain, nonatomic) UITextField *latitudeTextField;
@property (retain, nonatomic) UITextField *longitudeTextField;
@property (retain, nonatomic) UITextField *accuracyTextField;

//UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"reloading" 
  //                                            message:@"reload"
    //                                         delegate:nil
      //                              cancelButtonTitle:@"ok" otherButtonTitles:nil];
//[alert show];
//[alert release];

@end

