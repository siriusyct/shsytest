//
//  LoginController.m
//  shsytest
//
//  Created by jizhai_zl on 2017/3/2.
//  Copyright © 2017年 zl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginController.h"
#import "HomeController.h"
#import "SettingService.h"
#import "SHConst.h"

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (IBAction)saveNameAction:(id)sender {
    NSString* name = _tfName.text;
    if (name == nil)
        return;
    
    if (name.length > 1){
        SettingService* ss = [SettingService get];
        [ss setStringValue:SS_USER_INFO data:name];
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        HomeController* homeView = [story instantiateViewControllerWithIdentifier:@"homeView"];
        [self.navigationController pushViewController:homeView animated:NO];
    }
}
@end
