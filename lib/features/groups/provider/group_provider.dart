import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/data_sources/group_local_datasource.dart';
import '../data/data_sources/remote/group_remote_datasource.dart';
import '../data/repository/group_repository_impl.dart';


// Provider برای Isar
final isarProvider = Provider<Isar>((ref) {
  return Isar.getInstance()!;
});

// Provider برای Local Data Source
final groupLocalDataSourceProvider = Provider<GroupLocalDataSource>((ref) {
  final isar = ref.read(isarProvider);
  return GroupLocalDataSource(isar);
});

// Provider برای Remote Data Source
final groupRemoteDataSourceProvider = Provider<GroupRemoteDataSource>((ref) {
  final firestore = FirebaseFirestore.instance;
  return GroupRemoteDataSource(firestore);
});

// Provider برای Repository (استفاده از پیاده‌سازی واقعی)
final groupRepositoryProvider = Provider<GroupRepositoryImpl>((ref) {
  final local = ref.read(groupLocalDataSourceProvider);
  final remote = ref.read(groupRemoteDataSourceProvider);
  return GroupRepositoryImpl(local, remote);
});
