import 'dart:convert';

import 'package:flutter_absensi_app/src/core/error/exception.dart';
import 'package:flutter_absensi_app/src/features/auth/data/datasource/remote_datasource.dart';
import 'package:flutter_absensi_app/src/features/auth/data/model/user_model.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

@GenerateNiceMocks([MockSpec<LoginRemoteDataSource>(), MockSpec<http.Client>()])
import 'remote_datasource_test.mocks.dart';

void main() async {
  var loginRemoteDataSource = MockLoginRemoteDataSource();
  MockClient mockClient = MockClient();
  var loginRemoteDataSourceImpl = LoginRemoteDataSourceImpl(client: mockClient);

  var urlLogin = Uri.parse("http://127.0.0.1:8000/api/login");
  var urlLogout = Uri.parse("http://127.0.0.1:8000/api/logout");

  Map<String, dynamic> fakeDataJson = {
    "user": {
      "id": 11,
      "name": "Fikri Haikal",
      "email": "fikrihaikal568@gmail.com",
      "email_verified_at": "2024-04-26T11:47:43.000000Z",
      "two_factor_secret": null,
      "two_factor_recovery_codes": null,
      "two_factor_confirmed_at": null,
      "created_at": "2024-04-26T11:47:43.000000Z",
      "updated_at": "2024-04-26T11:47:43.000000Z",
      "phone": null,
      "role": "user",
      "position": null,
      "department": null,
      "face_embedding": null,
      "image_url": null
    },
    "token": "20|YnuU3DGX4TRORPKWuwNt2tRplyN9KBLmGJ6nBajn72e6c9e4"
  };

  UserModel fakeUserModel = UserModel.fromJson(fakeDataJson);
  String? token = fakeUserModel.token;
  String email = "fikrihaikal568@gmail.com";
  String password = "haikal110599";

  group('Remote DataSource', () {
    group("Login", () {
      test('Success', () async {
        when(loginRemoteDataSource.login(email, password)).thenAnswer(
          (_) async => fakeUserModel,
        );
        try {
          var response = await loginRemoteDataSource.login(email, password);
          expect(response, fakeUserModel);
        } catch (e) {
          fail('Tidak Bisa Menerima Data');
        }
      });
      test('Failed', () async {
        when(loginRemoteDataSource.login(email, password))
            .thenThrow(Exception());

        try {
          await loginRemoteDataSource.login(email, password);
          fail('Tidak Mungkin Terjadi');
        } catch (e) {
          expect(e, isException);
        }
      });
    });
    group("Logout", () {
      test('Success', () async {
        when(loginRemoteDataSource.logout(token!)).thenAnswer(
          (_) async => true,
        );
        try {
          var response = await loginRemoteDataSource.logout(token);
          expect(response, true);
        } catch (e) {
          fail('Tidak Bisa Menerima Data');
        }
      });
      test('Failed', () async {
        when(loginRemoteDataSource.logout(token!))
            .thenThrow(const StatusCodeException(message: "Unauthenticated"));
        try {
          await loginRemoteDataSource.logout(token);
          fail('Tidak Mungkin Terjadi');
        } catch (e) {
          expect(e, const StatusCodeException(message: "Unauthenticated"));
        }
      });
    });
  });

  group('Remote DataSource Impl', () {
    test('login Success', () async {
      when(mockClient.post(urlLogin, body: {
        "email": email,
        "password": password,
      })).thenAnswer(
        (_) async => http.Response(jsonEncode(fakeDataJson), 200),
      );
      try {
        var response = await loginRemoteDataSourceImpl.login(email, password);
        expect(response, fakeUserModel);
      } catch (e) {
        fail('Tidak Bisa Menerima Data');
      }
    });
    test('login Failed 404', () async {
      when(mockClient.post(urlLogin, body: {
        "email": email,
        "password": password,
      })).thenThrow(const GeneralExeption(message: "Server Error"));
      try {
        await loginRemoteDataSourceImpl.login(email, password);
        fail('Tidak Mungkin Terjadi');
      } catch (e) {
        expect(e, const GeneralExeption(message: "Server Error"));
      }
    });
    test('login Failed ', () async {
      when(mockClient.post(urlLogin, body: {
        "email": email,
        "password": password,
      })).thenThrow(const GeneralExeption(message: "Cannot Get Data"));
      try {
        await loginRemoteDataSourceImpl.login(email, password);
        fail('Tidak Mungkin Terjadi');
      } catch (e) {
        expect(e, const GeneralExeption(message: "Cannot Get Data"));
      }
    });
  });
}
