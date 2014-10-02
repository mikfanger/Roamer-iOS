//
//  EventDateSelectorViewCtrl.m
//  Roamer
//
//  Created by Mac Home on 6/6/14.
//
//

#import "EventDateSelectorViewCtrl.h"

@interface EventDateSelectorViewCtrl ()

@end

@implementation EventDateSelectorViewCtrl

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
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = 6;
    NSDate *sixMonthDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    self.mEventDatePicker.maximumDate = sixMonthDate;
    self.mEventDatePicker.minimumDate = [NSDate date];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSelectAction:(id)sender {
    [self.delegate selectEventDateSelectorView:self
                                     eventDate:self.mEventDatePicker.date];
}

- (IBAction)onCancelAction:(id)sender {
    [self.delegate cancelEventDateSelectorView:self];
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

@end
