//
//  ViewController.m
//  UWTodoApp
//
//  Created by Martin Nash on 1/27/15.
//  Copyright (c) 2015 Martin Nash. All rights reserved.
//

#import "ViewController.h"
#import "TodoItem.h"
#import "TodoList.h"

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>
@property (weak) IBOutlet NSTextField *inputTextField;
@property (weak) IBOutlet NSButton *allowDuplicatesButton;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *removeButton;
@property (weak) IBOutlet NSTableView* tableView;
@property (strong, nonatomic) TodoList *list;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _list = [[TodoList alloc] initWithTitle:@"Great List"];
    self.inputTextField.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.rowHeight = 140;
}

-(void)viewDidAppear
{
    [super viewDidAppear];
    [self updateInterface];
    self.view.window.title = _list.title;
}

-(void)updateInterface
{
    self.allowDuplicatesButton.state = self.list.allowsDuplicates;
    TodoItem *currentItem = [self todoItemFromCurrentInput];
    self.addButton.enabled = [self.list canAddItem:currentItem];
    self.removeButton.enabled = [self.list canRemoveItem:currentItem];
    self.view.window.title = self.list.title;

}

-(TodoItem*)todoItemFromCurrentInput
{
    return [TodoItem todoItemWithTitle:self.inputTextField.stringValue];
}




#pragma mark - Property Overrides

-(void)setList:(TodoList *)list
{
    _list = list;
    [self updateInterface];
    [self.tableView reloadData];
}



#pragma mark - Actions

- (IBAction)clickedAddButton:(id)sender
{
    [self tryToInsertNewItem];
}

- (IBAction)clickedRemoveButton:(id)sender
{
    TodoItem *item = [self todoItemFromCurrentInput];
    if ([self.list canRemoveItem:item]) {
        [self.list removeItem:item];
        
        // update table view
        [self.tableView reloadData];
        
        // clear text input
        self.inputTextField.stringValue = @"";
    }

    [self updateInterface];
}

- (IBAction)clickedDuplicatesButton:(id)sender
{
    self.list.allowsDuplicates = !self.list.allowsDuplicates;
    [self updateInterface];
}

-(void)tryToInsertNewItem
{
    TodoItem *item = [self todoItemFromCurrentInput];
    if ([self.list canAddItem:item]) {
        [self.list addItem:item];
        
        // update table view
        NSUInteger nextRow = self.tableView.numberOfRows;
        NSIndexSet *nextRowSet = [NSIndexSet indexSetWithIndex:nextRow];
        [self.tableView insertRowsAtIndexes:nextRowSet withAnimation:NSTableViewAnimationSlideDown];

        // clear text input
        self.inputTextField.stringValue = @"";
    }
    
    [self updateInterface];

}




#pragma mark - NSTextFieldDelegate

-(void)controlTextDidChange:(NSNotification *)obj
{
    if (obj.object == self.inputTextField) {
        [self updateInterface];
    }
}

-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    if (obj.object == self.inputTextField) {
        [self tryToInsertNewItem];
    }
}




#pragma mark - NSTableViewDataSource, NSTableViewDelegate

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.list itemCount];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"TextOnlyCell" owner:nil];
    TodoItem *item = self.list.allItems[row];
    cellView.textField.stringValue = item.title;
    return cellView;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (row % 2 == 0) {
        return 50;
    } else {
        return 100;
    }
}

-(IBAction)loadLandingList:(id)sender
{
    self.list = [TodoList airplaneLandingChecklist];
}

-(IBAction)loadShoppingList:(id)sender
{
    self.list = [TodoList groceryList];
}

@end
