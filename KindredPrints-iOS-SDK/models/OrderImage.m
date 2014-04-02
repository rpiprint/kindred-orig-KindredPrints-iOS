//
//  OrderImage.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/3/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "OrderImage.h"
#import "ImageEditor.h"

@implementation OrderImage

- (OrderImage *)initWithOutSize:(BaseImage *)image {
    self.image = image;
    self.printProducts = [[NSArray alloc] init];
    self.printProductsInit = NO;
    return self;
}

- (OrderImage *)initWithImage:(BaseImage *)image andSize:(CGSize)size {
    if (!self.printProductsInit) {
        self.image = image;
        self.printProducts = [[ImageEditor getAllowablePrintableSizesForImageSize:size] copy];
        if ([self.printProducts count]) {
            for (PrintableSize *product in self.printProducts) {
                product.sQuantity = 1;
            }
            self.printProductsInit = YES;
        }
    }
    return self;
}

- (OrderImage *) initWithPackedOrder:(NSDictionary *)savedObject {
    self.image = [[BaseImage alloc] initWithPackedImage:[savedObject objectForKey:ORDER_IMAGE]];
    self.printProductsInit = [[savedObject objectForKey:ORDER_INIT] boolValue];
    NSMutableArray *printedProducts = [[NSMutableArray alloc] init];
    NSArray *savedProducts = [savedObject objectForKey:ORDER_PRINTS_LIST];
    for (NSDictionary *savedProduct in savedProducts) {
        [printedProducts addObject:[[PrintableSize alloc] initWithPackedSize:savedProduct]];
    }
    self.printProducts = printedProducts;
    return self;
}
- (NSDictionary *) packOrder {
    NSMutableArray *packedProducts = [[NSMutableArray alloc] init];
    for (PrintableSize *size in self.printProducts) {
        [packedProducts addObject:[size packSize]];
    }
    NSDictionary *packedOrder = [[NSDictionary alloc]
                                 initWithObjects:@[
                                                   [self.image packImage],
                                                   [NSNumber numberWithBool:self.printProductsInit],
                                                   packedProducts
                                                   ]
                                 forKeys:@[ORDER_IMAGE,
                                           ORDER_INIT,
                                           ORDER_PRINTS_LIST]];
    return packedOrder;
}

- (void)updateOrderSizes {
    NSArray *newSizes = [ImageEditor getAllowablePrintableSizesForImageSize:CGSizeMake(self.image.pWidth, self.image.pHeight)];
    NSMutableArray *finalOutputSizeList = [[NSMutableArray alloc] init];
    for (PrintableSize *newSize in newSizes) {
        BOOL exists = NO;
        for (PrintableSize *size in self.printProducts) {
            if ([size.sid isEqualToString:newSize.sid]) {
                [finalOutputSizeList addObject:size];
                exists = YES;
                break;
            }
        }
        if (!exists) {
            PrintableSize *product = [newSize copy];
            product.sQuantity = 1;
            [finalOutputSizeList addObject:product];
        }
    }
    self.printProducts = finalOutputSizeList;
}

@end
