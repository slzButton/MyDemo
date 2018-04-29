//
//  SetTagsViewController.m
//  PushSDK
//
//  Created by ys on 16/05/2017.
//  Copyright © 2017 hxhg. All rights reserved.
//

#import "SetTagsViewController.h"
#import "JPUSHService.h"
@interface SetTagsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tagsTextField;
@property (weak, nonatomic) IBOutlet UITextField *aliasTextField;
@property (weak, nonatomic) IBOutlet UITextView *holderTextView;

@end

@implementation SetTagsViewController

static NSInteger seq = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.holderTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (IBAction)addTags:(id)sender {
    [JPUSHService addTags:[self tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
      [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@", iTags.allObjects] andSeq:seq];
    } seq:[self seq]];
}
- (IBAction)setTags:(id)sender {
    [JPUSHService setTags:[self tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
      [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@", iTags.allObjects] andSeq:seq];
    } seq:[self seq]];
}
- (IBAction)getAllTags:(id)sender {
    [JPUSHService getAllTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
      [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@", iTags.allObjects] andSeq:seq];
    } seq:[self seq]];
}
- (IBAction)deleteTags:(id)sender {
    [JPUSHService deleteTags:[self tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
      [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@", iTags.allObjects] andSeq:seq];
    } seq:[self seq]];
}
- (IBAction)cleanTags:(id)sender {
    [JPUSHService cleanTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
      [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@", iTags.allObjects] andSeq:seq];
    } seq:[self seq]];
}
- (IBAction)vaildTag:(id)sender {
  [JPUSHService validTag:[[self tags] anyObject] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq, BOOL isBind) {
    [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@ isBind:%d", iTags.allObjects, isBind] andSeq:seq];
  } seq:[self seq]];
}

- (IBAction)setAlias:(id)sender {
    [JPUSHService setAlias:[self alias] completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
      [self inputResponseCode:iResCode content:iAlias andSeq:seq];
    } seq:[self seq]];
}
- (IBAction)deleteAlias:(id)sender {
  [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
    [self inputResponseCode:iResCode content:iAlias andSeq:seq];
  } seq:[self seq]];
}
- (IBAction)getAlias:(id)sender {
  [JPUSHService getAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
    [self inputResponseCode:iResCode content:iAlias andSeq:seq];
  } seq:[self seq]];
}
- (IBAction)resetTextField:(id)sender {
  self.tagsTextField.text = nil;
  self.aliasTextField.text = nil;
}
- (IBAction)resetTextView:(id)sender {
  self.holderTextView.text = nil;
}

- (NSInteger)seq {
  return ++ seq;
}

- (NSSet<NSString *> *)tags {
  NSArray * tagsList = [self.tagsTextField.text componentsSeparatedByString:@","];
  if (self.tagsTextField.text.length > 0 && !tagsList.count) {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有输入tags,请使用逗号作为tags分隔符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
  }
  NSMutableSet * tags = [[NSMutableSet alloc] init];
  [tags addObjectsFromArray:tagsList];
  return tags;
}

- (NSString *)alias {
  return self.aliasTextField.text;
}

- (void)inputResponseCode:(NSInteger)code content:(NSString *)content andSeq:(NSInteger)seq{
  self.holderTextView.text = [self.holderTextView.text stringByAppendingFormat:@"\n\n code:%ld content:%@ seq:%ld", code, content, seq];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [JPUSHService startLogPageView:NSStringFromClass(self.class)];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [JPUSHService stopLogPageView:NSStringFromClass(self.class)];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self.tagsTextField resignFirstResponder];
  [self.aliasTextField resignFirstResponder];
}

@end
