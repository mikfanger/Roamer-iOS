//
//  ToCViewController.m
//  Roamer
//
//  Created by Rajesh Mehta on 8/13/14.
//
//

#import "ToCViewController.h"

@interface ToCViewController ()

@end

@implementation ToCViewController

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
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGSize contentSize = _mScrollView.contentSize;
    _mTocImgView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBackAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
