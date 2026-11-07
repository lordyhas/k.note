import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/core/themes/app_theme.dart';
import 'package:knote/ui/settings/widgets/feedback_page.dart';

import '../../../helpers/localized_app.dart';

const _user = User(
  id: 'uid-1',
  email: 'me@example.com',
  name: 'Me',
  photoMail: null,
  isCheckMail: true,
);

void main() {
  testWidgets('sends the message typed', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'K.Note',
      packageName: 'com.kdynamic.k_note',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(Theme(
      data: AppTheme.dark,
      child: localizedApp(
        home: FeedbackPage(
          firebaseManager: FirestoreService.user(_user, firestore),
        ),
      ),
    ));

    final send = find.byKey(const Key('__feedback_send__'));
    expect(tester.widget<ButtonStyleButton>(send).onPressed, isNull);

    await tester.enterText(
        find.byKey(const Key('__feedback_message__')), '  Love it  ');
    await tester.pump();
    await tester.tap(send);
    await tester.pumpAndSettle();

    final docs = (await firestore.collection('feedback').get()).docs;
    expect(docs, hasLength(1));
    expect(docs.single.data()['message'], 'Love it');
    expect(docs.single.data()['uid'], 'uid-1');
    expect(docs.single.data()['app_version'], '1.0.0');
    expect(
        find.text('Thank you! Your feedback has been sent.'), findsOneWidget);
  });
}
