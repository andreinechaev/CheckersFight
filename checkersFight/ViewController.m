//
//  ViewController.m
//  checkersFight
//
//  Created by Andrei Nechaev on 2/24/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UICollisionBehaviorDelegate, UIAlertViewDelegate>{
    NSString *name;
}

@property (nonatomic, strong) NSMutableArray *blackItems;
@property (nonatomic, strong) NSMutableArray *redItems;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UISnapBehavior *snap;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@property (weak, nonatomic) IBOutlet UILabel *blackScore;
@property (weak, nonatomic) IBOutlet UILabel *redScore;

@end

@implementation ViewController
@synthesize animator;
@synthesize collision;
@synthesize snap;
@synthesize itemBehavior;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self startGame];
    
    
}

- (void)startGame
{
    _blackItems = [NSMutableArray new];
    _redItems = [NSMutableArray new];
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    collision = [UICollisionBehavior new];
    collision.collisionDelegate = self;
    itemBehavior = [[UIDynamicItemBehavior alloc] init];
    [self createBlackItems];
    [self createRedItems];
    itemBehavior.elasticity = 0.1;
    itemBehavior.density = 100;
    itemBehavior.resistance = 1.0;
    itemBehavior.friction = 0.0;
    [animator addBehavior:itemBehavior];
    [animator addBehavior:collision];
    
    [self score];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBlackItems
{
    CGFloat size = self.view.frame.size.width / 10;
    CGFloat coordinateX = 15;
    CGFloat coordinateY = 20;
    
    
    for (int i = 0; i < 8; ++i) {
        UIView *square = [[UIView alloc] initWithFrame:CGRectMake(coordinateX, coordinateY, size, size)];
        square.backgroundColor = [UIColor blackColor];
        square.layer.cornerRadius = size/2;
        square.layer.shadowOffset = CGSizeMake(-1, -1);
        square.layer.shadowColor = [UIColor redColor].CGColor;
        square.layer.shadowOpacity = 1.0;
        square.layer.shadowRadius = 2.0;
        coordinateX += (square.frame.size.width + 15);
        [collision addItem:square];
        [_blackItems addObject:square];
        [itemBehavior addItem:square];
    }
    for (UIView *view in _blackItems) {
        [self.view addSubview:view];
    }
}

- (void)createRedItems
{
    CGFloat size = self.view.frame.size.width / 10;
    CGFloat coordinateX = 15;
    CGFloat coordinateY = self.view.frame.size.height - 15 - (self.view.frame.size.width / 10);
    
    
    for (int i = 0; i < 8; ++i) {
        UIView *square = [[UIView alloc] initWithFrame:CGRectMake(coordinateX, coordinateY, size, size)];
        square.backgroundColor = [UIColor redColor];
        square.layer.cornerRadius = size/2;
        square.layer.shadowOffset = CGSizeMake(1, 1);
        square.layer.shadowColor = [UIColor blackColor].CGColor;
        square.layer.shadowOpacity = 1.0;
        square.layer.shadowRadius = 2.0;
        coordinateX += (square.frame.size.width + 15);
        [collision addItem:square];
        [_redItems addObject:square];
        [itemBehavior addItem:square];
    }
    
    for (UIView *view in _redItems) {
        [self.view addSubview:view];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView *touchedView = [touch view];
    if (touchedView != self.view){
        if (snap) {
            [animator removeBehavior:snap];
        }
        snap = [[UISnapBehavior alloc] initWithItem:touchedView snapToPoint:[touch locationInView:self.view]];
        [animator addBehavior:snap];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self score];
    if (snap) {
        [animator removeBehavior:snap];
    }
}


- (void)score
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIView *sq in [self.blackItems copy]) {
            if (sq.frame.origin.x < -sq.bounds.size.width*2
                || sq.frame.origin.y < -sq.bounds.size.height*2
                || sq.frame.origin.x > [UIScreen mainScreen].bounds.size.width
                || sq.frame.origin.y > [UIScreen mainScreen].bounds.size.height) {
                [sq removeFromSuperview];
                [collision removeItem:sq];
                [itemBehavior removeItem:sq];
                [self.blackItems removeObject:sq];
                if (self.blackItems.count == 0)
                {
                    [self announcment:@"Red"];
                    return;
                }
            }
        }
        for (UIView *sq in [self.redItems copy]) {
            if (sq.frame.origin.x < 0
                || sq.frame.origin.y < 0
                || sq.frame.origin.x > [UIScreen mainScreen].bounds.size.width
                || sq.frame.origin.y > [UIScreen mainScreen].bounds.size.height) {
                [sq removeFromSuperview];
                [collision removeItem:sq];
                [itemBehavior removeItem:sq];
                [self.redItems removeObject:sq];
                if (self.redItems.count == 0)
                {
                    [self announcment:@"Black"];
                    return;
                }
            }
        }
        self.blackScore.text = [NSString stringWithFormat:@"%lu",(unsigned long)[self.blackItems count]];
        self.redScore.text = [NSString stringWithFormat:@"%lu",(unsigned long)[self.redItems count]];
        [self score];
    });
}

- (void)announcment:(NSString *)theName
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                        message:[NSString stringWithFormat:@"Winner is %@", theName]
                                                       delegate:self
                                              cancelButtonTitle:@"Restart"
                                              otherButtonTitles:@"Exit", nil];
    
    for (UIView *obj in collision.items){
        [obj removeFromSuperview];
        [collision removeItem:obj];
    }
    for (UIView *obj in itemBehavior.items) {
        [obj removeFromSuperview];
        [itemBehavior removeItem:obj];
    }
    [self.blackItems removeAllObjects];
    [self.redItems removeAllObjects];
    _redScore.text = @"0";
    _blackScore.text = @"0";
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self startGame];
    }
}


@end
