/// Public barrel of the `attendance` feature.
library;

export 'manifest.dart';
export 'src/attendance_data.dart' show todayAttendanceProvider, attendanceServiceProvider, minuteTickerProvider;
export 'src/attendance_domain.dart' show AttendanceDay, DayStatus, AttendanceEventType, computeDay, AttendanceEventIn;
export 'src/attendance_widgets.dart' show DutyCard, AttendanceCard, dutyStateOf;
