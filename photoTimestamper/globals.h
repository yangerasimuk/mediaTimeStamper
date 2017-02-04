//
//  globals.h
//  photoTimestamper
//
//  Created by Ян on 29/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

// YES - no additional info about work printed,
// NO - all information about apps work printed
// default - YES
BOOL isAppModeSilent;

// YES - rename files using file attributes
// NO - ignore files without EXIF
// default - NO
BOOL isAppModeProcessFilesWithoutMeta;

// YES - app working in test mode -> not delete old files for visual results
// NO - real works, whithout test
// default - NO
BOOL isAppModeTest;

