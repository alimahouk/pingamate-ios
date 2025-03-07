//
//  constants.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/20/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#ifndef CONSTANTS_H
#define CONSTANTS_H

#define NSUDKEY_CAMERA_GRID             @"CameraGrid"
#define NSUDKEY_PRELIMINARY_IMAGE       @"PreliminaryImageMessageID"
#define NSUDKEY_PRELIMINARY_TEXT        @"PreliminaryTextMessageID"
#define NSUDKEY_PRELIMINARY_VIDEO       @"PreliminaryVideoMessageID"
#define NSUDKEY_USER_HANDLE             @"CurrentUserHandle"
#define PM_DEFAULT_STROKE_COLOR         [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0]
#define PM_DEFAULT_STROKE_SIZE          5.5
#define PM_DIR_KEYS                     @"Keys"
#define PM_DIR_IMAGES                   @"Images"
#define PM_DIR_VIDEOS                   @"Videos"
#define PM_FILE_CLIENT_PRIVATE_KEY      @"client_private"
#define PM_FILE_CLIENT_PUBLIC_KEY       @"client_public"
#define PM_FILE_SERVER_PUBLIC_KEY       @"server_public"
#define PM_LIVE_REACTION_FRAMES         15
#define PM_MAGIC_NUM                    {0x89, 0x50, 0x44, 0x48, 0x5A, 0x0d, 0x0a, 0x1a, 0x0a}
#define PM_MAGIC_NUM_LEN                9
#define PM_MAX_VIDEO_LENGTH             15 // Seconds.
#define PM_PROTO_VERSION                1
#define PM_SERVER_CONNECTION_TIMEOUT    10
#define PM_SERVER_KEY_CHECKSUM          @"E5919AB78C5920B0AD025B2BB0DE631659C8D76A0C5D0434DBB8354637447F0B"
#define PM_SERVER_PORT                  1443
#define PM_SERVER_ADDRESS               @"192.168.0.116"
#define PM_THEME_BLUE                   [UIColor colorWithRed:14/255.0 green:122/255.0 blue:254/255.0 alpha:1.0]
#define PM_THEME_RED                    [UIColor colorWithRed:255/255.0 green:94/255.0 blue:58/255.0 alpha:1.0]
#define ZLIB_CHUNK                      16384

/*
 * Slots 1 -> 16 are reserved for server messages.
 */
typedef enum {
        PMErrorHandleUnavailable
} PMError;

typedef enum {
        PMFlashModeOff = 1,
        PMFlashModeOn,
        PMFlashModeAuto
} PMFlashMode;

typedef enum {
        PMMediaTypeNone = 0,
        PMMediaTypePhoto = 1,
        PMMediaTypeVideo
} PMMediaType;

typedef enum {
        PMMessageTypeNone = 0,
        PMMessageTypeError = 1,
        PMMessageTypeGreeting,
        PMMessageTypeLatestState,
        PMMessageTypeIM = 17,
        PMMessageTypePresence,
        PMMessageTypeStatus
} PMMessageType;

typedef enum {
        PMNippleDirectionDownHidden,
        PMNippleDirectionUpHidden,
        PMNippleDirectionDown,
        PMNippleDirectionUp
} PMNippleDirection;

typedef enum {
        PMUserPresenceOffline,
        PMUserPresenceOnline,
        PMUserPresenceTyping
} PMUserPresence;

#endif /* CONSTANTS_H */
