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

#import <UIKit/UIKit.h>
#import <XCTest/XCTestCase.h>

/**
 *  Posted immediately prior to XCTestCase::setUp. The @c userInfo dictionary contains
 *  the current XCTestCase.
 */
UIKIT_EXTERN NSString *const kGREYXCTestCaseInstanceWillSetUp;

/**
 *  Posted immediately after XCTestCase::setUp is called. The @c userInfo dictionary contains the
 *  current XCTestCase.
 */
UIKIT_EXTERN NSString *const kGREYXCTestCaseInstanceDidSetUp;

/**
 *  Posted immediately prior to XCTestCase::tearDown. The @c userInfo dictionary contains
 *  the current XCTestCase.
 */
UIKIT_EXTERN NSString *const kGREYXCTestCaseInstanceWillTearDown;

/**
 *  Posted immediately after XCTestCase::tearDown is called. The @c userInfo dictionary contains
 *  the current XCTestCase.
 */
UIKIT_EXTERN NSString *const kGREYXCTestCaseInstanceDidTearDown;

/**
 *  Posted immediately after XCTestCase::invokeTest is executed successfully, denoting that the
 *  test has passed. The @c userInfo dictionary contains the current XCTestCase.
 */
UIKIT_EXTERN NSString *const kGREYXCTestCaseInstanceDidPass;

/**
 *  Posted immediately after XCTestCase::invokeTest raises an Exception, denoting that the test has
 *  failed. The @c userInfo dictionary contains the current XCTestCase.
 */
UIKIT_EXTERN NSString *const kGREYXCTestCaseInstanceDidFail;

/**
 *  Posted immediately after a XCTestCase finishes, successfully or not. The @c userInfo dictionary
 *  contains the current XCTestCase.
 */
UIKIT_EXTERN NSString *const kGREYXCTestCaseInstanceDidFinish;

/**
 *  Key for retrieving the current XCTestCase from the @c userInfo of a notification.
 */
UIKIT_EXTERN NSString *const kGREYXCTestCaseNotificationKey;

/**
 *  Extends XCTestCase with capabilities to return current testcase and allows observing various
 *  states of test execution. Also allows clearing various states that can leak across from one
 *  testcase to another.
 */
@interface XCTestCase (GREYAdditions)

/**
 *  @return The current XCTestCase being executed or @c nil if called outside context of a test
 *          method.
 */
+ (XCTestCase *)grey_currentTestCase;

/**
 *  @return The name of the current test method being executed or @c nil if called outside context
 *          of a test method.
 */
- (NSString *)grey_testMethodName;

/**
 *  @return The name of the test class to which this message was sent.
 */
- (NSString *)grey_testClassName;

/**
 *  Interrupts the current test case execution immediately, tears down the test and marks it as
 *  failed.
 */
- (void)grey_interruptExecution;

/**
 *  @return A unique test outputs directory for the current test. All test related outputs should be
 *          under this directory (and subdirectories).
 */
- (NSString *)grey_localizedTestOutputsDirectory;

@end

