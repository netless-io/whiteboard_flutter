// Mocks generated by Mockito 5.1.0 from annotations
// in whiteboard_sdk_flutter/test/bridge_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:whiteboard_sdk_flutter/src/bridge.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeInnerJavascriptInterface_0 extends _i1.Fake
    implements _i2.InnerJavascriptInterface {}

/// A class which mocks [DsBridge].
///
/// See the documentation for Mockito's code generation for more information.
class MockDsBridge extends _i1.Mock implements _i2.DsBridge {
  MockDsBridge() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int get callID =>
      (super.noSuchMethod(Invocation.getter(#callID), returnValue: 0) as int);
  @override
  set callID(int? _callID) =>
      super.noSuchMethod(Invocation.setter(#callID, _callID),
          returnValueForMissingStub: null);
  @override
  Map<int, _i2.OnReturnValue<dynamic>> get handlerMap =>
      (super.noSuchMethod(Invocation.getter(#handlerMap),
              returnValue: <int, _i2.OnReturnValue<dynamic>>{})
          as Map<int, _i2.OnReturnValue<dynamic>>);
  @override
  set handlerMap(Map<int, _i2.OnReturnValue<dynamic>>? _handlerMap) =>
      super.noSuchMethod(Invocation.setter(#handlerMap, _handlerMap),
          returnValueForMissingStub: null);
  @override
  set callInfoList(List<_i2.CallInfo>? _callInfoList) =>
      super.noSuchMethod(Invocation.setter(#callInfoList, _callInfoList),
          returnValueForMissingStub: null);
  @override
  _i2.InnerJavascriptInterface get javascriptInterface =>
      (super.noSuchMethod(Invocation.getter(#javascriptInterface),
              returnValue: _FakeInnerJavascriptInterface_0())
          as _i2.InnerJavascriptInterface);
  @override
  set javascriptInterface(_i2.InnerJavascriptInterface? _javascriptInterface) =>
      super.noSuchMethod(
          Invocation.setter(#javascriptInterface, _javascriptInterface),
          returnValueForMissingStub: null);
  @override
  _i3.FutureOr<String?>? evaluateJavascript(String? javascript) =>
      (super.noSuchMethod(Invocation.method(#evaluateJavascript, [javascript]))
          as _i3.FutureOr<String?>?);
  @override
  _i3.FutureOr<String?>? dispatchJavascriptCall(_i2.CallInfo? info) =>
      (super.noSuchMethod(Invocation.method(#dispatchJavascriptCall, [info]))
          as _i3.FutureOr<String?>?);
  @override
  _i3.FutureOr<String?>? callHandler(String? method,
          [List<dynamic>? args = const [],
          _i2.OnReturnValue<dynamic>? handler]) =>
      (super.noSuchMethod(
              Invocation.method(#callHandler, [method, args, handler]))
          as _i3.FutureOr<String?>?);
  @override
  void hasJavascriptMethod(
          String? handlerName, _i2.OnReturnValue<dynamic>? existCallback) =>
      super.noSuchMethod(
          Invocation.method(#hasJavascriptMethod, [handlerName, existCallback]),
          returnValueForMissingStub: null);
  @override
  void addJavascriptObject(_i2.JavaScriptNamespaceInterface? interface) =>
      super.noSuchMethod(Invocation.method(#addJavascriptObject, [interface]),
          returnValueForMissingStub: null);
  @override
  void removeJavascriptObject(String? namespace) => super.noSuchMethod(
      Invocation.method(#removeJavascriptObject, [namespace]),
      returnValueForMissingStub: null);
}