//
//  MiSnapSDKScienceMicrResult.h
//  MiSnapSDKScience
//
//  Created by Steve Blake on 11/10/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 * MobileFlowMicrResult stores the value from a check or passport as the result
 * of the MiSnapScienceSDK analyzeFrame method
 *
 */
@interface MiSnapSDKScienceMicrResult : NSObject

/*!
 *  The confidence that the MICR/MRZ was found
 */
@property (nonatomic, assign) NSInteger confidence;

/*!
 *  The MICR/MRZ string depending on the document type (check or passport)
 */
@property (nonatomic, strong) NSString *micrString;

/*!
 *  The position of the MICR/MRZ
 */
@property (nonatomic, assign) CGRect micrPosition;

/*!
 *  Routing number parsed from the `micrString`
 */
@property (nonatomic, strong) NSString *routing;

/*!
 *  Account number parsed from the `micrString`
 */
@property (nonatomic, strong) NSString *account;

/*!
 *  The check number from the `micrString`
 */
@property (nonatomic, strong) NSString *check;

/*!
 *  The amount of the check from the `micrString` in cents
 */
@property (nonatomic, strong) NSString *amount;

/*!
 *  Image replacement document number from the `micrString`
 */
@property (nonatomic, strong) NSString *ird;

/*!
 *  The tran code from the `micrString`
 */
@property (nonatomic, strong) NSString *tranCode;

@end


