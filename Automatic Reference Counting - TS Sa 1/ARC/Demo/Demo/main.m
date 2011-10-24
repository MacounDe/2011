//
//  Demo
//  Macoun Demo
//
//  CC-SA-BY Daniel Höpfl
//

#import <Foundation/Foundation.h>
#import <NoARC/NoARC.h>

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        
        NSLog(@"--- Autoreleasepool angelegt ---");
        
        {
#if 1   // Variante 1
    
            NoARC *noARC = [[NoARC allocWithLabel:@"Macoun"] init];
            
            NSLog(@"Inhalt: %@", noARC);
#else   // Variante 2
            NoARC *aussen;
            {
                NoARC *noARC = [[NoARC allocWithLabel:@"Macoun"] init];
                aussen = noARC;
                
                NSLog(@"Inhalt: %@", noARC);
            }
            NSLog(@"Aussen: %@", aussen);
#endif
        }
        
        NSLog(@"--- Autoreleasepool verschwindet ---");
    }
    
    NSLog(@"--- Autoreleasepool ist weg ---");
    
    return 0;
}
