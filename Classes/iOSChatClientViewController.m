#import "iOSChatClientViewController.h"

@implementation iOSChatClientViewController

@synthesize messageText, sendButton, refreshButton, messageList, latitudeTextField, longitudeTextField, accuracyTextField;


static CGFloat const  kAccountDetailFontSize = 14.0;
static int const DATELABEL_TAG = 1;
static int const MESSAGELABEL_TAG = 2;
static int const IMAGEVIEW_TAG_1 = 3;
static int const IMAGEVIEW_TAG_2 = 4;
static int const IMAGEVIEW_TAG_3 = 5;
static int const IMAGEVIEW_TAG_4 = 6;
static int const IMAGEVIEW_TAG_5 = 7;
static int const IMAGEVIEW_TAG_6 = 8;
static int const IMAGEVIEW_TAG_7 = 9;
static int const IMAGEVIEW_TAG_8 = 10;
static int const IMAGEVIEW_TAG_9 = 11;

int bubbleFragment_width, bubbleFragment_height;
int bubble_width;
int bubble_x, bubble_y;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		lastId = 0;
		chatParser = NULL;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [lm release];
    [latitudeTextField release];
    [longitudeTextField release];
    [accuracyTextField release];
    [super dealloc];
}

// Get message for the viewcontroller la
- (void)getNewMessages {
    functioncalled=1;
    float latget, lngget;
    latget=[latitudeTextField.text floatValue];
    lngget=[longitudeTextField.text floatValue];
	NSString *url = [NSString stringWithFormat:@"http://www.edushoplist.com/chat/messages.php?past=%ld&lat=%f&lng=%f",
					 lastId,latget, lngget ];

	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];  
    if (conn)
    {  
        receivedData = [[NSMutableData data] retain];  

    }   
    else   
    {  
    
    }  
}


//Refresh message for viewcontroller reaching area
- (void)refreshNewMessages {
    functioncalled=1;
    [messages removeAllObjects];
    [messageList reloadData];
    float latget, lngget;
    latget=[latitudeTextField.text floatValue];
    lngget=[longitudeTextField.text floatValue];
	NSString *url = [NSString stringWithFormat:@"http://www.edushoplist.com/chat/messages.php?past=%ld&lat=%f&lng=%f",
					 0,latget, lngget ];
    
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];  
    if (conn)
    {  
        receivedData = [[NSMutableData data] retain];  
    }   
    else   
    {  
   
    }    
}


//when timer n secs counted, call getNewmessage again
- (void)timerCallback {
    if (functioncalled==0)
    {
	[self getNewMessages];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response  
{  
    [receivedData setLength:0];  
}  

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  
{  
    [receivedData appendData:data];  
}  

- (void)connectionDidFinishLoading:(NSURLConnection *)connection  
{  
	if (chatParser)
        chatParser=0;
	
	if ( messages == nil )
		messages = [[NSMutableArray alloc] init];

	chatParser = [[NSXMLParser alloc] initWithData:receivedData];
	[chatParser setDelegate:self];
	[chatParser parse];

	[receivedData release];  
    
	[messageList reloadData];
	
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
											[self methodSignatureForSelector: @selector(timerCallback)]];
	[invocation setTarget:self];
	[invocation setSelector:@selector(timerCallback)];
	timer = [NSTimer scheduledTimerWithTimeInterval:0.5 invocation:invocation repeats:NO];
    functioncalled=0;
}  

// XML Parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ( [elementName isEqualToString:@"message"] ) {
		msgAdded = [[attributeDict objectForKey:@"added"] retain];
		msgId = [[attributeDict objectForKey:@"id"] intValue];
		msgUser = [[NSMutableString alloc] init];
		msgText = [[NSMutableString alloc] init];
		inUser = NO;
		inText = NO;
	}
	if ( [elementName isEqualToString:@"user"] ) {
		inUser = YES;
	}
	if ( [elementName isEqualToString:@"text"] ) {
		inText = YES;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ( inUser ) {
		[msgUser appendString:string];
	}
	if ( inText ) {
		[msgText appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ( [elementName isEqualToString:@"message"] ) {
        
		[messages addObject:msgText];
		
        
        //---add items---
        //[messages addObject:@"Hello there!"];
        
        
		lastId = msgId;
		
		[msgAdded release];
		[msgUser release];
		[msgText release];
	}
	if ( [elementName isEqualToString:@"user"] ) {
		inUser = NO;
	}
	if ( [elementName isEqualToString:@"text"] ) {
		inText = NO;
	}
}

// tableview 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)myTableView numberOfRowsInSection:(NSInteger)section {
	return ( messages == nil ) ? 0 : [messages count];
}


//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [messages count];
//}



//---calculate the height for the message---
-(CGFloat) labelHeight:(NSString *) text {
	CGSize maximumLabelSize = CGSizeMake((bubbleFragment_width * 3) - 25,9999);
	CGSize expectedLabelSize = [text sizeWithFont:[UIFont systemFontOfSize: kAccountDetailFontSize] 
								constrainedToSize:maximumLabelSize 
									lineBreakMode:UILineBreakModeWordWrap]; 
	return expectedLabelSize.height;
}

//---returns the height for the table view row---
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  
  	int labelHeight = [self labelHeight:[messages objectAtIndex:indexPath.row]];
	labelHeight -= bubbleFragment_height;
	if (labelHeight<0) labelHeight = 0;
    
	return (bubble_y + bubbleFragment_height * 2 + labelHeight) + 5;	
}  



- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	UILabel* dateLabel = nil;
    UILabel* messageLabel = nil;
	UIImageView *imageView_top_left = nil;
	UIImageView *imageView_top_middle = nil;
	UIImageView *imageView_top_right = nil;
    
	UIImageView *imageView_middle_left = nil;
	UIImageView *imageView_middle_right = nil;
	UIImageView *imageView_middle_middle = nil;
	
	UIImageView *imageView_bottom_left = nil;
	UIImageView *imageView_bottom_middle = nil;
	UIImageView *imageView_bottom_right = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        
		//---date---
		dateLabel = [[[UILabel alloc] init] autorelease];
        dateLabel.tag = DATELABEL_TAG;
		[cell.contentView addSubview: dateLabel];
        
        //---top left---
		imageView_top_left = [[[UIImageView alloc] init] autorelease];
        imageView_top_left.tag = IMAGEVIEW_TAG_1;		
        [cell.contentView addSubview: imageView_top_left];
		
		//---top middle---
		imageView_top_middle = [[[UIImageView alloc] init] autorelease];
        imageView_top_middle.tag = IMAGEVIEW_TAG_2;
        [cell.contentView addSubview: imageView_top_middle];
		
		//---top right---
		imageView_top_right = [[[UIImageView alloc] init] autorelease];
        imageView_top_right.tag = IMAGEVIEW_TAG_3;
		[cell.contentView addSubview: imageView_top_right];
        
		//---middle left---
		imageView_middle_left = [[[UIImageView alloc] init] autorelease];
        imageView_middle_left.tag = IMAGEVIEW_TAG_4;
        [cell.contentView addSubview: imageView_middle_left];
		
		//---middle middle---
		imageView_middle_middle = [[[UIImageView alloc] init] autorelease];
        imageView_middle_middle.tag = IMAGEVIEW_TAG_5;
        [cell.contentView addSubview: imageView_middle_middle];
		
		//---middle right---
		imageView_middle_right = [[[UIImageView alloc] init] autorelease];
        imageView_middle_right.tag = IMAGEVIEW_TAG_6;
		[cell.contentView addSubview: imageView_middle_right];
		
		//---bottom left---
		imageView_bottom_left = [[[UIImageView alloc] init] autorelease];
        imageView_bottom_left.tag = IMAGEVIEW_TAG_7;
        [cell.contentView addSubview: imageView_bottom_left];
		
		//---bottom middle---
		imageView_bottom_middle = [[[UIImageView alloc] init] autorelease];
        imageView_bottom_middle.tag = IMAGEVIEW_TAG_8;
        [cell.contentView addSubview: imageView_bottom_middle];
		
		//---bottom right---
		imageView_bottom_right = [[[UIImageView alloc] init] autorelease];
        imageView_bottom_right.tag = IMAGEVIEW_TAG_9;
        [cell.contentView addSubview: imageView_bottom_right];
		
		//---message---
        messageLabel = [[[UILabel alloc] init] autorelease];
        messageLabel.tag = MESSAGELABEL_TAG;		
        [cell.contentView addSubview: messageLabel];
        
		//---set the images to display for each UIImageView---
		imageView_top_left.image = [UIImage imageNamed:@"bubble_top_left.png"];
		imageView_top_middle.image = [UIImage imageNamed:@"bubble_top_middle.png"];
		imageView_top_right.image = [UIImage imageNamed:@"bubble_top_right.png"];
		
		imageView_middle_left.image = [UIImage imageNamed:@"bubble_middle_left.png"];
		imageView_middle_middle.image = [UIImage imageNamed:@"bubble_middle_middle.png"];
		imageView_middle_right.image = [UIImage imageNamed:@"bubble_middle_right.png"];
		
		imageView_bottom_left.image = [UIImage imageNamed:@"bubble_bottom_left.png"];
		imageView_bottom_middle.image = [UIImage imageNamed:@"bubble_bottom_middle.png"];
		imageView_bottom_right.image = [UIImage imageNamed:@"bubble_bottom_right.png"];		
		
	} else {		
		//---reuse the old views---		
        dateLabel = (UILabel*)[cell.contentView viewWithTag: DATELABEL_TAG];
        messageLabel = (UILabel*)[cell.contentView viewWithTag: MESSAGELABEL_TAG];		
		
		imageView_top_left = (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_1];
		imageView_top_middle = (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_2];
		imageView_top_right = (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_3];
        
		imageView_middle_left = (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_4];
		imageView_middle_middle = (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_5];
		imageView_middle_right = (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_6];
        
		imageView_bottom_left = (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_7];
		imageView_bottom_middle = (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_8];
		imageView_bottom_right = (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_9];				
	}
	
	//---calculate the height for the label---
	int labelHeight = [self labelHeight:[messages objectAtIndex:indexPath.row]];
	labelHeight -= bubbleFragment_height;
	if (labelHeight<0) labelHeight = 0;
	
	
	//---you can customize the look and feel for the date for each message here---
	dateLabel.frame = CGRectMake(0.0, 0.0, 200, 15.0);
	dateLabel.font = [UIFont boldSystemFontOfSize: kAccountDetailFontSize];
	dateLabel.textAlignment = UITextAlignmentLeft;
	dateLabel.textColor = [UIColor darkGrayColor];
	dateLabel.backgroundColor = [UIColor clearColor];
    
    //---top left---
	imageView_top_left.frame = CGRectMake(bubble_x, bubble_y, bubbleFragment_width, bubbleFragment_height);		
	//---top middle---
	imageView_top_middle.frame = CGRectMake(bubble_x + bubbleFragment_width, bubble_y, bubbleFragment_width, bubbleFragment_height);        
	//---top right---
	imageView_top_right.frame = CGRectMake(bubble_x + (bubbleFragment_width * 2), bubble_y, bubbleFragment_width, bubbleFragment_height);		
	//---middle left---
	imageView_middle_left.frame = CGRectMake(bubble_x, bubble_y + bubbleFragment_height, bubbleFragment_width, labelHeight);		
	//---middle middle---
	imageView_middle_middle.frame = CGRectMake(bubble_x + bubbleFragment_width, bubble_y + bubbleFragment_height, bubbleFragment_width, labelHeight);		
	//---middle right---
	imageView_middle_right.frame = CGRectMake(bubble_x + (bubbleFragment_width * 2), bubble_y + bubbleFragment_height, bubbleFragment_width, labelHeight);		
	//---bottom left---
	imageView_bottom_left.frame = CGRectMake(bubble_x, bubble_y + bubbleFragment_height + labelHeight, bubbleFragment_width, bubbleFragment_height ); 		
	//---bottom middle---
	imageView_bottom_middle.frame = CGRectMake(bubble_x + bubbleFragment_width, bubble_y + bubbleFragment_height + labelHeight, bubbleFragment_width, bubbleFragment_height);		
	//---bottom right---
	imageView_bottom_right.frame = CGRectMake(bubble_x + (bubbleFragment_width * 2), bubble_y + bubbleFragment_height + labelHeight, bubbleFragment_width, bubbleFragment_height );
    
	//---you can customize the look and feel for each message here---	
	messageLabel.frame = CGRectMake(bubble_x + 10, bubble_y + 5, (bubbleFragment_width * 3) - 25, (bubbleFragment_height * 2) + labelHeight - 10);
	messageLabel.font = [UIFont systemFontOfSize:kAccountDetailFontSize];		
    messageLabel.textAlignment = UITextAlignmentCenter;
    messageLabel.textColor = [UIColor darkTextColor];
	messageLabel.numberOfLines = 0; //---display multiple lines---
	messageLabel.backgroundColor = [UIColor clearColor];
	messageLabel.lineBreakMode = UILineBreakModeWordWrap;		
    
    messageLabel.text = [messages objectAtIndex:messages.count-1- indexPath.row];	//bottom to top
    
    return cell;
}
	
// message to the server

- (IBAction)sendClicked:(id)sender {
	[messageText resignFirstResponder];
    [latitudeTextField resignFirstResponder];
    [longitudeTextField resignFirstResponder];
	if ( [messageText.text length] > 0 ) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSString *url = [NSString stringWithFormat:@"http://www.edushoplist.com/chat/add.php"];
		
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
		[request setURL:[NSURL URLWithString:url]];
		[request setHTTPMethod:@"POST"];
		
		NSMutableData *body = [NSMutableData data];
		[body appendData:[[NSString stringWithFormat:@"user=%@&message=%@&lat=%@&lng=%@", 
						   [defaults stringForKey:@"user_preference"], 
						   messageText.text, latitudeTextField.text, longitudeTextField.text] dataUsingEncoding:NSUTF8StringEncoding]];
		[request setHTTPBody:body];
		
		NSHTTPURLResponse *response = nil;
		NSError *error = [[[NSError alloc] init] autorelease];
		[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		[self getNewMessages];  //This line cause multiple entries appear for some reason ---Peter
	}
	
	messageText.text = @"";
}

-(IBAction)refreshClicked:(id)sender{
    if (functioncalled==0)
    {
    [self refreshNewMessages];
    }
}

// The inital loader

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *lat;
    //GPS
    lm = [[CLLocationManager alloc] init];
    if ([lm locationServicesEnabled]) {
        lm.delegate = self;
        lm.desiredAccuracy = kCLLocationAccuracyBest;
        lm.distanceFilter = 1000.0f;
        [lm startUpdatingLocation];
    }

    //GPS
    lat=latitudeTextField.text;
	messageList.dataSource = self;
	messageList.delegate = self;
    lat=latitudeTextField.text;
	
    //---location to display the bubble fragment--- 
	bubble_x = 10;
	bubble_y = 20;
	
	//---size of the bubble fragment---
	bubbleFragment_width = 56;
	bubbleFragment_height = 32;
	
	//---width of the bubble---
    //	bubble_width = 300;
	
	//---contains the messages---
	//messages = [[NSMutableArray alloc] init];

	//---add items---
	//[messages addObject:@"Hello there!"];
    
	[self getNewMessages];
}

//The Lat, Long
- (void) locationManager: (CLLocationManager *) manager
     didUpdateToLocation: (CLLocation *) newLocation
            fromLocation: (CLLocation *) oldLocation{
    NSString *lat = [[NSString alloc] initWithFormat:@"%g",
                     newLocation.coordinate.latitude];
    latitudeTextField.text = lat;
    NSString *lng = [[NSString alloc] initWithFormat:@"%g",
                     newLocation.coordinate.longitude];
    longitudeTextField.text = lng;
    NSString *acc = [[NSString alloc] initWithFormat:@"%g",
                     newLocation.horizontalAccuracy];
    accuracyTextField.text = acc;
    [acc release];
    [lat release];
    [lng release];
}

- (void) locationManager: (CLLocationManager *) manager
        didFailWithError: (NSError *) error {
    NSString *msg = [[NSString alloc]
                     initWithString:@"Error obtaining location"];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error"
                          message:msg
                          delegate:nil
                          cancelButtonTitle: @"Done"
                          otherButtonTitles:nil];
    [alert show];
    [msg release];
    [alert release];
}
//Lat, Long



@end
