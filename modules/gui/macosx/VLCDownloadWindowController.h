/*****************************************************************************

 * VLCDownloadWindowController.h: macOS authorized media download window

 *****************************************************************************
 * Copyright (C) 2026 VideoLAN
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 or later.
 *****************************************************************************/

#import <Cocoa/Cocoa.h>

@class VLCMediaDownloader;

NS_ASSUME_NONNULL_BEGIN

@interface VLCDownloadWindowController : NSWindowController <NSTextFieldDelegate>

@property (nonatomic, strong, readonly) VLCMediaDownloader *downloader;

@property (nonatomic, weak) IBOutlet NSTextField *urlField;
@property (nonatomic, weak) IBOutlet NSButton *authorizationCheck;
@property (nonatomic, weak) IBOutlet NSPopUpButton *formatPopup;
@property (nonatomic, weak) IBOutlet NSTextField *folderField;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, weak) IBOutlet NSTextField *statusLabel;
@property (nonatomic, weak) IBOutlet NSButton *chooseFolderButton;
@property (nonatomic, weak) IBOutlet NSButton *downloadButton;
@property (nonatomic, weak) IBOutlet NSButton *cancelButton;

- (IBAction)authorizationChanged:(id)sender;
- (IBAction)chooseFolder:(id)sender;
- (IBAction)download:(id)sender;
- (IBAction)cancelDownload:(id)sender;

@end

NS_ASSUME_NONNULL_END
