// Mocks generated by Mockito 5.4.4 from annotations
// in sr_demo/test/blocs/image_bloc_error_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:sr_demo/data/image_repository.dart' as _i3;
import 'package:sr_demo/models/image_model.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeImageModel_0 extends _i1.SmartFake implements _i2.ImageModel {
  _FakeImageModel_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ImageRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockImageRepository extends _i1.Mock implements _i3.ImageRepository {
  MockImageRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<List<_i2.ImageModel>> fetchImages({
    int? page = 1,
    int? limit = 20,
    bool? refresh = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchImages,
          [],
          {
            #page: page,
            #limit: limit,
            #refresh: refresh,
          },
        ),
        returnValue: _i4.Future<List<_i2.ImageModel>>.value(<_i2.ImageModel>[]),
      ) as _i4.Future<List<_i2.ImageModel>>);

  @override
  _i4.Future<_i2.ImageModel> toggleLikeStatusAsync(_i2.ImageModel? image) =>
      (super.noSuchMethod(
        Invocation.method(
          #toggleLikeStatusAsync,
          [image],
        ),
        returnValue: _i4.Future<_i2.ImageModel>.value(_FakeImageModel_0(
          this,
          Invocation.method(
            #toggleLikeStatusAsync,
            [image],
          ),
        )),
      ) as _i4.Future<_i2.ImageModel>);

  @override
  _i2.ImageModel toggleLikeStatus(_i2.ImageModel? image) => (super.noSuchMethod(
        Invocation.method(
          #toggleLikeStatus,
          [image],
        ),
        returnValue: _FakeImageModel_0(
          this,
          Invocation.method(
            #toggleLikeStatus,
            [image],
          ),
        ),
      ) as _i2.ImageModel);

  @override
  List<_i2.ImageModel> getLikedImages() => (super.noSuchMethod(
        Invocation.method(
          #getLikedImages,
          [],
        ),
        returnValue: <_i2.ImageModel>[],
      ) as List<_i2.ImageModel>);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
