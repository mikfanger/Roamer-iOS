//
//  SortDateSelectorViewCtrl.m
//  Roamer
//
//  Created by Mac Home on 6/2/14.
//
//

#import "SortDateSelectorViewCtrl.h"

@interface SortDateSelectorViewCtrl ()

@end

@implementation SortDateSelectorViewCtrl

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSelectAction:(id)sender {
    [self.delegate selectSortDateSelectorView:self startDate:self.mStartDatePicker.date endDate:self.mEndDatePicker.date];
}

- (IBAction)onCancelAction:(id)sender {
    [self.delegate cancelSortDateSelectorView:self];
}

- (IBAction)onStartDateChange:(id)sender {
    self.mEndDatePicker.minimumDate = self.mStartDatePicker.date;
    self.mEndDatePicker.date = self.mStartDatePicker.date;
}

@end
