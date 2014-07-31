//
//  ViewController.m
//  YoutubeRapid
//
//  Created by Sachin Kesiraju on 7/29/14.
//  Copyright (c) 2014 Sachin Kesiraju. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong,nonatomic) NSArray *defaultSearches;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation ViewController

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _searchField.backgroundColor = [UIColor whiteColor];
    _searchField.layer.cornerRadius = 4;
    _searchField.placeholder = @"Search YouTube in an instant";
    _searchField.textColor = [UIColor blackColor];
    _searchField.returnKeyType = UIReturnKeyDone;
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _defaultSearches = [[NSArray alloc] initWithObjects: @"YouTube", @"AutoTune", @"Rihanna", @"Far East Movement", @"Glee Cast", @"Nelly", @"Usher", @"Katy Perry", @"Taio Cruz", @"Eminem", @"Shakira", @"Kesha", @"B.o.B.",  @"Kid Cudi", @"Taylor Swift", @"Akon", @"Bon Jovi", @"Michael Jackson", @"Lady Gaga", @"Jay Z", @"My Chemical Romance", @"The Beatles", @"Led Zepplin", @"Guns N Roses", @"AC DC", @"Aerosmith", @"Tetris", @"Borat", @"Fallout Boy", @"Blink 182", @"Pink Floyd", @"MGMT", @"Justin Bieber", @"Billy Joel", @"Drake", @"Jay Sean", @"Childish Gambino", @"Pharell Williams", @"Kanye West", @"Frank Ocean", @"Bastille", @"Lorde", nil];
    _searchedLabel.text = @"";
    _indicator = [[UIActivityIndicatorView alloc] init];
    _indicator.hidesWhenStopped = YES;
    int rand = arc4random()%_defaultSearches.count;
    _searchedLabel.text = [_defaultSearches objectAtIndex:rand];
    NSString *suitableWord = [[_defaultSearches objectAtIndex:rand] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self searchYouTube:suitableWord];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan)
    {
        [self.view endEditing:YES];
    }
}

- (void) textFieldDidChange: (UITextField *) textField
{
    [_indicator startAnimating];
    if(textField.text.length== 0)
    {
        int rand = arc4random()%_defaultSearches.count;
        _searchedLabel.text = [_defaultSearches objectAtIndex:rand];
        NSString *searchWord = [[_defaultSearches objectAtIndex:rand] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        [self searchYouTube:searchWord];
    }
    else
    {
        NSLog(@"Searching text %@", textField.text);
        NSString *autoString = [NSString stringWithFormat:@"http://suggestqueries.google.com/complete/search?q=%@&ds=yt&hl=en&client=firefox", textField.text];
        NSMutableURLRequest *autoCompleteRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:autoString]];
        [autoCompleteRequest setHTTPMethod:@"GET"];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:autoCompleteRequest returningResponse:&response error:&error];
        
        if(error!= nil)
        {
            NSLog(@"Error %@", error);
        }
        else
        {
            NSMutableArray *autoCompleteJson = nil;
            if(data!= nil)
            {
                autoCompleteJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            }
            if(error || !autoCompleteJson)
            {
                NSLog(@"Could not parse loaded auto complete json with error %@", error);
            }
            else
            {
                NSString *suggestion = [[autoCompleteJson objectAtIndex:1] objectAtIndex:0];
                _searchedLabel.text = suggestion;
                NSString *wordSearch = [suggestion stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                [self searchYouTube:wordSearch];
            }
        }
    }
}

- (void) searchYouTube: (NSString *) keyword
{
    NSLog(@"Searching YouTube");
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=%@&order=viewCount&alt=json&key=AIzaSyBxFpgIBpsUI04ic-luzHZzlqoFbVEX9Ws", keyword];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *connectionData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error!= nil)
    {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops! An error occurred" message:[NSString stringWithFormat:@"%@", error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        NSMutableDictionary *json = nil;
        
        if(nil != connectionData)
        {
            json = [NSJSONSerialization JSONObjectWithData:connectionData options:NSJSONReadingMutableContainers error:&error];
        }
        
        if (error || !json)
        {
            NSLog(@"Could not parse loaded json with error:%@", error);
        }
        else
        {
            NSMutableDictionary *videos = [[json objectForKey:@"items"] objectAtIndex:0];
            [self playVideoWithId:[[videos objectForKey:@"id"] objectForKey:@"videoId"]];
        }
    }
}

- (void) playVideoWithId: (NSString *) videoId
{
    [_indicator stopAnimating];
    NSString *youTubeVideoHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>"; 
    NSLog(@"Playing video with video id %@", videoId);
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, self.playerView.frame.size.width, self.playerView.frame.size.height, videoId];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.playerView.frame];
    [webView setMediaPlaybackRequiresUserAction:NO];
    [webView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
