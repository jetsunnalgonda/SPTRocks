//
//  SPTTableViewCell.h
//  SPT Rocks
//
//  Created by Haluk Isik on 08/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPTTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UITextField *cellInputText;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

@end
