//
//  GraphViewController.h
//  Calculator
//
//  Created by Jeffrey Lam on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController : UIViewController <GraphViewDataSource, SplitViewBarButtonItemPresenter>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end
