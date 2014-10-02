//
//  ExplanationViewCntrl.m
//  Roamer
//
//  Created by Mac Home on 2/24/14.
//
//

#import "ExplanationViewCntrl.h"

@interface ExplanationViewCntrl ()

@end

@implementation ExplanationViewCntrl

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

    if ([[UIScreen mainScreen] bounds].size.height == 568){
        self.mBkgImgView.image = [UIImage imageNamed:@"plane_1136x640.png"];
    } else {
        self.mBkgImgView.image = [UIImage imageNamed:@"plane_960x640.png"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPrevAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)onCreateAccountAction:(id)sender {
    [self performSegueWithIdentifier:@"performNewAccount" sender:self];
}

- (void)performFinishedAction:(CreateAccountViewCntrl *)viewCtrl {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate performFinishedAction:self];
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"performNewAccount"]) {
        CreateAccountViewCntrl *friendsVC = segue.destinationViewController;
        friendsVC.delegate = self;
    }
}

@end
