//
//  NSStringObfuscationSpec.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "Kiwi.h"

#import "NSString+Obfuscation.h"

SPEC_BEGIN(NSStringObfuscationSpec)

describe(@"NSString+Obfsucation", ^{
    
    it(@"should properly obfuscate and deobfuscate arbitrary UTF-8 strings", ^{
        
        // Samples taken from http://www.cl.cam.ac.uk/~mgk25/ucs/examples/quickbrown.txt
        
        NSArray *strings = @[ @"Quizdeltagerne spiste jordbær med fløde, mens cirkusklovnen",
                              @"Falsches Üben von Xylophonmusik quält jeden größeren Zwerg",
                              @"Γαζέες καὶ μυρτιὲς δὲν θὰ βρῶ πιὰ στὸ χρυσαφὶ ξέφωτο",
                              @"The quick brown fox jumps over the lazy dog",
                              @"El pingüino Wenceslao hizo kilómetros bajo exhaustiva lluvia y frío, añoraba a su querido cachorro.",
                              @"Le cœur déçu mais l'âme plutôt naïve, Louÿs rêva de crapaüter en canoë au delà des îles, près du mälström où brûlent les novæ.",
                              @"D'fhuascail Íosa, Úrmhac na hÓighe Beannaithe, pór Éava agus Ádhaimh",
                              @"Árvíztűrő tükörfúrógép",
                              @"Kæmi ný öxi hér ykist þjófum nú bæði víl og ádrepa",
                              @"イロハニホヘト チリヌルヲ ワカヨタレソ ツネナラム ウヰノオクヤマ ケフコエテ アサキユメミシ ヱヒモセスン",
                              @"דג סקרן שט בים מאוכזב ולפתע מצא לו חברה איך הקליטה",
                              @"Pchnąć w tę łódź jeża lub ośm skrzyń fig",
                              @"В чащах юга жил бы цитрус? Да, но фальшивый экземпляр!",
                              @"กว่าบรรดาฝูงสัตว์เดรัจฉาน",
                              @"Pijamalı hasta, yağız şoföre çabucak güvendi." ];
        
        [strings enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
            NSString *obfuscated = [NSString stringByObfuscatingString:string];
            [[string shouldNot] equal:obfuscated];
            [[string should] equal:[NSString stringByDeobfuscatingString:obfuscated]];
        }];
        
    });
    
});

SPEC_END