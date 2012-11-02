#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#include "html.h"
#include "markdown.h"

#define OUTPUT_UNIT 64
#define EXTENSIONS  0
#define MAX_NESTING 16

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
  CFDataRef data;
  CFStringRef html;
  struct html_renderopt opts;
  struct sd_callbacks callbacks;
  struct sd_markdown *markdown;
  SInt32 error;
  CFRange range;
  UInt8 *bytes;
  struct buf *in_buff, *out_buff;
  
  CFURLCreateDataAndPropertiesFromResource(NULL, url, &data, NULL, NULL, &error);
  range = CFRangeMake(0, CFDataGetLength(data));
  bytes = (UInt8 *)malloc(range.length * sizeof(UInt8));
  CFDataGetBytes(data, CFRangeMake(0, CFDataGetLength(data)), bytes);
  
  in_buff = bufnew(range.length);
  bufput(in_buff, bytes, range.length);
  out_buff = bufnew(OUTPUT_UNIT);
  
  sdhtml_renderer(&callbacks, &opts, 0);
  markdown = sd_markdown_new(EXTENSIONS, MAX_NESTING, &callbacks, &opts);
  sd_markdown_render(out_buff, in_buff->data, in_buff->size, markdown);
  
  html = CFStringCreateWithBytes(NULL, out_buff->data, out_buff->size, kCFStringEncodingUTF8, true);
  data = CFStringCreateExternalRepresentation(NULL, html, kCFStringEncodingUTF8, 0);
  QLPreviewRequestSetDataRepresentation(preview, data, kUTTypeHTML, NULL);
  
  sd_markdown_free(markdown);
  bufrelease(out_buff);
  bufrelease(in_buff);
  free(bytes);
  CFRelease(data);
  
  return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
  // Implement only if supported
}
