/* ArnMotion Player — authorized downloads. Studio Arn, 2026.
 * Adapted from the provided VLCDownloadWindowController. GPL-2.0-or-later.
 * Original source attribution: Copyright (C) 2026 VideoLAN. */
#import "VLCDownloadWindowController.h"
#import "VLCMediaDownloader.h"
#import "ArnMotionGlassView.h"

static void *ArnDownloadObservation = &ArnDownloadObservation;

@interface VLCDownloadWindowController ()
@property (nonatomic, strong, readwrite) VLCMediaDownloader *downloader;
@property (nonatomic, strong) NSURL *downloadFolder;
@property (nonatomic) BOOL observing;
@property (nonatomic, weak) NSButton *sessionCheck;
- (void)buildDownloadInterface;
@end

@implementation VLCDownloadWindowController
- (instancetype)init
{
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 620, 430)
        styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
        backing:NSBackingStoreBuffered defer:NO];
    self = [super initWithWindow:window];
    if (self) {
        _downloader = [[VLCMediaDownloader alloc] init];
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES).firstObject;
        _downloadFolder = [NSURL fileURLWithPath:path ?: NSHomeDirectory()];
        [self buildDownloadInterface];
    }
    return self;
}

- (NSTextField *)label:(NSString *)text frame:(NSRect)frame
{
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.stringValue = text;
    label.editable = NO;
    label.selectable = YES;
    label.bezeled = NO;
    label.drawsBackground = NO;
    [self.window.contentView addSubview:label];
    return label;
}

- (NSButton *)button:(NSString *)title frame:(NSRect)frame action:(SEL)action
{
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    button.title = title;
    button.bezelStyle = NSRoundedBezelStyle;
    button.target = self;
    button.action = action;
    [self.window.contentView addSubview:button];
    return button;
}

- (void)buildDownloadInterface
{
    NSWindow *window = self.window;
    window.title = @"ArnMotion Player — Baixar vídeo autorizado";
    window.releasedWhenClosed = NO;
    window.collectionBehavior = NSWindowCollectionBehaviorFullScreenAuxiliary;
    // ArnMotion: use the same native dark glass as the player bars.
    window.opaque = NO;
    window.backgroundColor = [NSColor clearColor];
    ArnMotionInstallGlass(window.contentView);
    ArnMotionInstallTitleGlass(window);
    [window center];
    [self label:@"Endereço do vídeo (http ou https):" frame:NSMakeRect(24, 383, 570, 22)];
    NSTextField *url = [[NSTextField alloc] initWithFrame:NSMakeRect(24, 348, 570, 28)];
    [window.contentView addSubview:url];
    self.urlField = url;
    url.delegate = self;
    self.authorizationCheck = [self button:@"Tenho autorização para baixar este conteúdo"
        frame:NSMakeRect(24, 308, 570, 28) action:@selector(authorizationChanged:)];
    [self.authorizationCheck setButtonType:NSSwitchButton];
    [self label:@"Formato:" frame:NSMakeRect(24, 268, 85, 22)];
    NSPopUpButton *format = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(110, 263, 230, 28) pullsDown:NO];
    [format addItemsWithTitles:@[@"Vídeo — MP4", @"Áudio — MP3"]];
    [window.contentView addSubview:format];
    self.formatPopup = format;
    [self label:@"Salvar em:" frame:NSMakeRect(24, 225, 85, 22)];
    self.folderField = [self label:self.downloadFolder.path frame:NSMakeRect(110, 225, 350, 22)];
    self.folderField.cell.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.chooseFolderButton = [self button:@"Escolher…" frame:NSMakeRect(473, 218, 120, 32) action:@selector(chooseFolder:)];
    NSProgressIndicator *progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(24, 184, 570, 18)];
    progress.indeterminate = NO;
    progress.minValue = 0;
    progress.maxValue = 100;
    [window.contentView addSubview:progress];
    self.progressIndicator = progress;
    self.statusLabel = [self label:@"Baixe somente conteúdos que você esteja autorizado a obter."
        frame:NSMakeRect(24, 117, 570, 57)];
    self.statusLabel.cell.wraps = YES;
    self.sessionCheck = [self button:@"Usar sessão do Chrome no YouTube"
        frame:NSMakeRect(24, 74, 570, 28) action:@selector(authorizationChanged:)];
    [self.sessionCheck setButtonType:NSSwitchButton];
    self.sessionCheck.state = NSOffState;
    self.sessionCheck.toolTip = @"Usa localmente os cookies da sua sessão do Chrome. Não exporta um arquivo de cookies.";
    self.downloadButton = [self button:@"Baixar" frame:NSMakeRect(465, 24, 130, 32) action:@selector(download:)];
    self.cancelButton = [self button:@"Cancelar" frame:NSMakeRect(325, 24, 130, 32) action:@selector(cancelDownload:)];
    for (NSString *key in @[@"running", @"progress", @"status"])
        [self.downloader addObserver:self forKeyPath:key options:0 context:ArnDownloadObservation];
    self.observing = YES;
    [self updateControls];
}

- (void)dealloc
{
    if (_observing)
        for (NSString *key in @[@"running", @"progress", @"status"])
            [_downloader removeObserver:self forKeyPath:key context:ArnDownloadObservation];
    [_downloader cancel];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
    change:(NSDictionary *)change context:(void *)context
{
    if (context != ArnDownloadObservation) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    [self updateControls];
    self.progressIndicator.doubleValue = self.downloader.progress;
    if (self.downloader.status.length)
        self.statusLabel.stringValue = self.downloader.status;
}

- (void)updateControls
{
    BOOL running = self.downloader.running;
    NSString *url = [self.urlField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.urlField.enabled = !running;
    self.authorizationCheck.enabled = !running;
    self.sessionCheck.enabled = !running;
    self.formatPopup.enabled = !running;
    self.chooseFolderButton.enabled = !running;
    self.downloadButton.enabled = !running && self.authorizationCheck.state == NSOnState && url.length > 0;
    self.cancelButton.enabled = running;
}
- (void)controlTextDidChange:(NSNotification *)notification { [self updateControls]; }
- (IBAction)authorizationChanged:(id)sender { [self updateControls]; }
- (IBAction)chooseFolder:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = YES;
    panel.allowsMultipleSelection = NO;
    panel.directoryURL = self.downloadFolder;
    panel.prompt = @"Escolher";
    if ([panel runModal] == NSModalResponseOK) {
        self.downloadFolder = panel.URL;
        self.folderField.stringValue = panel.URL.path;
    }
}
- (IBAction)download:(id)sender
{
    if (self.downloader.running || self.authorizationCheck.state != NSOnState)
        return;
    NSString *text = [self.urlField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.downloader.cookiesBrowser = self.sessionCheck.state == NSOnState ? @"chrome" : nil;
    [self.downloader downloadURL:[NSURL URLWithString:text] folder:self.downloadFolder
        audioOnly:self.formatPopup.indexOfSelectedItem == 1];
}
- (IBAction)cancelDownload:(id)sender { [self.downloader cancel]; }
@end
