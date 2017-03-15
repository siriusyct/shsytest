//
//  LoginController.h
//  shsytest
//
//  Created by jizhai_zl on 2017/3/2.
//  Copyright © 2017年 zl. All rights reserved.
//

#ifndef LoginController_h
#define LoginController_h

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *tfName;

- (IBAction)saveNameAction:(id)sender;


@end


#endif /* LoginController_h */
