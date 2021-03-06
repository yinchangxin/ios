//
//  LMTest.m
//  Connect
//
//  Created by bitmain on 2017/3/8.
//  Copyright © 2017年 Connect. All rights reserved.
//

#import "Kiwi.h"
#import "RegexKit.h"
#import "LKUserCenter.h"
#import "LMLinkManDataManager.h"
#import "KeyHandle.h"
#import "PayTool.h"
#import "UserDBManager.h"
#import "StringTool.h"
#import "CameraTool.h"

SPEC_BEGIN(NetWorkOperationToolSpec)
describe(@"Math", ^{
    //Test the regular tool
    context(@"regex kit", ^{
        it(@"password", ^{
            BOOL result = [RegexKit vilidatePassword:@"123456"];
            [[theValue(result) should] beYes];
            
            BOOL result1 = [RegexKit vilidatePassword:@"12345"];
            [[theValue(result1) should] beNo];
            
            
            BOOL result2 = [RegexKit nameLengthLimit:@"123456"];
            [[theValue(result2) should] beYes];
            
            BOOL result3 = [RegexKit nameLengthLimit:@"12345678900"];
            [[theValue(result3) should] beNo];
            
        });

    });
    // Login related settings
    context(@"test login", ^{
        // Test whether the random number generated by the registered voice is 128
        it(@"rand url", ^{
            NSInteger firstObject = arc4random_uniform(1000);
            NSInteger lastObject = arc4random_uniform(1000);
            NSString* str = [LKUserCenter shareCenter].currentLoginUser.prikey;
            if(str.length <= 0) str = @"abcd";
            NSArray* cachArray = @[@(firstObject),str,@(lastObject)];
            NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString* cachePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%darray.data",arc4random_uniform(1000)]];
            [cachArray writeToFile:cachePath atomically:YES];
            NSData* data = [NSData dataWithContentsOfFile:cachePath];
            NSString* checkStr = [StringTool stringWithData:data];
            NSInteger strLen = 128;
            [[(theValue(checkStr.length)) should] equal:theValue(strLen)];
        });
    });
    // Set the relevant settings
       context(@"test set", ^{
            // Id can not be empty
            it(@"id is not null", ^{
                    NSString* idStr = [LKUserCenter shareCenter].currentLoginUser.contentId;
                    [[idStr shouldNot] beNil];
            
                   });
           // The user address can not be empty
            it(@"user address is not null", ^{
                    NSString* addressStr = [LKUserCenter shareCenter].currentLoginUser.address;
                    [[addressStr shouldNot] beNil];
                });
          });
    // Verify that the image is size (2m, 2k)
    context(@"image size test", ^{
       it(@"image test", ^{
           UIImage* imageName = [UIImage imageNamed:@"chat_bar_album"];
           NSData* imageData = UIImageJPEGRepresentation(imageName, 1.0);
           NSData* data = [CameraTool imageSizeLessthan2M:imageData withOriginImage:imageName];
           [theValue(data.length) beLessThan:theValue(2* 1024*1024)];
       });
        
        it(@"image test", ^{
            UIImage* imageName = [UIImage imageNamed:@"chat_bar_album"];
            NSData* imageData = UIImageJPEGRepresentation(imageName, 1.0);
            NSData* data = [CameraTool imageSizeLessthan2K:imageData withOriginImage:imageName];
            [theValue(data.length) beLessThan:theValue(2 * 1024)];
        });
        
    });
    // Keyhandle test
    context(@"Keyhandle test", ^{
        it(@"Create btc", ^{
            NSString *privkey = [KeyHandle creatNewPrivkey];
            [[theValue(privkey) shouldNot] beNil];
            
            NSString *rawPrivkey = [KeyHandle getRawPrivkey:privkey];
            [[theValue(rawPrivkey) shouldNot] beNil];
            
            NSString *publickey = [KeyHandle createPubkeyByPrikey:privkey];
            [[theValue(publickey) shouldNot] beNil];
            
            NSString *address1 = [KeyHandle getAddressByPrivKey:privkey];
            NSString *address2 = [KeyHandle getAddressByPubkey:publickey];
            [[theValue(address1) shouldNot] beNil];
            [[theValue(address2) shouldNot] beNil];
            [[address1 should] equal:address2];
            
            NSData *ecdh = [KeyHandle getECDHkeyWithPrivkey:[KeyHandle creatNewPrivkey] publicKey:publickey];
            NSInteger ecdhLen = 32;
            [[(theValue(ecdh.length)) should] equal:theValue(ecdhLen)];
            
            
            NSData *random = [KeyHandle createRandom512bits];
            [[theValue(random) shouldNot] beNil];
            
            
            NSString *encodePrivkey = [KeyHandle getEncodePrikey:privkey withBitAddress:address1 password:@"123456"];
            [[theValue(encodePrivkey) shouldNot] beNil];
            NSString *decodePri = [[KeyHandle decodePrikeyGetDict:encodePrivkey withPassword:@"123456"] valueForKey:@"prikey"];
            BOOL success = [[[KeyHandle decodePrikeyGetDict:encodePrivkey withPassword:@"123456"] valueForKey:@"is_success"] boolValue];
            [[theValue(success) should] beYes];
            [[decodePri should] equal:privkey];
        });
    });
    
    context(@"Stringtool test", ^{
        it(@"", ^{
            NSString *hex = [StringTool hexStringFromData:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
            NSData *data = [KeyHandle hexStringToData:hex];
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [[string should] equal:@"test"];
            
            NSData *random = [StringTool DataXOR1:[KeyHandle createRandom512bits] DataXOR2:[KeyHandle createRandom512bits]];
            [[theValue(random) shouldNot] beNil];
            
        });
    });
    
    // Test PayTool tool
    context(@"PayTool test", ^{
        it(@"PayTool", ^{
            NSString *amount = [PayTool getBtcStringWithAmount:11234566];
            [[amount should] equal:@"0.11234566"];
            
            NSString *amount2 = [PayTool getBtcStringWithAmount:0];
            [[amount2 should] equal:@"0.00000000"];
            
            NSString *amount1 = [PayTool getBtcStringWithDecimalAmount:[NSDecimalNumber decimalNumberWithString:@"11234566"]];
            [[amount1 should] equal:@"0.11234566"];
            
            NSString *amount4 = [PayTool getBtcStringWithDecimalAmount:[NSDecimalNumber decimalNumberWithString:@"0"]];
            [[amount4 should] equal:@"0"];
        });
    });
});
SPEC_END

