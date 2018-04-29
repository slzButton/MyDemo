//
//  ShowcaseMainViewController.m
//  FilterShowcase
//
//  Created by 陈春光 on 2017/8/2.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#import "ShowcaseMainViewController.h"
#import "ShowcaseFilterListController.h"

@interface ShowcaseMainViewController (){
    UIImagePickerController *_imagePickerController;
}

@end

@implementation ShowcaseMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)useDefaultPicture:(id)sender {
    
//    //攀哥
//    UIImage *inputImage = [UIImage imageNamed:@"1.png"];
//    //狗狗
//    UIImage *inputImage = [UIImage imageNamed:@"dog.jpg"];
    //🐔的狗狗
    UIImage *inputImage = [UIImage imageNamed:@"dog2.jpg"];
    
    filterListController = [[ShowcaseFilterListController alloc]init];
    [filterListController setInputImage:inputImage];
    [self.navigationController pushViewController:filterListController animated:YES];
}

- (IBAction)usePhotos:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = NO;
   // [self presentModalViewController:picker animated:YES];
    [self presentViewController:picker animated:YES completion:nil];

}
- (IBAction)useCamera:(id)sender {
    filterListController = [[ShowcaseFilterListController alloc]init];
    [self.navigationController pushViewController:filterListController animated:YES];
}


-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage* inputImage = nil;
    
    if ([type isEqualToString:@"public.image"])
    {
        inputImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    if(inputImage) {
    
        filterListController = [[ShowcaseFilterListController alloc]init];
        [filterListController setInputImage:inputImage];
        [self.navigationController pushViewController:filterListController animated:YES];
    }
    
}

@end
