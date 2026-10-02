/*****************************************************************************
 * HelpWindowController.m
 *****************************************************************************
 * Copyright (C) 2001-2014 VLC authors and VideoLAN
 * $Id: 9520e5aead0dbcd99fce04073c7b3dc317df3115 $
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

#import "VLCHelpWindowController.h"

#import "VLCMain.h"
#import <vlc_intf_strings.h>
#import <vlc_about.h>
#import "CompatibilityFixes.h"
#import "VLCScrollingClipView.h"

@implementation VLCHelpWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"Help"];
    if (self) {
        [self setWindowFrameAutosaveName:@"help"];
    }

    return self;
}

- (void)windowDidLoad
{
    [[self window] setTitle:@"Ajuda do ArnMotion Player"];
    [forwardButton setToolTip:_NS("Next")];
    [backButton setToolTip:_NS("Previous")];
    [homeButton setToolTip:_NS("Index")];
}

- (void)showHelp
{
    [self showWindow:nil];
    [self helpGoHome:nil];
}

- (IBAction)helpGoHome:(id)sender
{
    NSString *htmlWithStyle = [NSString
                               stringWithFormat:@"<style>body { font-family: -apple-system, %@; }</style>%@",
                               ((OSX_YOSEMITE_AND_HIGHER) ? @"Helvetica Neue" : @"Lucida Grande"), [@"<h2>ArnMotion Player — Studio Arn</h2><p>Versão pessoal por Alessandro Henriques Teixeira, baseada no VLC.</p><p>Para baixar: Arquivo → Baixar vídeo autorizado. Cole o endereço, confirme a autorização, escolha MP4 ou MP3 e a pasta.</p><p>Contato: studioarn@aletecweb.com.br — <a href=\"https://www.aletecweb.com.br\">www.aletecweb.com.br</a></p><hr><h3>Documentação da base VLC</h3>" stringByAppendingString:_NS(I_LONGHELP)]];

    [[helpWebView mainFrame] loadHTMLString:htmlWithStyle
                                    baseURL:[NSURL URLWithString:@"https://videolan.org"]];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    /* Update back/forward button states whenever a new page is loaded */
    [forwardButton setEnabled:[helpWebView canGoForward]];
    [backButton setEnabled:[helpWebView canGoBack]];
}

@end
