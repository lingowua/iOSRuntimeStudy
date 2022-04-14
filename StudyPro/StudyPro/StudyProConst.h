//
//  StudyProConst.h
//  StudyPro
//
//  Created by lingowu on 2022/4/14.
//

#ifndef StudyProConst_h
#define StudyProConst_h

#define LOG_ENABLE 0

#if LOG_ENABLE
#define LGLog(...) NSLog(__VA_ARGS__)
#else
#define LGLog(...) {}
#endif

#endif /* StudyProConst_h */
