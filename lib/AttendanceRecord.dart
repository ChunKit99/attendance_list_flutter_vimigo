//class attendance record to store record
class AttendanceRecord {
  String user;
  String phone;
  String check_in;

  //constructor
  AttendanceRecord(this.user, this.phone, this.check_in);

  //getter
  String get time => check_in;
  String get name => user;
  String get ph => phone;
}
