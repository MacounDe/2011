//
//  NoARC.m
//  Macoun Demo
//
//  CC-SA-BY Daniel Höpfl
//

#import "NoARC.h"

/**
 * Erweitert @c NoARC um die Label-Property.
 */
@interface NoARC()

/// Das Label der Instanz
@property (nonatomic, strong) NSString *label; 

@end

#pragma mark -

@implementation NoARC

@synthesize label = _label;

/**
 * Erzeugt eine neue Instanz und weist ihr ein Label zu.
 */
+ (id) allocWithLabel:(NSString *)label {
    NoARC *result = [super allocWithZone:nil];
    NSLog(@"NoARC - allocWithLabel - %@", label);
    result.label = label;
    return result;
}

/**
 * Erzeugt eine neue Instanz, weist ihr aber mein Label zu.
 */
+ (id) allocWithZone:(NSZone *)zone {
    NSLog(@"NoARC - allocWithZone - ???");
    return [super allocWithZone:zone];
}

/**
 * Erzeugt eine neue Instanz, weist ihr aber mein Label zu.
 */
+ (id) alloc {
    NSLog(@"NoARC - alloc - ???");
    return [super alloc];
}

/**
 * Initialisiert die Instanz, ohne das Label zu ändern.
 */
- (id) init {
    NSLog(@"NoARC - init - %@", self.label);
    
    return [self initWithLabel:nil];
}

/**
 * Initialisiert die Instanz, ändert das Label, falls es nicht @c nil ist.
 *
 * @param label Neues Label oder @c nil, wenn das Label nicht geändert werden soll.
 */
- (id)initWithLabel:(NSString *)label;
{
    self = [super init];
    if (self) {
        if (label != nil) {
            self.label = label;
            
            NSLog(@"NoARC - initWithLabel - %@", self.label);
        }
    }
    
    return self;
}

/**
 * Beschreibung der Instanz (vor allem: Label).
 */
- (NSString *) description {
    return [NSString stringWithFormat:@"[NoARC - description - %@]", self.label];
}

/**
 * @c retain plus Logging.
 */
- (id) retain {
    NSLog(@"NoARC - retain - %@", self.label);
    return [super retain];
}

/**
 * @c autorelease plus Logging.
 */
- (id) autorelease {
    NSLog(@"NoARC - autorelease - %@", self.label);
    return [super autorelease];
}

/**
 * @c release plus Logging.
 */
- (oneway void) release {
    NSLog(@"NoARC - release - %@", self.label);
    [super release];
    return;
}

/**
 * @c dealloc plus Logging.
 */
- (void) dealloc {
    NSLog(@"NoARC - dealloc - %@", self.label);
    [super dealloc];
}

@end
