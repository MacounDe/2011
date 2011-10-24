//
//  NoARC.m
//  Macoun Demo
//
//  CC-SA-BY Daniel Höpfl
//

#import <Foundation/Foundation.h>

/**
 * @c NoARC tut nichts, außer sämtliche Methoden zu überschreiben
 * die für die Speicherverwaltung relevant sind und deren Aufrufe
 * zu loggen.
 */
@interface NoARC : NSObject

/**
 * Zusätzlicher Allokator, der der neu angelegten Instanz gleich
 * ein Label zuweist.
 * Das widerspricht zwar der normalen @c alloc/init Semantik, erlaubt
 * aber, dass schon beim alloc mit dem richtigen Label geloggt wird,
 * ohne dass man das Label beim init noch einmal angeben muss.
 *
 * @param label Das Label, das für diese Instanz verwendet werden soll.
 */
+ allocWithLabel:(NSString *)label;

/**
 * Initialisiert die Instanz mit einem Label. Diese Methode wird
 * normalerweise nicht benötigt, wenn @c allocWithLabel: benutzt wird.
 *
 * @param label Das Label, das für diese Instanz verwendet werden soll.
 */
- (id) initWithLabel:(NSString *)label;

@end
