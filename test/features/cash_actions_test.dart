import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/api/api_models.dart';
import 'package:staff_app/core/api/field_api.dart';
import 'package:staff_app/features/cash/src/cash_actions.dart';

/// FR-M-058: what the user is told when the server refuses to change or delete a cash collection.
ApiException conflict409(String reason) => ApiException(
      statusCode: 409,
      problem: Problem(status: 409, code: 'INVALID_STATE', title: 'x', details: {'reason': reason}),
    );

void main() {
  test('each INVALID_STATE reason of contract 1.32.0 has its own message', () {
    expect(cashActionErrorOf(conflict409('COVERED_BY_DEPOSIT')), CashActionError.covered);
    expect(cashActionErrorOf(conflict409('NOT_EDITABLE')), CashActionError.notEditable);
    expect(cashActionErrorOf(conflict409('USE_RESOLVE')), CashActionError.notEditable);
    expect(cashActionErrorOf(conflict409('ALREADY_POSTED_OR_CLOSED')), CashActionError.posted);
    expect(cashActionErrorOf(conflict409('POSTING_IN_PROGRESS')), CashActionError.busy);
    expect(cashActionErrorOf(conflict409('STATUS_CHANGED')), CashActionError.busy);
    expect(cashActionErrorOf(conflict409('SOMETHING_NEW')), CashActionError.failed);
  });

  test('no network, a colleague\'s collection (404) and a missing permission (403) are told apart', () {
    expect(cashActionErrorOf(ApiException(isNetwork: true)), CashActionError.offline);
    expect(cashActionErrorOf(ApiException(statusCode: 404)), CashActionError.notAllowed);
    expect(cashActionErrorOf(ApiException(statusCode: 403)), CashActionError.notAllowed);
  });
}

