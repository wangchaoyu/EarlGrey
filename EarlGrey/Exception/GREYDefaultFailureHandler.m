//
// Copyright 2016 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Exception/GREYDefaultFailureHandler.h"

#import <XCTest/XCTestAssertionsImpl.h>

#import "Additions/XCTestCase+GREYAdditions.h"
#import "Common/GREYConfiguration.h"
#import "Common/GREYElementHierarchy.h"
#import "Common/GREYPrivate.h"
#import "Common/GREYScreenshotUtil.h"
#import "Common/GREYVisibilityChecker.h"
#import "Exception/GREYFrameworkException.h"
#import "Provider/GREYUIWindowProvider.h"

@implementation GREYDefaultFailureHandler {
  NSString *_fileName;
  NSUInteger _lineNumber;
}

#pragma mark - GREYFailureHandler

- (void)setInvocationFile:(NSString *)fileName andInvocationLine:(NSUInteger)lineNumber {
  _fileName = fileName;
  _lineNumber = lineNumber;
}

- (void)handleException:(GREYFrameworkException *)exception details:(NSString *)details {
  NSParameterAssert(exception);
  NSMutableString *exceptionLog = [[NSMutableString alloc] init];

  // Extra newlines before displaying window hierarchy.
  [exceptionLog appendString:@"Application window hierarchy (ordered by window level, "
                             @"from front to back):\n\n"];

  // Legend.
  [exceptionLog appendString:@"Legend:\n"
                             @"[Window 1] = [Frontmost Window]\n"
                             @"[AX] = [Accessibility]\n\n"];

  // Windows
  int index = 0;
  for (UIWindow *window in [GREYUIWindowProvider allWindows]) {
    index++;
    NSString *hierarchy = [GREYElementHierarchy hierarchyStringForElement:window];
    [exceptionLog appendFormat:@"========== Window %d ==========\n\n%@\n\n",
                               index, hierarchy];
  }
  // Extra newlines after displaying window hierarchy.
  [exceptionLog appendString:@"\n\n"];

  [exceptionLog appendString:@"========== Detailed Exception ==========\n\n"];
  [exceptionLog appendFormat:@"Exception: %@\n", [exception name]];
  if ([exception reason]) {
    [exceptionLog appendFormat:@"Reason: %@\n", [exception reason]];
  } else {
    [exceptionLog appendString:@"Reason for exception was not provided.\n"];
  }
  if (details) {
    [exceptionLog appendFormat:@"%@\n", details];
  }
  [exceptionLog appendString:@"\n"];

  // Pull the raw test case name
  // Test name can be nil if EarlGrey is invoked outside the context of a XCTestCase.
  NSString *testClassName = [[XCTestCase grey_currentTestCase] grey_testClassName];
  NSString *testMethodName = [[XCTestCase grey_currentTestCase] grey_testMethodName];
  NSString *screenshotName = [NSString stringWithFormat:@"%@_%@", testClassName, testMethodName];

  // Log the screenshot.
  [self grey_savePNGImage:[GREYScreenshotUtil grey_takeScreenshotAfterScreenUpdates:NO]
              toFileNamed:[NSString stringWithFormat:@"%@.png", screenshotName]
              forCategory:@"Screenshot At Failure"
          appendingLogsTo:exceptionLog];

  // Log before and after images (if available) for the element under test.
  UIImage *beforeImage = [GREYVisibilityChecker grey_lastActualBeforeImage];
  UIImage *afterExpectedImage = [GREYVisibilityChecker grey_lastExpectedAfterImage];
  UIImage *afterActualImage = [GREYVisibilityChecker grey_lastActualAfterImage];

  [self grey_savePNGImage:beforeImage
              toFileNamed:[NSString stringWithFormat:@"%@_before.png", screenshotName]
              forCategory:@"Visibility Checker's Most Recent Before Image"
          appendingLogsTo:exceptionLog];
  [self grey_savePNGImage:afterExpectedImage
              toFileNamed:[NSString stringWithFormat:@"%@_after_expected.png", screenshotName]
              forCategory:@"Visibility Checker's Most Recent Expected After Image"
          appendingLogsTo:exceptionLog];
  [self grey_savePNGImage:afterActualImage
              toFileNamed:[NSString stringWithFormat:@"%@_after_actual.png", screenshotName]
              forCategory:@"Visibility Checker's Most Recent Actual After Image"
          appendingLogsTo:exceptionLog];

  NSString *failureDescription;
  if (exception.reason) {
    failureDescription = exception.reason;
  } else {
    failureDescription = [NSString stringWithFormat:@"%@ has occurred.", [exception class]];
  }
  NSLog(@"%@", exceptionLog);

  [XCTestCase grey_currentTestCase].continueAfterFailure = NO;
  [[XCTestCase grey_currentTestCase] recordFailureWithDescription:failureDescription
                                                           inFile:_fileName
                                                           atLine:_lineNumber
                                                         expected:NO];
  [[XCTestCase grey_currentTestCase] grey_interruptExecution];
}

#pragma mark - Private

/**
 *  Saves the given @c image as a PNG file to the given @c fileName and appends a log to
 *  @c allLogs with the saved image's absolute path under the specified @c category.
 *
 *  @param image    Image to be saved as a PNG file.
 *  @param fileName The file name for the @c image to be saved.
 *  @param category The category for which the @c image is being saved.
 *                  This will be added to the front of the log.
 *  @param allLogs  Existing logs to which any new log statements are appended.
 */
- (void)grey_savePNGImage:(UIImage *)image
              toFileNamed:(NSString *)fileName
              forCategory:(NSString *)category
          appendingLogsTo:(NSMutableString *)allLogs {
  if (!image) {
    [allLogs appendFormat:@"No \"%@\" to save.\n", category];
    return;
  }

  NSString *screenshotDir = GREY_CONFIG_STRING(kGREYConfigKeyScreenshotDirLocation);
  NSString *filepath = [GREYScreenshotUtil saveImageAsPNG:image
                                                   toFile:fileName
                                              inDirectory:screenshotDir];
  if (filepath) {
    [allLogs appendFormat:@"%@: %@\n", category, filepath];
  } else {
    [allLogs appendFormat:@"Unable to save %@ as %@.\n", category, fileName];
  }
}

@end
