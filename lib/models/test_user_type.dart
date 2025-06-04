enum TestUserType {
  self,
  other;

  bool get requiresGPS => this == TestUserType.self;
}

class TestExecutionConfig {
  final TestUserType userType;
  final bool gpsEnabled;

  const TestExecutionConfig({
    required this.userType,
    required this.gpsEnabled,
  });

  factory TestExecutionConfig.forUserType(TestUserType type) {
    return TestExecutionConfig(
      userType: type,
      gpsEnabled: type.requiresGPS,
    );
  }
} 