//
//  NSString+Help.m
//  Pipol
//
//  Created by HiTechLtd on 3/2/16.
//  Copyright © 2016 HiTechLtd. All rights reserved.
//

#import "NSString+Help.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Help)

- (BOOL)isEmpty
{
    NSString * trimed = [self stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimed.length == 0?TRUE:FALSE;
}

- (NSString *)urlEncode
{
    //http://tools.ietf.org/html/rfc3986#section-2.1
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)self,
                                                                                 NULL,
                                                                                 CFSTR(":/?#[]@!$&'()*+,;="),
                                                                                 kCFStringEncodingUTF8));
}

- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (BOOL)isValidEmail {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isCheckWhitleSpace {
    NSRange whiteSpaceRange = [self rangeOfString:@" "];
    if (whiteSpaceRange.location != NSNotFound) {
        return YES;
    }
    return NO;
}
@end
