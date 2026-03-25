import 'package:flutter_test/flutter_test.dart';
import 'package:kmymoney_app/data/kmy_parser.dart';

void main() {
  group('KmyParser.parseAccounts', () {
    const xml = '''
<KMYMONEY-FILE>
  <ACCOUNTS>
    <ACCOUNT id="A000435" parentaccount="AStd::Asset" lastreconciled="" lastmodified="2026-03-05" institution="I000030" opened="2024-06-04" number="" type="1" name="Account 1" description="" currency="PLN">
      <KEYVALUEPAIRS>
        <PAIR key="PreferredAccount" value="Yes"/>
        <PAIR key="lastNumberUsed" value="4"/>
      </KEYVALUEPAIRS>
    </ACCOUNT>
    <ACCOUNT id="A000435" institution="I000030" number="" type="1" name="" description="" currency="PLN">
    </ACCOUNT>
  </ACCOUNTS>
</KMYMONEY-FILE>
''';
    const xmlClosed = '''
<KMYMONEY-FILE>
  <ACCOUNTS>
    <ACCOUNT id="A000444" parentaccount="AStd::Asset" lastreconciled="" lastmodified="2025-05-12" institution="I000045" opened="2024-08-29" number="" type="1" name="Account closed" description="" currency="PLN">
      <KEYVALUEPAIRS>
        <PAIR key="lastStatementBalance" value="0/1"/>
        <PAIR key="minBalanceEarly" value="0.00"/>
        <PAIR key="mm-closed" value="yes"/>
        <PAIR key="reconciliationHistory" value=":0/1"/>
      </KEYVALUEPAIRS>
    </ACCOUNT>
  </ACCOUNTS>
</KMYMONEY-FILE>
''';
    test('parses PreferredAccount=Yes as preffered=true', () {
      final parser = KmyParser(xml);
      final accounts = parser.parseAccounts();

      expect(accounts, hasLength(1));
      expect(accounts.single.id, 'A000435');
      expect(accounts.single.preferred, true);
    });

    test('merges duplicate accounts and preserves preferred=true', () {
      final parser = KmyParser(xml);
      final accounts = parser.parseAccounts();

      expect(accounts, hasLength(1));
      expect(accounts.single.name, 'Account 1');
      expect(accounts.single.preferred, true);
    });

    test('parses mm-closed=yes as closed=true', () {
      final parser = KmyParser(xmlClosed);
      final accounts = parser.parseAccounts();

      expect(accounts.single.closed, true);
    });
  });
}
