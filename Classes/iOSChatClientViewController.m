#import "iOSChatClientViewController.h"

@implementation iOSChatClientViewController

@synthesize messageText, sendButton, refreshButton, messageList, latitudeTextField, longitudeTextField, accuracyTextField;


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
		[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgAdded,@"added",msgUser,@"user",msgText,@"text",nil]];
		
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 75;
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = (UITableViewCell *)[self.messageList dequeueReusableCellWithIdentifier:@"ChatListItem"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatListItem" owner:self options:nil];
		cell = (UITableViewCell *)[nib objectAtIndex:0];
	}
	NSDictionary *itemAtIndex = (NSDictionary *)[messages objectAtIndex:(messages.count-1-indexPath.row)];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
	textLabel.text = [itemAtIndex objectForKey:@"text"];
	UILabel *userLabel = (UILabel *)[cell viewWithTag:2];			
	userLabel.text = [itemAtIndex objectForKey:@"user"];
	
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
