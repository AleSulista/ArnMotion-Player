/*****************************************************************************
 * VLCAboutWindowController.m
 *****************************************************************************
 * Copyright (C) 2001-2014 VLC authors and VideoLAN
 * $Id: f11e7fe1917017edd8767583f53e82fa0d35c88e $
 *
 * Authors: Derk-Jan Hartman <thedj@users.sourceforge.net>
 *          Felix Paul Kühne <fkuehne -at- videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

/*****************************************************************************
 * Preamble
 *****************************************************************************/

#import "VLCAboutWindowController.h"

#import "VLCMain.h"
#import <vlc_intf_strings.h>
#import <vlc_about.h>
#import "CompatibilityFixes.h"

#import "VLCScrollingClipView.h"

#ifdef __x86_64__
#define PLATFORM "Intel 64bit"
#else
#define PLATFORM "Apple Silicon"
#endif

@interface VLCAboutWindowController ()
{
    NSString *_authorsString;
}
@end

@implementation VLCAboutWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"About"];
    if (self) {
        [self setWindowFrameAutosaveName:@"about"];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

/*****************************************************************************
* VLC About Window
*****************************************************************************/

- (void)showAbout
{
    [self window];

    /* Show the window */
    [o_credits_scrollview setHidden:YES];
    [o_credits_textview setHidden:YES];
    [o_joinus_txt setHidden:NO];
    [o_copyright_field setHidden:NO];
    [o_revision_field setHidden:NO];
    [o_name_version_field setHidden:NO];
    [o_credits_textview scrollPoint:NSMakePoint(0, 0)];

    [self showWindow:nil];
}

- (void)windowDidLoad
{
    [[self window] setCollectionBehavior: NSWindowCollectionBehaviorFullScreenAuxiliary];

    [o_copyright_field setStringValue:@"© 2026 Studio Arn • Base VLC / VideoLAN"];

    /* l10n */
    [[self window] setTitle: @"Sobre o ArnMotion Player"];
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName, [NSColor VLCSecondaryLabelColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:13], NSFontAttributeName, nil];
    NSAttributedString *attrStr;
    attrStr = [[NSAttributedString alloc] initWithString:_NS("Credits") attributes:stringAttributes];
    [o_credits_btn setAttributedTitle:attrStr];
    attrStr = [[NSAttributedString alloc] initWithString:_NS("License") attributes:stringAttributes];
    [o_gpl_btn setAttributedTitle:attrStr];
    attrStr = [[NSAttributedString alloc] initWithString:_NS("Authors") attributes:stringAttributes];
    [o_authors_btn setAttributedTitle:attrStr];
    [o_trademarks_txt setStringValue:_NS("VLC media player and VideoLAN are trademarks of the VideoLAN Association.")];

    /* setup the creator / revision field */
    [o_revision_field setStringValue:@"Programador: Alessandro Henriques Teixeira • Studio Arn"];

    /* Setup the nameversion field */
    [o_name_version_field setStringValue: [NSString stringWithFormat:@"ArnMotion Player • Base VLC %s (%s)", VERSION_MESSAGE, PLATFORM]];

    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray: [toNSStr(psz_authors) componentsSeparatedByString:@"\n\n"]];
    NSUInteger count = [tmpArray count];
    for (NSUInteger i = 0; i < count; i++) {
        [tmpArray replaceObjectAtIndex:i withObject:[[tmpArray objectAtIndex:i]stringByReplacingOccurrencesOfString:@"\n" withString:@", "]];
        [tmpArray replaceObjectAtIndex:i withObject:[[tmpArray objectAtIndex:i]stringByReplacingOccurrencesOfString:@", -" withString:@"\n-" options:0 range:NSRangeFromString(@"0 30")]];
        [tmpArray replaceObjectAtIndex:i withObject:[[tmpArray objectAtIndex:i]stringByReplacingOccurrencesOfString:@"-, " withString:@"-\n" options:0 range:NSRangeFromString(@"0 30")]];
        [tmpArray replaceObjectAtIndex:i withObject:[[tmpArray objectAtIndex:i]stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]]];
    }
    _authorsString = [tmpArray componentsJoinedByString:@"\n\n"];

    /* setup join us! */
    NSString *joinus = @"<p><b>Studio Arn — projeto pessoal e sem fins lucrativos.</b><br>"
        "Melhorias desenvolvidas por Alessandro Henriques Teixeira sobre a base VLC.</p>"
        "<p>Download autorizado, identidade própria, barras translúcidas e volume até 400%.</p>"
        "<p>Faça uma doação para que o Studio Arn possa desenvolver novas melhorias.<br>"
        "<b>PIX:</b> studioarn@aletecweb.com.br<br>"
        "<a href=\"https://www.aletecweb.com.br\">www.aletecweb.com.br</a></p>"
        "<p>Base VLC / VideoLAN: licença e créditos preservados.</p>";

    NSString *joinUsWithStyle = [NSString stringWithFormat:@"<div style=\"text-align:left;font-family: -apple-system, Helvetica Neue;\">%@</div>", joinus];
    NSMutableAttributedString *joinus_readytorender = [[NSMutableAttributedString alloc] initWithHTML:[joinUsWithStyle dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]
                                                                                              options:@{NSCharacterEncodingDocumentOption : [NSNumber numberWithInt:NSUTF8StringEncoding]}
                                                                                   documentAttributes:NULL];
    [joinus_readytorender setAttributes:@{NSForegroundColorAttributeName : [NSColor VLCSecondaryLabelColor],
                                          NSFontAttributeName : [NSFont systemFontOfSize:12.]}
                                  range:NSMakeRange(0, joinus_readytorender.length)];
    [o_joinus_txt setAllowsEditingTextAttributes: YES];
    [o_joinus_txt setSelectable: YES];
    [o_joinus_txt setAttributedStringValue:joinus_readytorender];

    [o_credits_textview setString: @""];

    /* Setup the window */
    [o_credits_textview setDrawsBackground: NO];
    [o_credits_scrollview setDrawsBackground: NO];
    [[self window] setExcludedFromWindowsMenu:YES];
    [[self window] setMenu:nil];

    [o_icon_view setImage:[NSImage imageNamed:@"ArnMotion"]];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [(VLCScrollingClipView *)[o_credits_scrollview contentView] stopScrolling];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    [(VLCScrollingClipView *)[o_credits_scrollview contentView] stopScrolling];
}

- (IBAction)buttonAction:(id)sender
{
    [o_credits_scrollview setHidden:NO];
    [o_credits_textview setHidden:NO];
    [o_joinus_txt setHidden:YES];
    [o_copyright_field setHidden:YES];
    [o_revision_field setHidden:YES];
    [o_name_version_field setHidden:YES];

    NSString *stringToDisplay;
    if (sender == o_authors_btn)
        stringToDisplay = _authorsString;
    else if (sender == o_credits_btn)
        stringToDisplay = [toNSStr(psz_thanks) stringByReplacingOccurrencesOfString:@"\n" withString:@" "
                                                                            options:0 range:NSRangeFromString(@"680 2")];
    else
        stringToDisplay = toNSStr(psz_license);

    NSString *introduction = @"ArnMotion Player — Studio Arn\n"
        "Projeto pessoal de melhorias, sem fins lucrativos.\n"
        "Programador: Alessandro Henriques Teixeira.\n\n"
        "Base utilizada: VLC media player, desenvolvido pelos autores do VLC e pela comunidade VideoLAN.\n"
        "Melhorias Studio Arn: download autorizado de vídeo e áudio, identidade visual própria, barras translúcidas e controle de volume até 400%.\n\n"
        "Faça uma doação para que o Studio Arn possa desenvolver novas melhorias.\n"
        "PIX (chave e-mail): studioarn@aletecweb.com.br\n"
        "Contato: studioarn@aletecweb.com.br\n"
        "Site: https://www.aletecweb.com.br\n\n"
        "Os créditos e a licença da base VLC são preservados abaixo.\n"
        "As alterações do Studio Arn seguem a licença dos arquivos adaptados.\n\n"
        "————————————————————————————————\n\n";
    stringToDisplay = [introduction stringByAppendingString:stringToDisplay ?: @""];

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:stringToDisplay
                                                                           attributes:@{NSForegroundColorAttributeName : [NSColor VLCSecondaryLabelColor],
                                                                                        NSFontAttributeName : [NSFont systemFontOfSize:12.]}];
    [[o_credits_textview textStorage] setAttributedString:attributedString];

    VLCScrollingClipView *scrollView = (VLCScrollingClipView *)[o_credits_scrollview contentView];
    [scrollView resetScrolling];
    [scrollView stopScrolling];
}

/*****************************************************************************
* VLC GPL Window, action called from the about window and the help menu
*****************************************************************************/

- (void)showGPL
{
    [self showAbout];
    [self buttonAction:nil];
}

@end
