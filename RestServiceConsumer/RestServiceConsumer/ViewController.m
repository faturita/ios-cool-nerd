//
//  ViewController.m
//  RestServiceConsumer
//
//  Created by Rodrigo Ramele on 2/11/13.
//  Copyright (c) 2015 Baufest. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

- (IBAction)click:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *buttonzero;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doYourThing:(id)sender {
    
    NSLog(@"Ready to fetch info!");
    
    // Primero, serializo un dictionario mutable en su equivalente en JSON.
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      @"username" : @"Bill",
                                                                                      @"password" : @"Gates"}];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if ([jsonData length] > 0 && error == nil){
        NSLog(@"Successfully serialized the dictionary into data = %@",jsonData);
    }
    else if ([jsonData length] == 0 &&
             error == nil){
        NSLog(@"No data was returned after serialization.");
    } else if (error != nil){
        NSLog(@"An error happened = %@", error);
    }

    // URL de conexion al servicio REST donde voy a enviar la informacion.
    NSString *urlAsString = @"http://superwebmobile.azurewebsites.net/WebMobile/rest/authenticate/check";
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Si quiero mandar el JSON
    //NSString *body = [[NSString alloc] initWithData: jsonData encoding:NSUTF8StringEncoding];
    
    // Si quiero mandar el string hardcoded.
    NSString *body = @"username=connection&password=string";
    
    NSLog(@"Sending %@", body);
    
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // La cola me sirve para alocar espacio de procesamiento por el cual asincronicamente voy a enviar el pedido (Single Thread!)
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if ([data length] >0 && error == nil){
            NSString *html = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
            NSLog(@"JSON = %@", html);
            
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data //1
                                  options:kNilOptions
                                  error:&error];
            
            // Prueben esto directamente.
            //[_textField setText:[json objectForKey:@"username"]];
            //_textField.text =[json objectForKey:@"username"];
            
            // El cambio debe hacerse sobre el main thread.
            [self performSelectorOnMainThread:@selector(change:)
                                     withObject:[json objectForKey:@"username"]
                                  waitUntilDone:NO];
            
            
        }
        else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error);
        }
    }];
    
}

// Cambio del valor del text
-(void)change:(NSString*)val {
    _textField.text =val;
    //[_textField setText:[json objectForKey:@"username"]];
}
- (IBAction)click:(id)sender {
    [sender setBackgroundColor: [UIColor colorWithRed:0x33/255.0 green:0 blue:0x99/255.0 alpha:1.0]];
}
@end
