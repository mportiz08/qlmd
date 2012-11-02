#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <Foundation/Foundation.h>
#include <QuickLook/QuickLook.h>

#include "html.h"
#include "markdown.h"

#define OUTPUT_UNIT 64
#define EXTENSIONS  0
#define MAX_NESTING 16

#define CSS_GITHUB "<style>html{border:3px solid #eee;margin:2em auto;padding:0;width:975px}body{background-color:#fff;border:1px solid #cacaca;font-family:Helvetica,arial,sans-serif;font-size:14px;line-height:1.6;padding:30px;margin:0}body>*:first-child{margin-top:0!important}body>*:last-child{margin-bottom:0!important}a{color:#4183c4;text-decoration:none}a:hover{text-decoration:underline}a.absent{color:#c00}a.anchor{display:block;padding-left:30px;margin-left:-30px;cursor:pointer;position:absolute;top:0;left:0;bottom:0}h1,h2,h3,h4,h5,h6{margin:20px 0 10px;padding:0;font-weight:700;-webkit-font-smoothing:antialiased;cursor:text;position:relative}h1:hover a.anchor,h2:hover a.anchor,h3:hover a.anchor,h4:hover a.anchor,h5:hover a.anchor,h6:hover a.anchor{background:url(../../images/modules/styleguide/para.png) no-repeat 10px center;text-decoration:none}h1 tt,h1 code{font-size:inherit}h2 tt,h2 code{font-size:inherit}h3 tt,h3 code{font-size:inherit}h4 tt,h4 code{font-size:inherit}h5 tt,h5 code{font-size:inherit}h6 tt,h6 code{font-size:inherit}h1{font-size:28px;color:#000}h2{font-size:24px;border-bottom:1px solid #ccc;color:#000}h3{font-size:18px}h4{font-size:16px}h5{font-size:14px}h6{color:#777;font-size:14px}p,blockquote,ul,ol,dl,li,table,pre{margin:15px 0}hr{background:transparent url(https://a248.e.akamai.net/assets.github.com/assets/primer/markdown/dirty-shade-0e7d81b119cc9beae17b0c98093d121fa0050a74.png) repeat-x 0 0;border:0 none;color:#ccc;height:4px;padding:0}body>h2:first-child{margin-top:0;padding-top:0}body>h1:first-child{margin-top:0;padding-top:0}body>h1:first-child+h2{margin-top:0;padding-top:0}body>h3:first-child,body>h4:first-child,body>h5:first-child,body>h6:first-child{margin-top:0;padding-top:0}a:first-child h1,a:first-child h2,a:first-child h3,a:first-child h4,a:first-child h5,a:first-child h6{margin-top:0;padding-top:0}h1 p,h2 p,h3 p,h4 p,h5 p,h6 p{margin-top:0}li p.first{display:inline-block}ul,ol{padding-left:30px}ul:first-child,ol:first-child{margin-top:0}ul:last-child,ol:last-child{margin-bottom:0}dl{padding:0}dl dt{font-size:14px;font-weight:700;font-style:italic;padding:0;margin:15px 0 5px}dl dt:first-child{padding:0}dl dt>:first-child{margin-top:0}dl dt>:last-child{margin-bottom:0}dl dd{margin:0 0 15px;padding:0 15px}dl dd>:first-child{margin-top:0}dl dd>:last-child{margin-bottom:0}blockquote{border-left:4px solid #ddd;padding:0 15px;color:#777}blockquote>:first-child{margin-top:0}blockquote>:last-child{margin-bottom:0}table{border-collapse:collapse;border-spacing:0;padding:0}table tr{border-top:1px solid #ccc;background-color:#fff;margin:0;padding:0}table tr:nth-child(2n){background-color:#f8f8f8}table tr th{font-weight:700;border:1px solid #ccc;text-align:left;margin:0;padding:6px 13px}table tr td{border:1px solid #ccc;text-align:left;margin:0;padding:6px 13px}table tr th:first-child,table tr td:first-child{margin-top:0}table tr th:last-child,table tr td:last-child{margin-bottom:0}img{max-width:100%}span.frame{display:block;overflow:hidden}span.frame>span{border:1px solid #ddd;display:block;float:left;overflow:hidden;margin:13px 0 0;padding:7px;width:auto}span.frame span img{display:block;float:left}span.frame span span{clear:both;color:#333;display:block;padding:5px 0 0}span.align-center{display:block;overflow:hidden;clear:both}span.align-center>span{display:block;overflow:hidden;margin:13px auto 0;text-align:center}span.align-center span img{margin:0 auto;text-align:center}span.align-right{display:block;overflow:hidden;clear:both}span.align-right>span{display:block;overflow:hidden;margin:13px 0 0;text-align:right}span.align-right span img{margin:0;text-align:right}span.float-left{display:block;margin-right:13px;overflow:hidden;float:left}span.float-left span{margin:13px 0 0}span.float-right{display:block;margin-left:13px;overflow:hidden;float:right}span.float-right>span{display:block;overflow:hidden;margin:13px auto 0;text-align:right}code,tt{margin:0 2px;padding:0 5px;white-space:nowrap;border:1px solid #eaeaea;background-color:#f8f8f8;border-radius:3px}pre code{margin:0;padding:0;white-space:pre;border:0;background:transparent}.highlight pre{background-color:#f8f8f8;border:1px solid #ccc;font-size:13px;line-height:19px;overflow:auto;padding:6px 10px;border-radius:3px}pre{background-color:#f8f8f8;border:1px solid #ccc;font-size:13px;line-height:19px;overflow:auto;padding:6px 10px;border-radius:3px}pre code,pre tt{background-color:transparent;border:0}.markdown-body code,.markdown-body tt{margin:0 2px;padding:0 5px;white-space:nowrap;border:1px solid #eaeaea;background-color:#f8f8f8;border-radius:3px}.markdown-body pre>code{margin:0;padding:0;white-space:pre;border:0;background:transparent}.markdown-body .highlight pre,.markdown-body pre{background-color:#f8f8f8;border:1px solid #ccc;font-size:13px;line-height:19px;overflow:auto;padding:6px 10px;border-radius:3px}.markdown-body pre code,.markdown-body pre tt{background-color:transparent;border:0}.highlight{background:#fff}.highlight .c{color:#998;font-style:italic}.highlight .err{color:#a61717;background-color:#e3d2d2}.highlight .k{font-weight:700}.highlight .o{font-weight:700}.highlight .cm{color:#998;font-style:italic}.highlight .cp{color:#999;font-weight:700}.highlight .c1{color:#998;font-style:italic}.highlight .cs{color:#999;font-weight:700;font-style:italic}.highlight .gd{color:#000;background-color:#fdd}.highlight .gd .x{color:#000;background-color:#faa}.highlight .ge{font-style:italic}.highlight .gr{color:#a00}.highlight .gh{color:#999}.highlight .gi{color:#000;background-color:#dfd}.highlight .gi .x{color:#000;background-color:#afa}.highlight .go{color:#888}.highlight .gp{color:#555}.highlight .gs{font-weight:700}.highlight .gu{color:purple;font-weight:700}.highlight .gt{color:#a00}.highlight .kc{font-weight:700}.highlight .kd{font-weight:700}.highlight .kn{font-weight:700}.highlight .kp{font-weight:700}.highlight .kr{font-weight:700}.highlight .kt{color:#458;font-weight:700}.highlight .m{color:#099}.highlight .s{color:#d14}.highlight .na{color:teal}.highlight .nb{color:#0086b3}.highlight .nc{color:#458;font-weight:700}.highlight .no{color:teal}.highlight .ni{color:purple}.highlight .ne{color:#900;font-weight:700}.highlight .nf{color:#900;font-weight:700}.highlight .nn{color:#555}.highlight .nt{color:navy}.highlight .nv{color:teal}.highlight .ow{font-weight:700}.highlight .w{color:#bbb}.highlight .mf{color:#099}.highlight .mh{color:#099}.highlight .mi{color:#099}.highlight .mo{color:#099}.highlight .sb{color:#d14}.highlight .sc{color:#d14}.highlight .sd{color:#d14}.highlight .s2{color:#d14}.highlight .se{color:#d14}.highlight .sh{color:#d14}.highlight .si{color:#d14}.highlight .sx{color:#d14}.highlight .sr{color:#009926}.highlight .s1{color:#d14}.highlight .ss{color:#990073}.highlight .bp{color:#999}.highlight .vc{color:teal}.highlight .vg{color:teal}.highlight .vi{color:teal}.highlight .il{color:#099}.highlight .gc{color:#999;background-color:#eaf2f5}.type-csharp .highlight .k{color:#00f}.type-csharp .highlight .kt{color:#00f}.type-csharp .highlight .nf{color:#000;font-weight:400}.type-csharp .highlight .nc{color:#2b91af}.type-csharp .highlight .nn{color:#000}.type-csharp .highlight .s{color:#a31515}.type-csharp .highlight .sc{color:#a31515}</style>"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
  NSMutableDictionary *props;
  NSMutableString *html;
  NSMutableString *rendered;
  struct buf *inbuf, *outbuf;
  struct html_renderopt opts;
  struct sd_callbacks callbacks;
  struct sd_markdown *markdown;
  
  @autoreleasepool {
    if(QLPreviewRequestIsCancelled(preview)) {
      return noErr;
    }
    
    props = [[NSMutableDictionary alloc] init];
    [props setObject:@"UTF-8" forKey:(__bridge NSString *)kQLPreviewPropertyTextEncodingNameKey];
    [props setObject:@"text/html" forKey:(__bridge NSString *)kQLPreviewPropertyMIMETypeKey];
    
    html = [[NSMutableString alloc] init];
    [html appendString:@"<!DOCTYPE html><html><head><meta charset=\"UTF-8\" /><title>"];
    [html appendString:[(__bridge NSURL *)url lastPathComponent]];
    [html appendString:@"</title>"];
    [html appendString:[NSString stringWithUTF8String:CSS_GITHUB]];
    [html appendString:@"</head><body>"];
    
    NSString *unrendered = [NSString stringWithContentsOfURL:(__bridge NSURL *)url
                                                    encoding:NSUTF8StringEncoding error:NULL];
    NSData *data = [unrendered dataUsingEncoding:NSUTF8StringEncoding];
    const void *rawBytes = [data bytes];
    inbuf = bufnew([data length]);
    bufput(inbuf, rawBytes, [data length]);
    outbuf = bufnew(OUTPUT_UNIT);
    
    sdhtml_renderer(&callbacks, &opts, 0);
    markdown = sd_markdown_new(EXTENSIONS, MAX_NESTING, &callbacks, &opts);
    sd_markdown_render(outbuf, inbuf->data, inbuf->size, markdown);
    
    rendered = [[NSMutableString alloc] initWithBytes:outbuf->data
                                               length:outbuf->size
                                             encoding:NSUTF8StringEncoding];
    
    [html appendString:rendered];
    [html appendString:@"</body></html>"];
    NSLog(@"%@", html);
    
    QLPreviewRequestSetDataRepresentation(preview,
      (CFDataRef)CFBridgingRetain([html dataUsingEncoding:NSUTF8StringEncoding]),
      kUTTypeHTML, (CFDictionaryRef)CFBridgingRetain(props));
    
    sd_markdown_free(markdown);
    bufrelease(outbuf);
    bufrelease(inbuf);
  }
  
  return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
  // Not supported
}
