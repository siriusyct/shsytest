//
//  ViewController.m
//  shsytest
//
//  Created by jizhai_zl on 2017/2/27.
//  Copyright © 2017年 zl. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "SettingService.h"
#import "HomeController.h"
#import "SHConst.h"
#import "LoginController.h"
#import "HomeController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    //AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    //appDelegate.allowRotation = YES;//(以上2行代码,可以理解为打开横屏开关)
    
    //[self setNewOrientation:YES];//调用转屏代码
    //[self performSegueWithIdentifier:@"loginView" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    SettingService* ss = [SettingService get];
    NSDictionary* info = [ss getDictoryValue:SS_USER_INFO defValue:nil];
    if (info == nil){
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            LoginController* lgView = [story instantiateViewControllerWithIdentifier:@"loginView"];
            [self.navigationController pushViewController:lgView animated:NO];
        });
    } else {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            HomeController* homeView = [story instantiateViewControllerWithIdentifier:@"homeView"];
            [self.navigationController pushViewController:homeView animated:NO];
        });
    }
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return ((interfaceOrientation == UIDeviceOrientationLandscapeLeft)||(interfaceOrientation ==UIDeviceOrientationLandscapeRight));
}


@end
