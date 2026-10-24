// Native entry point of Patrol's on-device tests (patrol_test/): lists the
// Dart tests and runs each one as an XCTest case. See docs/TESTING.md.
@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

#if !defined(PATROL_INTEGRATION_TEST_IOS_RUNNER)
#import "PatrolIntegrationTestIosRunner.h"
#endif

PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)
