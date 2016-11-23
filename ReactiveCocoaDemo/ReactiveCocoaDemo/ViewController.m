//
//  ViewController.m
//  ReactiveCocoaDemo
//
//  Created by chocklee on 16/8/10.
//  Copyright © 2016年 北京超信. All rights reserved.
//

#import "ViewController.h"

#import "ReactiveCocoa.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    RAC(self.loginButton, enabled) = [RACSignal combineLatest:@[self.usernameField.rac_textSignal,self.passwordField.rac_textSignal] reduce:^(NSString *username, NSString *password){
        return  @(username.length > 0 && password.length > 0);
    }];
    

}

- (IBAction)loginAction:(UIButton *)sender {
    
    // 解决按钮短时间内多次点击只触发一次事件方法
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTime) object:_loginButton];
    [self performSelector:@selector(startTime) withObject:_loginButton afterDelay:0.2f];
    
//    NSLog(@"登录");
//    [self startTime];
}

- (void)startTime {
    __block int timeout= 59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if (timeout <= 0) { //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 设置界面的按钮显示 根据自己需求设置
                [_loginButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                _loginButton.userInteractionEnabled = YES;
            });
        } else {
            // int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                [_loginButton setTitle:[NSString stringWithFormat:@"%@秒重发",strTime] forState:UIControlStateNormal];
                [UIView commitAnimations];
                _loginButton.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
