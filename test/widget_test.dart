import 'package:flutter_test/flutter_test.dart';
import 'package:khire/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const KhireApp());
    expect(find.text('نظام إدارة توزيع المساعدات الخيرية'), findsWidgets);
  });
}
