#import "ProjectListView.h"
#import "SessionBrowserViewController.h"
#import "Session+Queries.h"
#import "Asset.h"
#import "Project+Queries.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface ProjectListView ()

@property(nonatomic, strong) NSArray *projects;

- (void)displayDeleteConfirmation;

- (void)disableAlertSaveButton;

- (void)enableAlertSaveButton;

- (void)showViewForSelectedProject:(NSInteger)row;

- (void)createNewProject:(NSString *)projectName;

- (void)deleteProject;

- (BOOL)projectNameExists:(NSString *)projectName;

- (void)setDefaultView;

- (void)setEditView;

- (void)showNewProjectAlertVIew;

@end

@implementation ProjectListView {
    UITextField *_textField;
    UIAlertView *_newProjectAlert;
    NSArray *_projects;
    Project *_projectToDelete;
}

@synthesize managedObjectContext;
@synthesize projects = _projects;


- (NSArray *)projects {

    if (!_projects) {

        NSEntityDescription *entityDescription = [NSEntityDescription
                entityForName:@"Project"
       inManagedObjectContext:managedObjectContext];

        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];

        NSError *error;
        NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
        if (objects == nil) {
            NSLog(@"There was an error!");
            // Do whatever error handling is appropriate
        }

        _projects = objects;

        [self.tableView reloadData];
    }

    return _projects;
}


#pragma mark - View lifecycle


- (void)viewDidLoad {

    [super viewDidLoad];

    if (self.projects.count > 0)
        [self setDefaultView];
    else
        [self setEditView];
}

- (void)viewDidUnload {

    self.projects = nil;

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;

    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"GrotographTableCell";

    __block UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    Project *project = [self.projects objectAtIndex:(NSUInteger) indexPath.row];
    Asset *photo = [[project getMostRecentSession] getMostRecentPhoto];

    cell.imageView.image = [UIImage imageNamed:@"tableviewthumbdefault.png"];

    NSLog(@"Image size %f %f", cell.bounds.size.width, cell.bounds.size.height);

    if (photo && photo.url) {
        ALAssetsLibrary *alAssetsLibrary = [[ALAssetsLibrary alloc] init];

        [alAssetsLibrary assetForURL:[NSURL fileURLWithPath:photo.url]
                            resultBlock:^(ALAsset *asset) {
                                NSLog(@"Loaded asset for thumbnail %@", photo.url);
                                if (asset) {

                                        UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
                                                                        [cell.imageView setImage:image];

                                    [cell.imageView setImage:image];
                                }
                                //[self.tableView setNeedsDisplay];

                            } failureBlock:^(NSError *error) {
            //Nothing to do, just leave the default image
        }];
    }

    cell.textLabel.text = [project name];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showViewForSelectedProject:[indexPath row]];
}


- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        _projectToDelete = [self.projects objectAtIndex:(NSUInteger) indexPath.row];

        [self displayDeleteConfirmation];


    } else if (editingStyle == UITableViewCellEditingStyleInsert) {

        NSLog(@"Insert row at indexPath %d", indexPath.row);
        [self.tableView reloadData];
    }
}

#pragma mark - Private Methods

- (void)showViewForSelectedProject:(NSInteger)row {
    NSString *projectName = [(Project *) [self.projects objectAtIndex:(NSUInteger) row] name];

    Project *project = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(name = %@)", projectName]];
    [request setEntity:entityDescription];

    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];

    if (objects != nil) {
        if ([objects count] > 0)
            project = (Project *) [objects objectAtIndex:0];
    }
    else {
        //TODO : Error handling
        NSLog(@"Unable to load project from DB!");
    }

    SessionBrowserViewController *browser = [[SessionBrowserViewController alloc] initWithProject:project];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - UITextField delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // [textField resignFirstResponder];
    NSLog(@"Did end editing: %@", textField.text);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    NSLog(@"Should return: %@", textField.text);
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
        [_newProjectAlert dismissWithClickedButtonIndex:1 animated:YES];
    }

    return NO;
}

#pragma mark - UITextField change handler

- (void)textFieldContentChanged:(id)handleNameInputChanges {

    if (_textField.text.length > 0) {
        if (![self projectNameExists:_textField.text]) {
            [self enableAlertSaveButton];
            return;
        }
    }

    [self disableAlertSaveButton];
}



#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1) {
        [self createNewProject:_textField.text];
        self.projects = nil;
        [self.tableView reloadData];
        [self.tableView setNeedsLayout];
    }
}



#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1)
        return;
    
    [self deleteProject];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {

}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {

}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {

}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {

}


#pragma mark - Project CRUD

- (void)createNewProject:(NSString *)projectName {

    if ([self projectNameExists:projectName])
        return;

    //Create new project
    Project *newProject = [NSEntityDescription
            insertNewObjectForEntityForName:@"Project"
                     inManagedObjectContext:[self managedObjectContext]];

    NSDate *now = [[NSDate alloc] init];
    [newProject setName:projectName];
    [newProject setDateCreated:now];
    [newProject setDateModified:now];

    //Save changes
    NSError *error = nil;
    [self.managedObjectContext save:&error];

    //TODO: Error handling

}

- (void)deleteProject {

    [self.projects indexOfObject:_projectToDelete];

    NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.projects indexOfObject:_projectToDelete] inSection:0]];
    [self.tableView beginUpdates];

    [self.managedObjectContext deleteObject:_projectToDelete];
    _projectToDelete = nil;
    self.projects = nil;

    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];

    NSError *error = nil;
    [self.managedObjectContext save:&error];
    //TODO: Error handling

}

- (BOOL)projectNameExists:(NSString *)projectName {

    BOOL nameExists = NO;

    //Check if a project is already using the name
    NSEntityDescription *entityDescription = [NSEntityDescription
            entityForName:@"Project"
   inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@)", projectName];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];


    NSError *error = nil;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];

    if (objects == nil) {
        NSLog(@"There was an error!");
        //TODO: Do whatever error handling is appropriate
    }

    if ([objects lastObject] != nil)
        nameExists = YES;

    return nameExists;
}


#pragma mark - Display

- (void)setDefaultView {
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                 target:self
                                 action:@selector(setEditView)];

    self.navigationItem.rightBarButtonItem = button;

    [self.tableView setEditing:NO animated:YES];

    self.navigationItem.leftBarButtonItem = nil;
    //UIImage *image = [UIImage imageNamed:@"Icon.png"];
    //UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    //UIBarButtonItem *logoImage = [[UIBarButtonItem alloc] initWithCustomView:imgView];
    //self.navigationItem.leftBarButtonItem = logoImage;
}

- (void)setEditView {

    [self.tableView setEditing:YES animated:YES];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
            initWithTitle:@"Add"
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(showNewProjectAlertVIew)];

    self.navigationItem.leftBarButtonItem = addButton;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(setDefaultView)];

    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)displayDeleteConfirmation {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
            initWithTitle:@"Your photos used in the Grotograph will not be deleted."
                 delegate:self
        cancelButtonTitle:@"Cancel"
   destructiveButtonTitle:@"Delete"
        otherButtonTitles:nil];

    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:self.tableView];
}

- (void)disableAlertSaveButton {
    for (UIView *view in _newProjectAlert.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (((UIButton *) view).titleLabel.text == @"Save")
                ((UIButton *) view).enabled = NO;
        }
    }
}

- (void)enableAlertSaveButton {
    for (UIView *view in _newProjectAlert.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (((UIButton *) view).titleLabel.text == @"Save")
                ((UIButton *) view).enabled = YES;
        }
    }
}

- (void)showNewProjectAlertVIew {

    _newProjectAlert = [[UIAlertView alloc]
            initWithTitle:@"New Grotograph Project"
                  message:@"\n\n\n"
                 delegate:self
        cancelButtonTitle:@"Cancel"
        otherButtonTitles:@"Save", nil];

    _newProjectAlert.tag = 0;
    [self disableAlertSaveButton];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, -1);
    label.textAlignment = UITextAlignmentCenter;
    label.text = @"Enter a name for this project.";

    [_newProjectAlert addSubview:label];

    UIImageView *passwordImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"textfieldbackground" ofType:@"png"]]];
    passwordImage.frame = CGRectMake(11, 79, 262, 31);
    [_newProjectAlert addSubview:passwordImage];

    _textField = [[UITextField alloc] initWithFrame:CGRectMake(16, 83, 252, 25)];
    _textField.placeholder = @"Title";
    _textField.font = [UIFont systemFontOfSize:18];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.secureTextEntry = NO;
    _textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.enablesReturnKeyAutomatically = YES;
    _textField.delegate = self;
    [_textField becomeFirstResponder];
    [_textField addTarget:self action:@selector(textFieldContentChanged:) forControlEvents:UIControlEventEditingChanged];

    [_newProjectAlert addSubview:_textField];

    [_newProjectAlert setTransform:CGAffineTransformMakeTranslation(0, 0)];
    [_newProjectAlert show];
}


@end
