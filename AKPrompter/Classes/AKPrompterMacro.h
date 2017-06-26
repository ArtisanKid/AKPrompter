//
//  AKPrompterMacro.h
//  Pods
//
//  Created by 李翔宇 on 2017/6/12.
//
//

#ifndef AKPrompterMacro_h
#define AKPrompterMacro_h

#if DEBUG
    #define AKPrompterLog(_Format, ...)\
    do {\
        printf("\n");\
        NSString *file = [NSString stringWithUTF8String:__FILE__].lastPathComponent;\
        NSLog((@"\n[%@][%d][%s]\n" _Format), file, __LINE__, __PRETTY_FUNCTION__, ## __VA_ARGS__);\
        printf("\n");\
    } while(0)
#else
    #define AKPrompterLog(_Format, ...)
#endif

#endif /* AKPrompterMacro_h */
