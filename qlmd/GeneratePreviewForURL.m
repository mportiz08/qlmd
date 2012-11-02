#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <Foundation/Foundation.h>
#include <QuickLook/QuickLook.h>

#include "html.h"
#include "markdown.h"

#define OUTPUT_UNIT 64
#define EXTENSIONS  0
#define MAX_NESTING 16

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
    [html appendString:@"<!DOCTYPE html><html><head><meta charset=\"UTF-8\" /></head><body>"];
    
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
