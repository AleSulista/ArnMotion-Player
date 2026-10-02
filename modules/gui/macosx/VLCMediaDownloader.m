/* ArnMotion Player — Studio Arn, 2026. GPL-2.0-or-later.
 * Adapted from the provided VLCMediaDownloader.
 * Original source attribution: Copyright (C) 2026 VideoLAN. */
#import "VLCMediaDownloader.h"
#import <math.h>

@interface VLCMediaDownloader ()
@property (nonatomic, readwrite, getter=isRunning) BOOL running;
@property (nonatomic, readwrite) NSInteger progress;
@property (nonatomic, readwrite, copy) NSString *status;
@property (nonatomic, strong) NSTask *task;
@property (nonatomic) BOOL cancellationRequested;
@end

@implementation VLCMediaDownloader
- (instancetype)init
{
    self = [super init];
    if (self) _status = @"";
    return self;
}
- (NSString *)tool:(NSString *)name
{
    NSArray *directories = @[
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"tools"],
        @"/usr/local/bin", @"/opt/homebrew/bin", @"/usr/bin"];
    for (NSString *directory in directories) {
        NSString *path = [directory stringByAppendingPathComponent:name];
        if ([[NSFileManager defaultManager] isExecutableFileAtPath:path]) return path;
    }
    return nil;
}
- (void)downloadURL:(NSURL *)URL folder:(NSURL *)folder audioOnly:(BOOL)audioOnly
{
    if (self.running) return;
    NSString *scheme = URL.scheme.lowercaseString;
    if (!URL.host.length || !([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])) {
        self.status = @"Informe um endereço válido iniciado por http:// ou https://.";
        return;
    }
    BOOL directory = NO;
    NSFileManager *files = [NSFileManager defaultManager];
    if (!folder.isFileURL || ![files fileExistsAtPath:folder.path isDirectory:&directory] || !directory ||
        ![files isWritableFileAtPath:folder.path]) {
        self.status = @"Escolha uma pasta com permissão para salvar.";
        return;
    }
    NSString *ytDlp = [self tool:@"yt-dlp"];
    NSString *ffmpeg = [self tool:@"ffmpeg"];
    if (!ytDlp || !ffmpeg) {
        self.status = @"O download precisa de yt-dlp e FFmpeg instalados. Consulte LEIA-ME-ArnMotion.md.";
        return;
    }
    NSMutableArray *arguments = [NSMutableArray arrayWithArray:@[
        @"--ignore-config", @"--no-playlist", @"--newline", @"--progress", @"--no-color",
        @"--restrict-filenames", @"--no-overwrites", @"--ffmpeg-location", ffmpeg]];
    NSString *host = URL.host.lowercaseString;
    BOOL youtube = [host isEqualToString:@"youtube.com"] ||
        [host hasSuffix:@".youtube.com"] || [host isEqualToString:@"youtu.be"];
    if (youtube && [self.cookiesBrowser isEqualToString:@"chrome"])
        [arguments addObjectsFromArray:@[@"--cookies-from-browser", @"chrome"]];
    if (audioOnly)
        [arguments addObjectsFromArray:@[@"--extract-audio", @"--audio-format", @"mp3"]];
    else
        [arguments addObjectsFromArray:@[@"--format", @"bv*+ba/b", @"--merge-output-format", @"mp4", @"--remux-video", @"mp4"]];
    [arguments addObjectsFromArray:@[@"--output",
        [folder.path stringByAppendingPathComponent:@"%(title)s [%(id)s].%(ext)s"], @"--", URL.absoluteString]];
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = ytDlp;
    task.arguments = arguments;
    NSMutableDictionary *environment = [[[NSProcessInfo processInfo] environment] mutableCopy];
    [environment setObject:[NSString stringWithFormat:@"%@:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:%@",
        [ytDlp stringByDeletingLastPathComponent], [environment objectForKey:@"PATH"] ?: @""] forKey:@"PATH"];
    task.environment = environment;
    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    task.standardError = pipe;
    self.task = task;
    self.cancellationRequested = NO;
    self.progress = 0;
    self.status = @"Preparando download…";
    self.running = YES;
    @try {
        [task launch];
    } @catch (NSException *exception) {
        self.status = @"Não foi possível iniciar o yt-dlp. Confira a instalação.";
        self.running = NO;
        self.task = nil;
        return;
    }
    /* One reader drains both streams; parsing complete lines handles partial UTF-8 reads. */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSMutableData *pending = [NSMutableData data];
            NSRegularExpression *percent = [NSRegularExpression regularExpressionWithPattern:
                @"\\[download\\]\\s+([0-9]+(?:\\.[0-9]+)?)%" options:0 error:NULL];
            __block NSString *lastError = nil;
            void (^consume)(NSData *) = ^(NSData *lineData) {
                NSString *line = [[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding];
                if (!line.length) return;
                if ([line hasPrefix:@"ERROR:"]) lastError = line;
                NSTextCheckingResult *match = [percent firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
                if (match.numberOfRanges > 1) {
                    NSInteger value = MAX(0, MIN(100, (NSInteger)llround([[line substringWithRange:[match rangeAtIndex:1]] doubleValue])));
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.task != task || self.cancellationRequested) return;
                        self.progress = value;
                        self.status = [NSString stringWithFormat:@"Baixando… %ld%%", (long)value];
                    });
                }
            };
            @try {
                while (YES) {
                    NSData *data = [pipe.fileHandleForReading availableData];
                    if (!data.length) break;
                    [pending appendData:data];
                    NSUInteger start = 0;
                    const unsigned char *bytes = pending.bytes;
                    for (NSUInteger index = 0; index < pending.length; index++) {
                        if (bytes[index] == '\n' || bytes[index] == '\r') {
                            consume([pending subdataWithRange:NSMakeRange(start, index-start)]);
                            start = index+1;
                        }
                    }
                    if (start) [pending replaceBytesInRange:NSMakeRange(0, start) withBytes:NULL length:0];
                    if (pending.length > 65536) [pending setLength:0];
                }
                if (pending.length) consume(pending);
            } @catch (NSException *exception) {
                lastError = @"Falha ao ler a saída do downloader.";
            }
            [task waitUntilExit];
            [pipe.fileHandleForReading closeFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.task != task) return;
                if (self.cancellationRequested) self.status = @"Download cancelado.";
                else if (task.terminationStatus == 0) {
                    self.progress = 100;
                    self.status = @"Download concluído. Arquivo salvo na pasta escolhida.";
                } else if (lastError && [lastError rangeOfString:@"Sign in to confirm"].location != NSNotFound) {
                    self.status = @"O YouTube pediu login. Abra o vídeo no Chrome conectado à sua conta, marque ‘Usar sessão do Chrome’ e tente novamente.";
                } else self.status = lastError ?: @"Falha no download. Confira o endereço e a conexão.";
                self.task = nil;
                self.cancellationRequested = NO;
                self.running = NO;
            });
        }
    });
}
- (void)cancel
{
    if (!self.running || !self.task) return;
    self.cancellationRequested = YES;
    self.status = @"Cancelando download…";
    if (self.task.running) [self.task terminate];
}
@end
