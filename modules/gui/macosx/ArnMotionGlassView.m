/* ArnMotion Player — Studio Arn. GPL-2.0-or-later. */
#import "ArnMotionGlassView.h"

/* The backdrop must not intercept clicks, dragging or accessibility controls. */
API_AVAILABLE(macos(10.10))
@interface ArnMotionGlassView : NSVisualEffectView
@end
@implementation ArnMotionGlassView
- (NSView *)hitTest:(NSPoint)point { return nil; }
@end

void ArnMotionInstallGlass(NSView *view)
{
    if (@available(macOS 10.10, *)) {
        for (NSView *child in view.subviews)
            if ([child isKindOfClass:[ArnMotionGlassView class]])
                return;
        ArnMotionGlassView *glass = [[ArnMotionGlassView alloc] initWithFrame:view.bounds];
        glass.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        glass.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        glass.state = NSVisualEffectStateActive;
        if (@available(macOS 10.14, *)) {
            glass.material = NSVisualEffectMaterialHUDWindow;
            glass.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
            view.appearance = glass.appearance;
        } else {
            glass.material = NSVisualEffectMaterialDark;
        }
        [view addSubview:glass positioned:NSWindowBelow relativeTo:nil];
    }
}

void ArnMotionInstallTitleGlass(NSWindow *window)
{
    if (@available(macOS 10.10, *)) {
        /* Decorate the native button container without adding height to the window. */
        if (!(window.styleMask & NSTitledWindowMask))
            return;
        window.titlebarAppearsTransparent = YES;
        NSView *titleView = [window standardWindowButton:NSWindowCloseButton].superview;
        if (titleView) ArnMotionInstallGlass(titleView);
    }
}
