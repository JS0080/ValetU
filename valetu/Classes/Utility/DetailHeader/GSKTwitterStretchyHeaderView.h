#import <GSKStretchyHeaderView/GSKStretchyHeaderView.h>

@protocol  GSKTwitterStretchyHeaderViewDelegate;

@interface GSKTwitterStretchyHeaderView : GSKStretchyHeaderView
@property (weak, nonatomic) id<GSKTwitterStretchyHeaderViewDelegate> delegate;
@end

@protocol GSKTwitterStretchyHeaderViewDelegate <NSObject>

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
  didTapBackButton:(id)sender;

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
  didAddReview:(id)sender;

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
      didReturntoCar:(id)sender;

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
    didMenuPressed:(id)sender;

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
    didTapDirection:(id)sender;

@end
