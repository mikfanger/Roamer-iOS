//
//  ChatDetailViewController.h
//  Roamer
//
//  Created by Rajesh Mehta on 6/26/14.
//
//

#import <UIKit/UIKit.h>

@class ChatDetailViewController;

@protocol ChatDetailViewControllerDelegate <NSObject>
- (void)backFromChatDetailView:(ChatDetailViewController *)viewCtrl;
@end

@interface ChatDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id <ChatDetailViewControllerDelegate> delegate;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UITextField *mMsgTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) PFObject *userRoamer;

- (IBAction)onSendAction:(id)sender;
- (IBAction)onBackAction:(id)sender;
@end
