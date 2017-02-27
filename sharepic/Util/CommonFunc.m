//
//  CommonUtil.m
//  findtalents
//
//  Created by steven on 15/4/2016.
//  Copyright © 2016 steven. All rights reserved.
//

#import "CommonFunc.h"

@implementation UIViewController (BackViewController)

-(UIViewController*)backViewController {
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

@end

@implementation CommonFunc

+ (UIView*)blockView {
    UIView* blockView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    blockView.backgroundColor = [UIColor clearColor];
    return blockView;
}

+ (void)showMBProgressHudOn:(UIView*)view withText:(NSString*)text delay:(CGFloat)seconds {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (text != nil) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = text;
    }
    
    [hud show:YES];
    hud.userInteractionEnabled = NO;
    int64_t delayInSeconds = seconds;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [hud hide:YES];
    });
}
//for filter view
+(void) showMBProgressHudOn:(UIView *)view withTitle:(NSString *)title blockView: (BOOL)flag {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (title != nil) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = title;
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = flag;
    }
    [hud show:YES];
}

+ (void)showMBProgressHudOn:(UIView *)view withText:(NSString*)text delay:(CGFloat)seconds blockUserInteraction: (BOOL)flag {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (!flag) {
        hud.userInteractionEnabled = NO;
    }
    if (text != nil) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = text;
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = flag;
    }
    
    [hud show:YES];
    int64_t delayInSeconds = seconds;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [hud hide:YES];
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = true;
    });
}

static NSMutableDictionary* waitingHuds = nil;
static NSMutableDictionary* blockViews = nil;
+ (void)startWaitingMBProgressHudOn:(UIView*)view{
    @synchronized (self) {
        if(waitingHuds == nil) {
            waitingHuds = [[NSMutableDictionary alloc] init];
        }
        if (waitingHuds[view.description] == nil) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            [hud show:YES];
            hud.userInteractionEnabled = NO;
            waitingHuds[view.description] = hud;
        }
    }
}

+ (void)startWaitingMBProgressHudOn:(UIView*)view isBlockView: (BOOL)flag{
    @synchronized (self) {
        if(waitingHuds == nil) {
            waitingHuds = [[NSMutableDictionary alloc] init];
        }
        if (waitingHuds[view.description] == nil) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            [hud show:YES];
            if (flag) {
                hud.userInteractionEnabled = YES;
            }
            else {
                hud.userInteractionEnabled = NO;
            }
            waitingHuds[view.description] = hud;
        }
    }
}

+ (void)startWaitingMBProgressHudOn:(UIView*)view isBlockScreen: (BOOL)flag {
    @synchronized (self) {
        if(waitingHuds == nil) {
            waitingHuds = [[NSMutableDictionary alloc] init];
        }
        if (blockViews == nil) {
            blockViews = [[NSMutableDictionary alloc] init];
        }
        if (waitingHuds[view.description] == nil) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            
            [hud show:YES];
            
            if (!flag) {
                hud.userInteractionEnabled = NO;
            }
            else {
                UIView* blockView = [self blockView];
                [[UIApplication sharedApplication].keyWindow addSubview:blockView];
                blockViews[view.description] = blockView;
            }
            waitingHuds[view.description] = hud;
        }
    }
}

+ (void)startWaitingMBProgressHudOn:(UIView*)view andTag:(NSString*)tag{
    @synchronized (self) {
        if(waitingHuds == nil) {
            waitingHuds = [[NSMutableDictionary alloc] init];
        }
        if (waitingHuds[tag] == nil) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            [hud show:YES];
            hud.userInteractionEnabled = NO;
            waitingHuds[tag] = hud;
        }
    }
}

+ (void)startWaitingMBProgressHudOn:(UIView *)view andTag:(NSString *)tag isBlockView: (BOOL)flag {
    @synchronized (self) {
        if(waitingHuds == nil) {
            waitingHuds = [[NSMutableDictionary alloc] init];
        }
        if (waitingHuds[tag] == nil) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            
            [hud show:YES];
            if (flag) {
                hud.userInteractionEnabled = YES;
            }
            else {
                hud.userInteractionEnabled = NO;
            }
            waitingHuds[tag] = hud;
        }
    }
}

+ (void)startWaitingMBProgressHudOn:(UIView *)view andTag:(NSString *)tag Title:(NSString *)title isBlockView: (BOOL)flag {
    @synchronized (self) {
        if(waitingHuds == nil) {
            waitingHuds = [[NSMutableDictionary alloc] init];
        }
        if (waitingHuds[tag] == nil) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            hud.labelText = title;
            [hud show:YES];
            if (flag) {
                hud.userInteractionEnabled = YES;
            }
            else {
                hud.userInteractionEnabled = NO;
            }
            waitingHuds[tag] = hud;
        }
    }
}

+ (void)startWaitingMBProgressHudOn:(UIView *)view andTag:(NSString *)tag Title:(NSString *)title  Detail:(NSString *)detail isBlockView: (BOOL)flag {
    @synchronized (self) {
        if(waitingHuds == nil) {
            waitingHuds = [[NSMutableDictionary alloc] init];
        }
        if (waitingHuds[tag] == nil) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            hud.labelText = title;
            hud.detailsLabelText = detail;
            [hud show:YES];
            if (flag) {
                hud.userInteractionEnabled = YES;
            }
            else {
                hud.userInteractionEnabled = NO;
            }
            waitingHuds[tag] = hud;
        }
    }
}

+ (void)startWaitingMBProgressHudOn:(UIView*)view andTag:(NSString*)tag isBlockScreen: (BOOL)flag {
    @synchronized (self) {
        if(waitingHuds == nil) {
            waitingHuds = [[NSMutableDictionary alloc] init];
        }
        if (blockViews == nil) {
            blockViews = [[NSMutableDictionary alloc] init];
        }
        if (waitingHuds[tag] == nil) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            
            [hud show:YES];
            
            if (!flag) {
                hud.userInteractionEnabled = NO;
            }
            else {
                UIView* blockView = [self blockView];
                [[UIApplication sharedApplication].keyWindow addSubview:blockView];
                blockViews[tag] = blockView;
            }
            
            waitingHuds[tag] = hud;
        }
    }
}

+(void)commitWaitingMBProgressHudOn:(UIView*)view {
    @synchronized (self) {
        UIView* blockView = blockViews[view.description];
        if (blockView != nil) {
            [blockView removeFromSuperview];
            blockViews[view.description] = nil;
        }
        
        if ((waitingHuds == nil) || (waitingHuds.count == 0)) {
            return;
        }
        MBProgressHUD *hud = waitingHuds[view.description];
        if(hud != nil) {
            [hud hide:YES];
            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = true;
            waitingHuds[view.description] = nil;
        }
    }
}

+(void)commitWaitingMBProgressHudWithTag:(NSString*)tag{
    @synchronized (self) {
        UIView* blockView = blockViews[tag];
        if (blockView != nil) {
            [blockView removeFromSuperview];
            blockViews[tag] = nil;
        }
        
        if ((waitingHuds == nil) || (waitingHuds.count == 0)) {
            return;
        }
        MBProgressHUD *hud = waitingHuds[tag];
        
        if (hud != nil) {
            [hud hide:YES];
            waitingHuds[tag] = nil;
        }
    }
}

+ (BOOL)isEmailWith:(NSString *)string {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![emailTest evaluateWithObject:string]) {
        return NO;
    }
    return YES;
}

+(UIPickerView*) setInputPickerViewAndToolBarTo:(UITextField*)textField andWithTarget:(id<UIPickerViewDelegate, UIPickerViewDataSource>)target andWithDoneAction:(SEL)doneSelector andWithCancelAction:(SEL)cancelSelector andHeight:(NSInteger)height {
    
    CGSize deviceSize = [UIScreen mainScreen].bounds.size;
    UIPickerView* pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, deviceSize.height - height , deviceSize.width, height)];
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    pickerView.showsSelectionIndicator = YES;
    
    UIToolbar* toolBar = [[UIToolbar alloc] init];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.translucent = YES;
    [toolBar sizeToFit];
    
    NSMutableArray *items = [NSMutableArray new];
    if (cancelSelector != nil) {
        UIBarButtonItem* cancelButoon = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:target action:cancelSelector];
        [cancelButoon setTintColor:[UIColor blackColor]];
        [items addObject:cancelButoon];
    }
    
    UIBarButtonItem* spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:spaceButton];
    
    if ([textField isKindOfClass: [FormTextField class]]) {
        UIBarButtonItem* title = [[UIBarButtonItem alloc] initWithTitle:((FormTextField*)textField).toolbarTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        [title setTintColor: [UIColor grayColor]];
        UIFont * font = [UIFont systemFontOfSize:14];
        NSDictionary * attributes = @{NSFontAttributeName: font};
        [title setTitleTextAttributes:attributes forState:UIControlStateNormal];
        title.enabled = NO;
        [items addObject:title];
    }
    else {
        UIBarButtonItem* title = [[UIBarButtonItem alloc] initWithTitle:textField.placeholder style:UIBarButtonItemStylePlain target:nil action:nil];
        [title setTintColor: [UIColor grayColor]];
        UIFont * font = [UIFont systemFontOfSize:14];
        NSDictionary * attributes = @{NSFontAttributeName: font};
        [title setTitleTextAttributes:attributes forState:UIControlStateNormal];
        title.enabled = NO;
        [items addObject:title];
    }
    
    UIBarButtonItem* spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:spaceButton1];
    
    if (doneSelector != nil) {
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:target action:doneSelector];
        [doneButton setTintColor:[UIColor blackColor]];
        [items addObject:doneButton];
    }
    
    [toolBar setItems:items animated:NO];
    toolBar.userInteractionEnabled = YES;
    
    textField.inputView = pickerView;
    
    if (items.count > 1) {
        textField.inputAccessoryView = toolBar;
    }
    
    
    return pickerView;
}

+(UIDatePicker*)setDatePickerViewAndToolBarTo:(UITextField*)textField andWithTarget:(id)target andWithValueChangedAction:(SEL)valueChangedAction andWithDoneAction:(SEL)doneSelector andWithCancelAction:(SEL)cancelSelector from:(NSDate*)from to:(NSDate*)to {
    
    NSInteger height = 250;
    CGSize deviceSize = [UIScreen mainScreen].bounds.size;
    UIDatePicker* datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, deviceSize.height - height , deviceSize.width, height)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    
    if (valueChangedAction != nil) {
        [datePicker addTarget:target action:valueChangedAction forControlEvents:UIControlEventValueChanged];
    }
    
    /*** set date range ***/
    datePicker.minimumDate = from;
    datePicker.maximumDate = to;
    
    /*** set uitoolbar for input view accessory ***/
    UIToolbar* toolBar = [[UIToolbar alloc] init];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.translucent = YES;
    [toolBar sizeToFit];
    
    NSMutableArray *items = [NSMutableArray new];
    
    
    UIBarButtonItem* cancelButoon = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:target action:cancelSelector];
    [cancelButoon setTintColor:[UIColor blackColor]];
    [items addObject:cancelButoon];
    
    UIBarButtonItem* spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:spaceButton];
    
    if ([textField isKindOfClass: [FormTextField class]]) {
        UIBarButtonItem* title = [[UIBarButtonItem alloc] initWithTitle:((FormTextField*)textField).toolbarTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        [title setTintColor: [UIColor grayColor]];
        UIFont * font = [UIFont systemFontOfSize:14];
        NSDictionary * attributes = @{NSFontAttributeName: font};
        [title setTitleTextAttributes:attributes forState:UIControlStateNormal];
        title.enabled = NO;
        [items addObject:title];
    }
    else {
        UIBarButtonItem* title = [[UIBarButtonItem alloc] initWithTitle:textField.placeholder style:UIBarButtonItemStylePlain target:nil action:nil];
        [title setTintColor: [UIColor grayColor]];
        UIFont * font = [UIFont systemFontOfSize:14];
        NSDictionary * attributes = @{NSFontAttributeName: font};
        [title setTitleTextAttributes:attributes forState:UIControlStateNormal];
        title.enabled = NO;
        [items addObject:title];
    }
    
    UIBarButtonItem* spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:spaceButton1];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:target action:doneSelector];
    [doneButton setTintColor:[UIColor blackColor]];
    [items addObject:doneButton];
    
    [toolBar setItems:items animated:NO];
    toolBar.userInteractionEnabled = YES;
    
    textField.inputView = datePicker;
    textField.inputAccessoryView = toolBar;
    
    return datePicker;
}

+(void)determineCameraAccessPermission: (void(^)(BOOL))completion{
    //check authorizationStatus
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        completion(YES);
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                completion(YES);
            } else {
                completion(NO);
            }
        }];
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
        completion(NO);
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                completion(YES);
            } else {
                completion(NO);
            }
        }];
    } else {
        // impossible, unknown authorization status
        completion(NO);
    }
}

+(void)determinePhotoGalleryAccessPermission: (void(^)(BOOL))completion {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
        completion(YES);
    }
    
    else if (status == PHAuthorizationStatusDenied) {
        // Access has been denied.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                completion(YES);
            }
            
            else {
                // Access has been denied.
                completion(NO);
            }
        }];
    }
    
    else if (status == PHAuthorizationStatusNotDetermined) {
        
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                completion(YES);
            }
            
            else {
                // Access has been denied.
                completion(NO);
            }
        }];
    }
    
    else if (status == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
        completion(NO);
    }
}

+(void)presentImagePickerViewControllerOn:(UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>*)vc isImportVideo: (BOOL)isImportVideo {
    
    NSString* title = @"Select Photo Source";
    if (isImportVideo) {
        title = @"Select Media Source";
    }
    
    //Settings->Privacy->Camera must be enable to use camera function
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cameraButton = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self determineCameraAccessPermission:^(BOOL isAllowed) {
            if (isAllowed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                    imagePickerController.delegate = vc;
                    imagePickerController.allowsEditing = true;
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [vc presentViewController: imagePickerController
                                     animated: YES
                                   completion: nil];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Access to Camera is denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                });
            }
        }];
        
    }];
    UIAlertAction *albumButton = [UIAlertAction actionWithTitle:@"Select Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self determinePhotoGalleryAccessPermission:^(BOOL isAllowed) {
            if (isAllowed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = vc;
                    picker.allowsEditing = YES;
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    
                    [vc presentViewController:picker animated:YES completion:NULL];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Access to Gallery is denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                });
                
            }
        }];
        
    }];
    UIAlertAction *videoButton = [UIAlertAction actionWithTitle:@"Select Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self determinePhotoGalleryAccessPermission:^(BOOL isAllowed) {
            if (isAllowed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = vc;
                    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie, (NSString*)kUTTypeVideo, nil];
                    
                    [vc presentViewController:picker animated:YES completion:NULL];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Access to Gallery is denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                });
            }
        }];
        
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cameraButton];
    [alertController addAction:albumButton];
    if (isImportVideo) {
        [alertController addAction:videoButton];
    }
    [alertController addAction:cancelBtn];
    
    [vc presentViewController:alertController animated:YES completion:nil];
}

+ (NSString *)mimeTypeForImageData:(NSData *)imagedata {
    uint8_t c;
    [imagedata getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
            break;
        case 0x42:
            return @"image/bmp";
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

+ (void)addressFromLatLong : (NSString*)lat lon:(NSString*)lon success:(void (^)(NSDictionary*))success fail: (void (^)(NSError*))fail {
    
    dispatch_async(CONCURRENT_QUEUE, ^{
        NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&amp;sensor=false",lat,lon];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        request.timeoutInterval = 10.0f;
        NSURLResponse *response = nil;
        NSError *requestError = nil;
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&requestError];
        
        if (requestError != nil || responseData == nil) {
            fail(requestError);
            return;
        }
        
        NSError *error;
        NSMutableDictionary *results = [NSJSONSerialization
                                        JSONObjectWithData:responseData
                                        options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments
                                        error:&error];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error);
            });
            return;
        }
        
        NSArray *resultsArray = [results valueForKey:@"results"];
        
        if (resultsArray.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail([[NSError alloc] initWithDomain:@"" code:1 userInfo:@{@"error":@"can't fetch data"}]);
            });
            return;
        }
        
        NSString *fulladdress = [[resultsArray objectAtIndex:0] valueForKey:@"formatted_address"];
        NSString* city_longname = @"";
        NSString* city_shortname = @"";
        NSString* state_longname = @"";
        NSString* state_shortname = @"";
        NSString* country_longname = @"";
        NSString* country_shortname = @"";
        
        NSArray* address_components = [resultsArray[0] valueForKey:@"address_components"];
        for (NSDictionary* addressPart in address_components) {
            if ([(NSArray*)addressPart[@"types"] containsObject:@"locality"] && [(NSArray*)addressPart[@"types"] containsObject:@"political"]) {
                city_longname = addressPart[@"long_name"];
                city_shortname = addressPart[@"short_name"];
            }
            else if ([(NSArray*)addressPart[@"types"] containsObject:@"administrative_area_level_1"] && [(NSArray*)addressPart[@"types"] containsObject:@"political"]) {
                state_longname = addressPart[@"long_name"];
                state_shortname = addressPart[@"short_name"];
            }
            else if ([(NSArray*)addressPart[@"types"] containsObject:@"country"] && [(NSArray*)addressPart[@"types"] containsObject:@"political"]) {
                country_longname = addressPart[@"long_name"];
                country_shortname = addressPart[@"short_name"];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(@{@"fulladdress":fulladdress, @"country":@[country_shortname, country_longname], @"state":@[state_shortname, state_longname], @"city":@[city_shortname, city_longname]});
        });
    });
    
}

+(void) predictAddressesWithCityName:(NSString*)cityname
                             success: (void (^)(NSArray<NSDictionary*>* ))success
                                fail: (void (^)(NSError*))fail {
    dispatch_async(CONCURRENT_QUEUE, ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=(cities)&key=%@&sensor=true", cityname, GOOGLE_API_KEY]]];
        
        if (data)
        {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            
            // Digging into JSON for predictions array
            NSArray* predictions = [json objectForKey:@"predictions"];
            NSMutableArray<NSDictionary*> *results = [[NSMutableArray alloc] init];
            
            for (NSDictionary* prediction in predictions) {
                //extract city, state and country
                NSString* loc = prediction[@"description"];
                NSArray* location = [loc componentsSeparatedByString: @", "];
                
                NSString *state = @"";
                NSString *country = @"";
                NSString *city = @"";
                
                if (location.count > 2)
                {
                    state = location[1];
                    country = location[2];
                    
                }
                else if (location.count == 2)
                {
                    country = location[1];
                }
                
                city = location[0];
                [results addObject:@{@"city":city, @"state":state, @"country":country, @"fulladdress":loc}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(results);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail([[NSError alloc] initWithDomain:@"" code:1 userInfo:@{@"error":@"can't fetch data"}]);
            });
        }
    });
    
}

+(void) predictAddressesWithCityName:(NSString*)cityname
                         withinState:(NSString*)shortStateName
                       withinCountry:(NSString*)countryName
                             success:(void (^)(NSArray<NSDictionary*>* ))success
                                fail:(void (^)(NSError*))fail {
    dispatch_async(CONCURRENT_QUEUE, ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=(cities)&key=%@&sensor=true", cityname, GOOGLE_API_KEY]]];
        
        if (data)
        {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    fail(error);
                });
                return;
            }
            
            // Digging into JSON for predictions array
            NSArray* predictions = [json objectForKey:@"predictions"];
            NSMutableArray<NSDictionary*> *results = [[NSMutableArray alloc] init];
            
            for (NSDictionary* prediction in predictions) {
                //extract city, state and country
                NSString* loc = prediction[@"description"];
                NSArray* location = [loc componentsSeparatedByString: @", "];
                
                NSString *_shortState = @"";
                NSString *_country = @"";
                NSString *city = @"";
                
                if (location.count > 2)
                {
                    _shortState = location[1];
                    _country = location[2];
                    
                }
                else if (location.count == 2)
                {
                    _country = location[1];
                }
                
                if (![_shortState isEqualToString:@""] && ![shortStateName isEqualToString:@""]) {
                    if (![shortStateName containsString:_shortState] && ![_shortState containsString:shortStateName]) {
                        continue;
                    }
                    else {
                        if ([_country isEqualToString:countryName]) {
                            
                            city = location[0];
                            [results addObject:@{@"city":city, @"state":_shortState, @"country":_country, @"fulladdress":loc}];
                        }
                    }
                }
                else {
                    
                    if ([_country isEqualToString:countryName]) {
                        
                        city = location[0];
                        [results addObject:@{@"city":city, @"state":_shortState, @"country":_country, @"fulladdress":loc}];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(results);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail([[NSError alloc] initWithDomain:@"" code:1 userInfo:@{@"error":@"can't fetch data"}] );
            });
        }
    });
    
}

+(void)predictAddressesWith:(NSString *)address_part
                    success:(void (^)(NSArray<NSDictionary*>* ))success
                       fail:(void (^)(NSError *))fail {
    dispatch_async(CONCURRENT_QUEUE, ^{
        NSString *strUrl =
        [[[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?sensor=false&key=%@&input=%@",
           GOOGLE_API_KEY,
           address_part]
          stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
         stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        
        NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl] options:NSDataReadingUncached error:nil];
        
        if (responseData) {
            NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:Nil];
            NSArray *predictions = dictResponse[@"predictions"];
            
            NSMutableArray<NSDictionary*> *results = [[NSMutableArray alloc] init];
            
            for (NSDictionary* prediction in predictions) {
                //extract city, state and country
                NSString* loc = prediction[@"description"];
                NSArray* location = [loc componentsSeparatedByString: @", "];
                
                NSString *state = @"";
                NSString *country = @"";
                NSString *city = @"";
                
                if (location.count > 2)
                {
                    state = location[1];
                    country = location[2];
                    
                }
                else if (location.count == 2)
                {
                    country = location[1];
                }
                
                city = location[0];
                [results addObject:@{@"city":city, @"state":state, @"country":country, @"fulladdress":loc}];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(results);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail([[NSError alloc] initWithDomain:@"" code:1 userInfo:@{@"error":@"can't fetch data"}]);
            });
        }
    });
    
}

+(void)addressFullComponentsFrom:(NSString *)address_part success:(void (^)(NSDictionary *))success fail:(void (^)(NSError *))fail {
    
    @synchronized (self) {
        NSString* correctedAddress = [address_part stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet symbolCharacterSet]];
        NSURL* url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false", correctedAddress]];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error != nil || data ==nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    fail(error);
                });
                return;
            }
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    fail(error);
                });
                return;
            }
            
            NSString *lat = [[[[dic[@"results"] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] objectAtIndex:0];
            NSString *lon = [[[[dic[@"results"] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] objectAtIndex:0];
            
            NSArray *resultsArray = [dic valueForKey:@"results"];
            
            if (resultsArray.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    fail([[NSError alloc] initWithDomain:@"" code:1 userInfo:@{@"error":@"can't fetch data"}]);
                });
                return;
            }
            
            NSString *fulladdress = [[resultsArray objectAtIndex:0] valueForKey:@"formatted_address"];
            NSString* city_longname = @"";
            NSString* city_shortname = @"";
            NSString* state_longname = @"";
            NSString* state_shortname = @"";
            NSString* country_longname = @"";
            NSString* country_shortname = @"";
            
            NSArray* address_components = [resultsArray[0] valueForKey:@"address_components"];
            for (NSDictionary* addressPart in address_components) {
                if ([(NSArray*)addressPart[@"types"] containsObject:@"locality"] && [(NSArray*)addressPart[@"types"] containsObject:@"political"]) {
                    city_longname = addressPart[@"long_name"];
                    city_shortname = addressPart[@"short_name"];
                }
                else if ([(NSArray*)addressPart[@"types"] containsObject:@"administrative_area_level_1"] && [(NSArray*)addressPart[@"types"] containsObject:@"political"]) {
                    state_longname = addressPart[@"long_name"];
                    state_shortname = addressPart[@"short_name"];
                }
                else if ([(NSArray*)addressPart[@"types"] containsObject:@"country"] && [(NSArray*)addressPart[@"types"] containsObject:@"political"]) {
                    country_longname = addressPart[@"long_name"];
                    country_shortname = addressPart[@"short_name"];
                }
            }
            
            NSDictionary *addressComp = @{@"fulladdress":fulladdress, @"country":@[country_shortname, country_longname], @"state":@[state_shortname, state_longname], @"city":@[city_shortname, city_longname], @"lat":[NSString stringWithFormat:@"%@", lat] , @"lon":[NSString stringWithFormat:@"%@", lon]};
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(addressComp);
            });
            return;
            
            
        }] resume];
    }
}

+(UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(void)phoneCall: (NSString*)phoneNumber notAvailable:(void(^)(void))notAvailable{
    phoneNumber     = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    phoneNumber    = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSURL *phoneUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumber]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else {
        notAvailable();
    }
}

+(NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

+(NSString *)mimeTypeWithFileExtension: (NSString*)fileExtension {
    NSString *UTI = (__bridge_transfer NSString*)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    NSString *mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!mimeType) {
        return @"application/octet-stream";
    }
    return mimeType;
}

@end

