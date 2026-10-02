/*****************************************************************************

 * VLCMediaDownloader.h: authorized media downloader

 *****************************************************************************
 * Copyright (C) 2026 VideoLAN
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 or later.
 *****************************************************************************/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VLCMediaDownloader : NSObject

@property (nonatomic, readonly, getter=isRunning) BOOL running;
@property (nonatomic, readonly) NSInteger progress;
@property (nonatomic, readonly, copy) NSString *status;

/* Optional local session, enabled explicitly in the download window. */
@property (nonatomic, copy, nullable) NSString *cookiesBrowser;

- (void)downloadURL:(NSURL *)URL
             folder:(NSURL *)folder
         audioOnly:(BOOL)audioOnly;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
