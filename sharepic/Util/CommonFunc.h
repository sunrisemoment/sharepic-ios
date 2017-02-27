//
//  Header.h
//  findtalents
//
//  Created by steven on 15/4/2016.
//  Copyright © 2016 steven. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import <Foundation/Foundation.h>
#import "StevenCore.h"

#define CONCURRENT_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define SERIAL_QUEUE(QUEUE_IDENTIFER) dispatch_queue_create([QUEUE_IDENTIFER UTF8String] ,DISPATCH_QUEUE_SERIAL)
#define GOOGLE_API_KEY  @"AIzaSyB_EcXdmIPgwI76xj4buFdUAwpm0ZYGMbY"

#endif /* Header_h */

@interface UIViewController (BackViewController)
-(UIViewController*)backViewController;
@end

@interface CommonFunc : NSObject

/**
 *show MBProgressHud which doesn't block the user interaction for the view
 *
 */
+ (void)showMBProgressHudOn:(UIView *)view withText:(NSString*)text delay:(CGFloat)seconds;

+ (void)showMBProgressHudOn:(UIView *)view withText:(NSString*)text delay:(CGFloat)seconds blockUserInteraction: (BOOL)flag;
+ (BOOL)isEmailWith:(NSString *)string;

/**
 *set pickerview as inputview to the specified textfield and return that pickerview, so user can set delegate and datasource for it additionally
 *@return setted pickerView
 */
+(UIPickerView*) setInputPickerViewAndToolBarTo:(UITextField*)textField andWithTarget:(id<UIPickerViewDelegate, UIPickerViewDataSource>)target andWithDoneAction:(SEL)doneSelector andWithCancelAction:(SEL)cancelSelector andHeight:(NSInteger)height;

/**
 *set datePicker as inputview to the specified textfield and return that datePicker, so user can do more work for it additionally
 *can be customized in source to adjust the date range
 *@return setted datePicker
 */
+(UIDatePicker*)setDatePickerViewAndToolBarTo:(UITextField*)textField andWithTarget:(id)target andWithValueChangedAction:(SEL)valueChangedAction andWithDoneAction:(SEL)doneSelector andWithCancelAction:(SEL)cancelSelector from:(NSDate*)from to:(NSDate*)to;

+(void)determineCameraAccessPermission: (void(^)(BOOL))completion;

+(void)determinePhotoGalleryAccessPermission: (void(^)(BOOL))completion;

/**
 *present ImagePickerViewController on the specified viewController, here the view controller must adopt the UIImagePickerControllerDelegate, UINavigationControllerDelegate
 the reason why UINavigionControllerDelegate is used is that in the presentedPickerController, we need to navigate to the controller that present photos or vidoes.
 at first, must import MobileCoreService.framework
 
 *****************the delegate method could be as following****************
 
 func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
 
     let mediaType = info[UIImagePickerControllerMediaType]
     
     if let type:AnyObject = mediaType {
        if type is String {
            let stringType = type as! String
            if (stringType == kUTTypeMovie as String) || (stringType == kUTTypeVideo as String) {
                let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                if let url = urlOfVideo {
                    let videoData = NSData(contentsOfURL: url)
     
                }
            }
            else if stringType == kUTTypeImage as String {
                let image = info[UIImagePickerControllerEditedImage] as! UIImage
     
            }
        }
     }
     
     picker.dismissViewControllerAnimated(true, completion: nil)
 }
 
 */

/**
 *get the mimetype of the imagedata
 */
+ (NSString *)mimeTypeForImageData:(NSData *)imagedata;

/**
 *get formattted address data from lat and lon, and callback is executed in main queue
 *
 *@return @{@"fulladdress":fulladdress, @"country":@[country_shortname, country_longname], @"state":@[state_shortname, state_longname], @"city":@[city_shortname, city_longname]}
 */
+ (void)addressFromLatLong : (NSString*)lat lon:(NSString*)lon success:(void (^)(NSDictionary*))success fail: (void (^)(NSError*))fail;

/**
 *@param type passed in success block; @[@{@"city":city, @"state":state, @"country":country, @"fulladdress":address}, ...], and callback is executed in main queue
 */
+(void) predictAddressesWithCityName:(NSString*)cityname
                             success: (void (^)(NSArray<NSDictionary*>* ))success
                                fail: (void (^)(NSError*))fail;
/**
 *if stateName is empty, search results in only for country
 **/
+(void) predictAddressesWithCityName:(NSString*)cityname
                         withinState:(NSString*)shortStateName
                       withinCountry:(NSString*)country
                             success:(void (^)(NSArray<NSDictionary*>* ))success
                                fail:(void (^)(NSError*))fail;

/**
 *@param type passed in success block; @[@{@"city":city, @"state":state, @"country":country, @"fulladdress":address}, ...], and callback is executed in main queue queue. Here, state is short name
 */
+(void)predictAddressesWith:(NSString *)address_part
                    success:(void (^)(NSArray<NSDictionary*>* ))success
                       fail:(void (^)(NSError *))fail;

/**
 *callback is executed in main queue
 *
 *@param type passed in success block; @{@"fulladdress":fulladdress, @"country":@[country_shortname, country_longname], @"state":@[state_shortname, state_longname], @"city":@[city_shortname, city_longname], @"lat":lat, @"lon":lon}
 */
+(void)addressFullComponentsFrom:(NSString *)address_part success:(void (^)(NSDictionary *))success fail:(void (^)(NSError *))fail;

+ (void)startWaitingMBProgressHudOn:(UIView*)view;
+ (void)startWaitingMBProgressHudOn:(UIView*)view isBlockView: (BOOL)flag;
+ (void)startWaitingMBProgressHudOn:(UIView*)view isBlockScreen: (BOOL)flag;
+ (void)startWaitingMBProgressHudOn:(UIView*)view andTag:(NSString*)tag;
+ (void)startWaitingMBProgressHudOn:(UIView *)view andTag:(NSString *)tag isBlockView: (BOOL)flag;
+ (void)startWaitingMBProgressHudOn:(UIView *)view andTag:(NSString *)tag Title:(NSString *)title isBlockView: (BOOL)flag;
+ (void)startWaitingMBProgressHudOn:(UIView *)view andTag:(NSString *)tag Title:(NSString *)title  Detail:(NSString *)detail isBlockView: (BOOL)flag;
+ (void)startWaitingMBProgressHudOn:(UIView*)view andTag:(NSString*)tag isBlockScreen: (BOOL)flag;
+ (void)commitWaitingMBProgressHudOn:(UIView*)view;
+ (void)commitWaitingMBProgressHudWithTag:(NSString*)tag;

+(UIImage *)imageResize: (UIImage*)img andResizeTo:(CGSize)newSize;

+(void)phoneCall: (NSString*)phoneNumber notAvailable:(void(^)(void))notAvailable;

+(NSString *)documentsPathForFileName:(NSString *)name;

+(NSString *)mimeTypeWithFileExtension: (NSString*)fileExtension;

+(void) showMBProgressHudOn:(UIView *)view withTitle:(NSString *)title blockView: (BOOL)flag;

@end
